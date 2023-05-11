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

func on_added(po):
	var map = main_node.get_mod("map")
	
	var cell = map.get_cells_of_type(Enums.CellType.EMPTY).pick_random()
	po.set_position(cell.visual.get_position())
	
	map.layers.overlay.call_deferred("add_child", po)
