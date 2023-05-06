extends Node3D

@onready var body = get_parent()
var content = []

func get_content():
	return content

func add(node):
	content.append(node.get_data_representation())
	update_visuals()

func remove_at_index(idx):
	content.remove_at(idx)
	update_visuals()

func empty():
	for i in range(content.size()-1, -1, -1):
		remove_at_index(i)
	content = []

func is_empty():
	return content.size() <= 0

func update_visuals():
	body.get_mod("visuals").update_ui(content)
	
