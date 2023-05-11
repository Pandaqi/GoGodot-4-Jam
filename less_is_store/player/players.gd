extends Node2D

@onready var main_node = get_parent()
var player_scene : PackedScene = preload("res://less_is_store/player/player.tscn")

func activate():
	place_players()

func place_players():
	var num_players = 1
	for i in range(num_players):
		place_player(i)

func place_player(idx : int):
	var p = player_scene.instantiate()
	var map = main_node.get_mod("map")
	var start_cell = map.get_cells_of_type(Enums.CellType.EMPTY).pick_random()
	p.set_position(start_cell.visual.get_position())
	
	map.layers.overlay.add_child(p)
	p.get_mod("mover").connect("dash_changed", main_node.get_mod("ui").on_dash_changed)
