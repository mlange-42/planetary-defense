#[macro_use]
extern crate lazy_static;
extern crate gdnative;

mod flow;
mod geom;
mod network;

use std::hash::BuildHasherDefault;

use gdnative::prelude::*;
use indexmap::IndexMap;
use rustc_hash::FxHasher;

pub use flow::path::MultiCommodityFlow;
pub use geom::ico_sphere::IcoSphere;
pub use geom::planet::data::NodeData;
pub use geom::planet::data::PlanetData;
pub use geom::planet::generator::PlanetGenerator;
pub use network::Edge;
pub use network::FlowNetwork;

type FxIndexMap<K, V> = IndexMap<K, V, BuildHasherDefault<FxHasher>>;

fn init(handle: InitHandle) {
    handle.add_class::<MultiCommodityFlow>();
    handle.add_class::<FlowNetwork>();
    handle.add_class::<Edge>();
    handle.add_class::<IcoSphere>();
    handle.add_class::<PlanetData>();
    handle.add_class::<NodeData>();
    handle.add_class::<PlanetGenerator>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
