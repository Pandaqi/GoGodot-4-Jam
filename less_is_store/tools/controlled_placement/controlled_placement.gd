extends Node

var config = {}
@onready var random_timer = $RandomTimer

signal added(elem)
signal removed(elem)
signal refresh

func activate(cfg):
	config = cfg
	
	random_timer.connect("timeout", on_timeout)
	random_timer.activate(config.rand_timer)

func on_timeout():
	check_elements(true)

func get_group():
	return get_tree().get_nodes_in_group(config.group_name)

func check_elements(add : bool = false):
	emit_signal("refresh")
	
	var num = get_group().size()
	var num_bounds = config.num_bounds
	
	print("checking elements")
	print(num_bounds)
	
	while num < num_bounds.min:
		place_element()
		num += 1
	
	var too_many = num >= num_bounds.max
	if too_many: return
	if not add: return
	
	place_element()

func place_element():
	var elem = config.element_scene.instantiate()
	elem.connect("removed", on_element_removed)
	emit_signal("added", elem)

func on_element_removed(elem):
	emit_signal("removed", elem)
	check_elements()

func set_num_bounds(b):
	config.num_bounds = b
