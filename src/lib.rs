extern crate gdnative;

mod flow;
mod path;

pub use flow::NetworkSimplex;

use gdnative::prelude::*;

fn init(handle: InitHandle) {
    handle.add_class::<NetworkSimplex>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
