use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::hash::{BuildHasherDefault, Hash};

use indexmap::{map::Entry::Occupied, IndexMap};
use num_traits::Zero;
use rustc_hash::FxHasher;

type FxIndexMap<K, V> = IndexMap<K, V, BuildHasherDefault<FxHasher>>;

pub fn dijkstra<N, C, FN, IN, FS>(
    start: &N,
    mut successors: FN,
    mut success: FS,
) -> Option<(Vec<N>, C)>
where
    N: Eq + Hash + Clone,
    C: Zero + Ord + Copy,
    FN: FnMut(&N) -> IN,
    IN: IntoIterator<Item = (N, C)>,
    FS: FnMut(&N) -> bool,
{
    dijkstra_internal(start, &mut successors, &mut success)
}

pub(crate) fn dijkstra_internal<N, C, FN, IN, FS>(
    start: &N,
    successors: &mut FN,
    success: &mut FS,
) -> Option<(Vec<N>, C)>
where
    N: Eq + Hash + Clone,
    C: Zero + Ord + Copy,
    FN: FnMut(&N) -> IN,
    IN: IntoIterator<Item = (N, C)>,
    FS: FnMut(&N) -> bool,
{
    let (parents, reached) = run_dijkstra(start, successors, success);
    reached.map(|target| {
        (
            reverse_path(&parents, |&(p, _)| p, target),
            parents.get_index(target).unwrap().1 .1,
        )
    })
}

fn run_dijkstra<N, C, FN, IN, FS>(
    start: &N,
    successors: &mut FN,
    stop: &mut FS,
) -> (FxIndexMap<N, (usize, C)>, Option<usize>)
where
    N: Eq + Hash + Clone,
    C: Zero + Ord + Copy,
    FN: FnMut(&N) -> IN,
    IN: IntoIterator<Item = (N, C)>,
    FS: FnMut(&N) -> bool,
{
    let mut to_see = BinaryHeap::new();
    to_see.push(SmallestHolder {
        cost: Zero::zero(),
        index: 0,
    });
    let mut parents: FxIndexMap<N, (usize, C)> = FxIndexMap::default();
    parents.insert(start.clone(), (usize::MAX, Zero::zero()));
    let mut target_reached = None;
    while let Some(SmallestHolder { cost, index }) = to_see.pop() {
        let successors = {
            let (node, &(_, c)) = parents.get_index(index).unwrap();
            if stop(node) {
                target_reached = Some(index);
                break;
            }
            // We may have inserted a node several time into the binary heap if we found
            // a better way to access it. Ensure that we are currently dealing with the
            // best path and discard the others.
            if cost > c {
                continue;
            }
            successors(node)
        };
        for (successor, move_cost) in successors {
            let new_cost = cost + move_cost;
            let n;
            if let Occupied(entry) = parents.entry(successor.clone()) {
                if entry.get().1 > new_cost {
                    n = entry.index();
                    if let Some(swap) = parents.swap_remove_full(&successor) {
                        parents.insert(successor, (index, new_cost));
                        parents.swap_indices(swap.0, parents.len() - 1);
                    }
                } else {
                    continue;
                }
            } else {
                n = parents.len();
                parents.insert(successor, (index, new_cost));
            }

            to_see.push(SmallestHolder {
                cost: new_cost,
                index: n,
            });
        }
    }
    (parents, target_reached)
}

#[allow(clippy::needless_collect)]
fn reverse_path<N, V, F>(parents: &FxIndexMap<N, V>, mut parent: F, start: usize) -> Vec<N>
where
    N: Eq + Hash + Clone,
    F: FnMut(&V) -> usize,
{
    let path = itertools::unfold(start, |i| {
        parents.get_index(*i).map(|(node, value)| {
            *i = parent(value);
            node
        })
    })
    .collect::<Vec<&N>>();
    // Collecting the going through the vector is needed to revert the path because the
    // unfold iterator is not double-ended due to its iterative nature.
    path.into_iter().rev().cloned().collect()
}

struct SmallestHolder<K> {
    cost: K,
    index: usize,
}

impl<K: PartialEq> PartialEq for SmallestHolder<K> {
    fn eq(&self, other: &Self) -> bool {
        self.cost == other.cost
    }
}

impl<K: PartialEq> Eq for SmallestHolder<K> {}

impl<K: Ord> PartialOrd for SmallestHolder<K> {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl<K: Ord> Ord for SmallestHolder<K> {
    fn cmp(&self, other: &Self) -> Ordering {
        other.cost.cmp(&self.cost)
    }
}
