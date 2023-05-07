extends Node3D

@onready var body = get_parent()
@onready var timer : Timer = $Timer

const TIMER_BOUNDS = { "min": 0.5, "max": 3.0 }
const MIN_DIST_WHEN_REAPPEAR : float = 4.0
var disappear_offset : Vector3 = Vector3.DOWN*20
var hidden : bool = false

func _ready():
	body.connect("ingredient_added", on_ingredient_added)

func on_ingredient_added(data):
	if not GDict.cfg.cauldron_moves_after_change: return
	if hidden: return
	disappear()

func appear():
	hidden = false
	
	var avoid_list = get_tree().get_nodes_in_group("Cauldrons") + get_tree().get_nodes_in_group("Players") + get_tree().get_nodes_in_group("Ingredients")
	var query_params = {
		"avoid": avoid_list,
		"radius": MIN_DIST_WHEN_REAPPEAR
	}
	var map_module = body.get_main_node().get_mod("map")
	var rand_pos = map_module.get_random_valid_position(query_params)
	body.set_position(rand_pos)
	
	body.get_mod("visuals").appear()

func disappear():
	hidden = true
	body.set_position(body.get_position() + disappear_offset)
	timer.wait_time = randf_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()
	
	body.get_mod("visuals").disappear()
	
	print("SHOULD DISAPPEAR")

func _on_timer_timeout():
	appear()
