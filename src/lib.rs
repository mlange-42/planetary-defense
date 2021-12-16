extern crate gdnative;

mod flow;
mod path;

pub use flow::NetworkSimplex;
pub use path::MultiCommodityFlow;

use gdnative::prelude::*;

fn init(handle: InitHandle) {
    handle.add_class::<NetworkSimplex>();
    handle.add_class::<MultiCommodityFlow>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
