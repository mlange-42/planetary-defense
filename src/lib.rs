extern crate gdnative;

mod flow;
mod geom;

pub use flow::path::MultiCommodityFlow;
pub use geom::ico_sphere::IcoSphere;

use gdnative::prelude::*;

fn init(handle: InitHandle) {
    handle.add_class::<MultiCommodityFlow>();
    handle.add_class::<IcoSphere>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
