extends Node3D

@onready var body = get_parent()
var content = []

func get_content():
	return content

func get_content_property(prop):
	var arr = []
	for data in content:
		arr.append(data[prop])
	return arr

func can_accept(data):
	if not GDict.cfg.player_has_backpack: return false
	
	if GDict.cfg.backpacks_are_exclusive and not is_empty():
		var types = get_content_property("type")
		if not types.has(data.type): return false
	
	return true

func add(data):
	content.append(data)
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
	
