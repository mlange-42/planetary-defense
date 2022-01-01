extends Control
class_name CityProductionInfo


func set_commodity(comm: String):
	$CommLabel.text = comm


func set_values(source: int, produced: int, consumed: int, sink: int):
	$PotProduction.text = str(source)
	$Production.text = str(produced)
	$Consumption.text = str(consumed)
	$PotConsumption.text = str(sink)
	
	if consumed < sink:
		$Consumption.self_modulate = Color.orange
		$PotConsumption.self_modulate = Color.orange
	else:
		$Consumption.self_modulate = Color.white
		$PotConsumption.self_modulate = Color.white
