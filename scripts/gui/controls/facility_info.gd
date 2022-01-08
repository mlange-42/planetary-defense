extends Control
class_name FacilityInfo

onready var label: Label = find_node("FacilityLabel")
onready var container: Container = find_node("Entries")
onready var food: CommodityStats = find_node("Food")
onready var resources: CommodityStats = find_node("Resources")
onready var products: CommodityStats = find_node("Products")

var infos: Dictionary

func _ready():
	infos = {
		Commodities.COMM_FOOD: food,
		Commodities.COMM_RESOURCES: resources,
		Commodities.COMM_PRODUCTS: products,
	}

func update_info(facility):
	if facility == null:
		label.text = "Nothing here"
		container.visible = false
		return
	
	if not facility is City:
		label.text = facility.type
		container.visible = false
		return
	
	var city = facility as City
	label.text = "%s (%d/%d workers)" % [city.name, city.workers(), city.population()]
	
	container.visible = true
	
	for comm in Commodities.COMM_ALL:
		var flows = city.flows.get(comm, [0, 0])
		var pot_source = 0
		for key in city.conversions:
			if key[1] == comm:
				var conv = city.conversions[key]
				pot_source += city.sinks.get(key[0], 0) * conv[1] / conv[0]
		
		infos[comm].set_values(city.sources.get(comm, 0) + pot_source, flows[0], flows[1], city.sinks.get(comm, 0))
