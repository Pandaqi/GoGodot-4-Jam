extends CanvasLayer

@onready var main_node = get_parent()
var feedback_scene : PackedScene = preload("res://less_is_store/feedback/feedback.tscn")

func add_for_node(node, data):
	var pos = node.get_viewport_transform() * node.global_position
	add_at_pos(pos, data)

func add_at_pos(pos, data):
	var fb = feedback_scene.instantiate()
	var text = data.text if data.has("text") else "?"
	fb.get_node("Feedback/Label").set_text(str(text))
	fb.set_position(pos)
	add_child(fb)
