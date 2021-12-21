extern crate gdnative;

mod flow;

pub use flow::path::MultiCommodityFlow;

use gdnative::prelude::*;

fn init(handle: InitHandle) {
    handle.add_class::<MultiCommodityFlow>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
