extends GuiState
class_name EditCityState

var city_node: int

func init(the_fsm, args):
	.init(the_fsm, args)
	city_node = args["node"]

func _on_Back_pressed():
	fsm.pop()

func on_planet_clicked(_planet: Planet, _node: int, button: int):
	if button == BUTTON_LEFT:
		pass
