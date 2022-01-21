import sys
import bpy
from mathutils import Vector

def gamma_inverse(color):
    return Vector(tuple([x ** (2.2) for x in color]))

if __name__ == "__main__":
    current_obj = bpy.context.active_object 
    mesh = current_obj.data
    
    if not mesh.vertex_colors:
        mesh.vertex_colors.new()
    
    mesh.update()
    
    for loop_index, loop in enumerate(mesh.loops):
        loop_vert_index = loop.vertex_index
        
        norm = mesh.vertices[loop_vert_index].normal
        tnorm = Vector((norm.x, norm.z, -norm.y))
        color = gamma_inverse((tnorm * 0.5) + Vector((0.5, 0.5, 0.5)))
        color.resize_4d()
        
        mesh.vertex_colors.active.data[loop_index].color = color
    
    mesh.update()
    
    assert bpy.data.is_saved, "File needs to be saved first"
    
    path = bpy.data.filepath[:bpy.data.filepath.rindex(".blend")] + ".escn"
    print("Saving to", path)
    
    addons = bpy.utils.user_resource('SCRIPTS', path="addons")
    print("Addons", addons)
    sys.path.insert(0, addons)
    import io_scene_godot
    
    overrides = {
        "object_types": { "EMPTY", "GEOMETRY" },
        "use_included_in_render": True,
        "animation_modes": "SCENE_ANIMATION",
        "material_mode": "SPATIAL",
        "material_search_paths": "PROJECT_DIR",
        "use_beta_features": False,
        "use_visible_objects": True,
        "use_export_selected": False,
        "use_mesh_modifiers": False,
        "use_export_shape_key": True,
        "use_export_animation": True,
        "use_stashed_action": True,
    }
    io_scene_godot.export(path, overrides)
    
    print("Done")
