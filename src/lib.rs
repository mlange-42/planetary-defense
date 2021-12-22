extern crate gdnative;

mod flow;
mod geom;

pub use flow::path::MultiCommodityFlow;
pub use geom::ico_sphere::IcoSphere;
pub use geom::planet_generator::PlanetData;
pub use geom::planet_generator::PlanetGenerator;

use gdnative::prelude::*;

fn init(handle: InitHandle) {
    handle.add_class::<MultiCommodityFlow>();
    handle.add_class::<IcoSphere>();
    handle.add_class::<PlanetData>();
    handle.add_class::<PlanetGenerator>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
