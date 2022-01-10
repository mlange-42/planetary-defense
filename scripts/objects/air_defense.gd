extends Defense
class_name AirDefense

export var animation: String = "TurretAction"

var radius: int

onready var warning = $Error
onready var range_indicator: RangeIndicator = $RangeIndicator
onready var anim_player: AnimationPlayer = $air_defense/AnimationPlayer

func _ready():
	intercepts = {
		AirAttack: 0.75,
	}
	
	radius = Facilities.FACILITY_RADIUS[type]
	
	if randf() < 0.5:
		anim_player.play(animation)
	else:
		anim_player.play_backwards(animation)
	
	var anim: Animation = anim_player.get_animation(animation)
	anim.set_loop(true)
	
	anim_player.seek(randf() * anim_player.current_animation_length, true)


func on_ready(planet_data):
	var temp_cells = planet_data.get_in_radius(node_id, radius)
	for c in temp_cells:
		cells[c[0]] = c[1]
	
	_draw_cells(planet_data)
	calc_is_supplied()


func calc_is_supplied():
	.calc_is_supplied()
	warning.set_shown(not is_supplied)
	
	if is_supplied:
		range_indicator.material_override = Materials.RANGE_DEFENSE
		if not anim_player.is_playing():
			if randf() < 0.5:
				anim_player.play(animation)
			else:
				anim_player.play_backwards(animation)
	else:
		range_indicator.material_override = Materials.RANGE_DEFENSE_UNSUPPLIED
		if anim_player.is_playing():
			anim_player.stop(false)


func can_build(planet_data, node) -> bool:
	return not planet_data.get_node(node).is_water


func _draw_cells(planet_data): 
	range_indicator.draw_range(planet_data, node_id, cells, radius, Color.magenta)
