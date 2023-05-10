extends Node2D

@onready var main_node = get_parent()
var client_scene : PackedScene = preload("res://less_is_store/clients/client.tscn")
const NUM_BOUNDS = { "min": 5, "max": 10 }
const RAND_TIMER_CONFIG = { "min": 1.0, "max": 4.0, "autostart": true }
@onready var random_timer = $RandomTimer

func activate():
	random_timer.connect("timeout", on_timeout)
	random_timer.activate(RAND_TIMER_CONFIG)

func place_client():
	var client = client_scene.instantiate()
	var map = main_node.get_mod("map")
	
	var cell = map.get_entrance()
	client.set_position(cell.visual.get_position())
	client.connect("removed", on_client_removed)
	client.connect("score", on_client_scored)
	
	map.layers.overlay.add_child(client)
	client.activate(map)

func get_score_for_client(client) -> int:
	var sum = 0
	for elem in client.get_mod("backpack").get_content():
		sum += 1
	return sum

func on_client_scored(client):
	var score = get_score_for_client(client)
	main_node.get_mod("score").change(score)

func on_client_removed():
	check_clients()

func check_clients(add : bool = false):
	var num = get_tree().get_nodes_in_group("Clients").size()
	while num < NUM_BOUNDS.min:
		place_client()
		num += 1
	
	var too_many = num >= NUM_BOUNDS.max
	if too_many: return
	if not add: return
	
	place_client()

func on_timeout():
	check_clients(true)
