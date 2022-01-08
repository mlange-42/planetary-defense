extends Control
class_name LandUseInfo

onready var land_use_label: Label = find_node("LandUse")
onready var resources_label: Label = find_node("Resources")
onready var container: Container = find_node("Entries")

func _ready():
	container.add_child(LandUseEntry.new(LandUse.LU_FOREST, Commodities.COMM_RESOURCES, 2))

func update_info(planet: Planet, consts: LandUse, node: int):
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	
	if node < 0:
		land_use_label.text = "Space"
		resources_label.text = ""
		return
	
	var veg = planet.planet_data.get_node(node).vegetation_type
	var res_here = planet.resources.resources.get(node, null)
	
	land_use_label.text = LandUse.VEG_NAMES[veg]
	
	if res_here == null:
		resources_label.text = ""
	else:
		resources_label.text = "%s (%s)" % [Resources.RES_NAMES[res_here[0]], res_here[1]]
	
	for lut in consts.LU_MAPPING:
		var lu: Dictionary = consts.LU_MAPPING[lut]
		if veg in lu:
			if lu[veg] == null:
				continue
			var prod: LandUse.VegLandUse = lu[veg]
			var child = null
			if prod.source == null:
				child = LandUseEntry.new(lut, "", 0)
			else:
				child = LandUseEntry.new(lut, prod.source.commodity, prod.source.amount)
			
			container.add_child(child)
	
	if res_here != null:
		var res_id = res_here[0]
		for lut in consts.LU_RESOURCES:
			var res: Dictionary = consts.LU_RESOURCES[lut]
			var lu: Dictionary = consts.LU_MAPPING[lut]
			if res.has(res_here[0]) and lu.has(veg):
				var prod: LandUse.VegLandUse = res[res_id]
				var child = null
				
				if prod.source == null:
					child = LandUseEntry.new(lut, "", 0)
				else:
					child = LandUseEntry.new(lut, prod.source.commodity, prod.source.amount)
				
				container.add_child(child)