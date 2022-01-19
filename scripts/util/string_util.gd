class_name StrUtil

static func bb_name(facility: Facility) -> String:
	return "[url=%s]%s[/url]" % [facility.node_id, \
			facility.name if facility is City else facility.type]

static func bb_link(text: String, node: int) -> String:
	return "[url=%s]%s[/url]" % [node, text]
