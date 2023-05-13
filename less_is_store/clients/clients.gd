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

func get_random_type():
	return GDict.cfg.client_types.pick_random()

func on_added(client):
	var map = main_node.get_mod("map")
	
	var cell = map.get_entrance()
	client.set_position(cell.visual.get_position())
	client.connect("score", on_client_scored)
	
	map.layers.overlay.add_child(client)
	client.get_mod("state").set_type(get_random_type())
	client.activate(map)

func get_score_for_item(item : Enums.Item) -> int:
	var sale_signs = main_node.get_mod("map").get_cells_of_type(Enums.CellType.SALE)
	var highest_value = 1
	for sale_sign in sale_signs:
		if sale_sign.get_buyable() != item: continue
		highest_value = max(highest_value, sale_sign.get_num())
	return highest_value

func get_score_for_client(client) -> int:
	var sum = 0
	for elem in client.get_mod("backpack").get_content():
		sum += get_score_for_item(elem.buyable)
	return sum

func on_client_scored(client):
	var score = get_score_for_client(client)
	main_node.get_mod("feedback").add_for_node(client, { "text": str(score) + " coins!", "mood": "bad" })
	main_node.get_mod("score").change(score)

