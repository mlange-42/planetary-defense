extends Control
class_name FacilityInfo

onready var label: Label = find_node("FacilityLabel")
onready var container: Container = find_node("Entries")
onready var food: CommodityStats = find_node("Food")
onready var resources: CommodityStats = find_node("Resources")
onready var products: CommodityStats = find_node("Products")
onready var electricity: CommodityStats = find_node("Electricity")

onready var city_stats: Container = find_node("CityStats")
onready var city_workers: Label = find_node("WorkersLabel")
onready var city_growth: Label = find_node("GrowthLabel")
onready var city_growth_supply: Label = find_node("SupplyFactorLabel")
onready var city_growth_space: Label = find_node("SpaceFactorLabel")
onready var city_growth_employment: Label = find_node("EmploymentFactorLabel")

var infos: Dictionary

func _ready():
	infos = {
		Commodities.COMM_FOOD: food,
		Commodities.COMM_RESOURCES: resources,
		Commodities.COMM_PRODUCTS: products,
		Commodities.COMM_ELECTRICITY: electricity,
	}

func update_info(facility):
	if facility == null:
		label.text = "Nothing here"
		container.visible = false
		city_stats.visible = false
		return
	
	if facility is City:
		var city = facility as City
		label.text = city.name
		city_workers.text = "%d/%d" % [city.workers(), city.population()]
		city_growth.text = "%d%%" % city.growth_stats.total
		city_growth_supply.text = "%d%%" % city.growth_stats.supply_factor
		city_growth_space.text = "%d%%" % city.growth_stats.space_factor
		city_growth_employment.text = "%d%%" % city.growth_stats.employment_factor
		city_stats.visible = true
	else:
		label.text = facility.type
		city_stats.visible = false
	
	container.visible = true
	
	for comm in Commodities.COMM_ALL:
		var flows = facility.flows.get(comm, [0, 0])
		var pot_source = 0
		for key in facility.conversions:
			if key[1] == comm:
				var conv = facility.conversions[key]
				pot_source += facility.sinks.get(key[0], 0) * conv[1] / conv[0]
		
		infos[comm].set_values(facility.sources.get(comm, 0) + pot_source, flows[0], flows[1], facility.sinks.get(comm, 0))
