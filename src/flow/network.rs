use std::collections::btree_map::Entry;
use std::collections::BTreeMap;

#[allow(dead_code)]
struct Edge {
    from: usize,
    to: usize,
    flow: u32,
    capacity: u32,
}

#[allow(dead_code)]
impl Edge {
    fn new(from: usize, to: usize, capacity: u32) -> Self {
        Self {
            from,
            to,
            flow: 0,
            capacity,
        }
    }
}

#[allow(dead_code)]
pub struct FlowNetwork {
    neighbors: BTreeMap<usize, Vec<usize>>,
    edges: BTreeMap<(usize, usize), Edge>,
}

#[allow(dead_code)]
impl FlowNetwork {
    pub fn is_road(&self, v: usize) -> bool {
        self.neighbors.contains_key(&v)
    }

    pub fn points_connected(&self, v1: usize, v2: usize) -> bool {
        self.edges.contains_key(&(v1, v2))
    }

    pub fn connect_points(&mut self, v1: usize, v2: usize, capacity: u32) {
        self.connect(v1, v2, capacity);
        self.connect(v2, v1, capacity);
    }

    pub fn disconnect_points(&mut self, v1: usize, v2: usize) {
        self.disconnect(v1, v2);
        self.disconnect(v2, v1);
    }

    fn connect(&mut self, v1: usize, v2: usize, capacity: u32) {
        match self.neighbors.entry(v1) {
            Entry::Vacant(e) => {
                e.insert(vec![v2]);
            }
            Entry::Occupied(mut e) => {
                assert!(
                    !e.get().contains(&v2),
                    "Points {} and {} are already connected",
                    v1,
                    v2
                );
                e.get_mut().push(v2);
            }
        }
        self.edges.insert((v1, v2), Edge::new(v1, v2, capacity));
    }

    fn disconnect(&mut self, v1: usize, v2: usize) {
        let mut is_empty = false;
        match self.neighbors.entry(v1) {
            Entry::Vacant(_) => panic!("Points {} and {} are not connected", v1, v2,),
            Entry::Occupied(mut e) => {
                let idx = e.get().iter().position(|v| *v == v2);
                assert!(idx.is_some(), "Points {} and {} are not connected", v1, v2);
                e.get_mut().remove(idx.unwrap());
                if e.get().is_empty() {
                    is_empty = true;
                }
            }
        }
        if is_empty {
            assert!(
                self.neighbors.remove(&v1).is_some(),
                "Points {} and {} are not connected",
                v1,
                v2
            );
        }

        assert!(
            self.edges.remove(&(v1, v2)).is_some(),
            "Points {} and {} have no edge to remove",
            v1,
            v2
        );
    }
}
