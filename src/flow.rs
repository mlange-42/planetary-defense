use gdnative::prelude::*;

#[derive(NativeClass)]
#[inherit(Node)]
pub struct NetworkSimplex{}

#[methods]
impl NetworkSimplex {
    fn new(_owner: &Node) -> Self {
        godot_print!("Creating NetworkSimplex");
        Self{}
    }
    
    #[export]
    fn _ready(&mut self, _owner: &Node) {
        godot_print!("hello, world.");
    }
}