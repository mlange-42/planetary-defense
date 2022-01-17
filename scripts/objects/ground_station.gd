extends Facility
class_name GroundStation

export var animation: String = "TurretAction"

onready var anim_player: AnimationPlayer = $ground_station/AnimationPlayer

func _ready():
	if randf() < 0.5:
		anim_player.play(animation)
	else:
		anim_player.play_backwards(animation)
	
	var anim: Animation = anim_player.get_animation(animation)
	anim.set_loop(true)
	
	anim_player.seek(randf() * anim_player.current_animation_length, true)


func on_ready(planet_data):
	.on_ready(planet_data)


func calc_is_supplied():
	.calc_is_supplied()
	if is_supplied:
		if not anim_player.is_playing():
			if randf() < 0.5:
				anim_player.play(animation)
			else:
				anim_player.play_backwards(animation)
	else:
		if anim_player.is_playing():
			anim_player.stop(false)
