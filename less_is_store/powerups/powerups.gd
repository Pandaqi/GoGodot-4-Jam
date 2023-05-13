extends Node2D

@onready var main_node = get_parent()
var PLACE_CONFIG = {
	"element_scene": preload("res://less_is_store/powerups/powerup.tscn"),
	"group_name": "Powerups",
	"rand_timer": { "min": 1.0, "max": 4.0, "autostart": true },
	"num_bounds": { "min": 0, "max": 0 }
}

@onready var controlled_placement = $ControlledPlacement

func activate():
	controlled_placement.connect("added", on_added)
	controlled_placement.activate(PLACE_CONFIG)
	
	main_node.get_mod("progression").connect("state_changed", on_state_changed)
	on_state_changed()

func on_state_changed():
	refresh()

func refresh():
	controlled_placement.set_num_bounds(GDict.cfg.num_powerups)
	controlled_placement.check_elements()

func get_map():
	return main_node.get_mod("map")

func dist_to_closest(pos : Vector2, list : Array):
	var closest_dist = INF
	for node in list:
		var dist = (node.global_position - pos).length()
		closest_dist = min(dist, closest_dist)
	return closest_dist

func get_valid_cell():
	var cell
	var bad_choice : bool = true
	var groups = get_tree().get_nodes_in_group("Powerups") + get_tree().get_nodes_in_group("Players")
	var map = get_map()
	var min_dist_between = map.get_cell_size().length()
	while bad_choice:
		bad_choice = false
		cell = map.get_cells_of_type(Enums.CellType.EMPTY).pick_random()
		var dist = dist_to_closest(cell.visual.global_position, groups)
		if dist <= min_dist_between: bad_choice = true
	return cell

func on_added(po):
	var cell = get_valid_cell()
	var base_pos = cell.visual.get_position()
	po.set_position(base_pos)
	
	get_map().layers.overlay.call_deferred("add_child", po)
