class_name MessageManager

class Message:
	var node: int
	var text: String
	var message_type: int
	
	func _init(n: int, t: String, type: int):
		node = n
		text = t
		message_type = type
	
	func has_location():
		return node >= 0

var messages: Array = []

func add_message(node: int, text: String, type: int):
	messages.append(Message.new(node, text, type))

func clear_messages():
	messages.clear()

func save() -> Dictionary:
	var msg = []
	for m in messages:
		msg.append([m.node, m.text, m.message_type])
	
	return {"messages": msg}

func read(dict: Dictionary):
	var msg = dict["messages"]
	for m in msg:
		add_message(m[0] as int, m[1], m[2] as int)
