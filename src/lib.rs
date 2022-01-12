#[macro_use]
extern crate lazy_static;
extern crate gdnative;

mod flow;
mod geom;

pub use flow::network::Edge;
pub use flow::network::FlowNetwork;
pub use flow::path::MultiCommodityFlow;
pub use geom::ico_sphere::IcoSphere;
pub use geom::planet::data::NodeData;
pub use geom::planet::data::PlanetData;
pub use geom::planet::generator::PlanetGenerator;

use gdnative::prelude::*;

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
