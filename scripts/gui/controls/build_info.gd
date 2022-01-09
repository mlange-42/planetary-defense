extends Control
class_name BuildInfo


onready var type_label: Label = find_node("TypeLabel")
onready var cost_label: Label = find_node("CostLabel")
onready var maintenance_label: Label = find_node("MaintenanceLabel")
onready var sinks: Container = find_node("SinksContainer")

var infos: Dictionary = {}


func _ready():
	for comm in Commodities.COMM_ALL:
		var info = CommodityStatsSimple.new(comm, 0)
		info.rect_min_size = Vector2(70, 0)
		sinks.add_child(info)
		infos[comm] = info


func update_info_facility(facility: String):
	type_label.text = facility
	cost_label.text = "%3d" % Facilities.FACILITY_COSTS[facility]
	maintenance_label.text = "%2d" % Facilities.FACILITY_MAINTENANCE[facility]
	
	for comm in infos:
		infos[comm].visible = false
	
	var s = Facilities.FACILITY_SINKS[facility]
	if s != null:
		for sink in s:
			var info = infos[sink[0]]
			info.set_amount(sink[1])
			info.visible = true


func update_info_road(type: int, length: int):
	type_label.text = "%s (%d)" % [Roads.ROAD_NAMES[type], length]
	var cost = Roads.ROAD_COSTS[type] * length
	var maint = Roads.ROAD_MAINTENANCE_1000[type] * length / 1000.0
	
	cost_label.text = "%3d" % cost
	maintenance_label.text = "%s" % maint
	
	for comm in infos:
		infos[comm].visible = false
