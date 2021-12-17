extern crate gdnative;

mod path;

pub use path::MultiCommodityFlow;

use gdnative::prelude::*;

fn init(handle: InitHandle) {
    handle.add_class::<MultiCommodityFlow>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
