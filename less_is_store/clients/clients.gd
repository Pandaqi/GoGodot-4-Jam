extends Node2D

@onready var main_node = get_parent()
var PLACE_CONFIG = {
	"element_scene": preload("res://less_is_store/clients/client.tscn"),
	"group_name": "Clients",
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
	controlled_placement.set_num_bounds(GDict.cfg.num_clients)
	controlled_placement.check_elements()

func on_added(client):
	var map = main_node.get_mod("map")
	
	var cell = map.get_entrance()
	client.set_position(cell.visual.get_position())
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
	main_node.get_mod("feedback").add_for_node(client, { "text": str(score) + " products!", "mood": "bad" })
	main_node.get_mod("score").change(score)

