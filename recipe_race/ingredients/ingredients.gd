extends Node3D

@onready var rand_timer = $RandomTimer
@onready var ingredient_scene = preload("res://recipe_race/ingredients/ingredient.tscn")
@onready var main = get_node("/root/Main")

const TIMER_CONFIG = { "min": 0.5, "max": 0.3, "autostart": true }
const NUM_BOUNDS = { "min": 1, "max": 1 }

func activate():
	rand_timer.connect("on_timeout", on_timeout)
	rand_timer.activate(TIMER_CONFIG)

func on_timeout():
	place_new_ingredients()

func place_new_ingredients():
	check_ingredients(true)

func check_ingredients(place_new : bool = false):
	var ings = get_tree().get_nodes_in_group("Ingredients")
	var num = ings.size()
	while num < NUM_BOUNDS.min:
		place_new_ingredient()
		num += 1
	
	if num >= NUM_BOUNDS.max: return
	
	if place_new: place_new_ingredient()

func place_new_ingredient():
	var ing = ingredient_scene.instantiate()
	
	var rand_pos = main.get_mod("map").get_random_position()
	ing.set_position(rand_pos)
	
	var rand_type = get_random_ingredient_type()
	ing.set_type(rand_type)
	
	ing.connect("removed", on_ingredient_removed)
	
	print("Placing new ingredient")
	
	add_child(ing)

func on_ingredient_removed():
	check_ingredients()

func get_random_ingredient_type():
	var all_types = GDict.ingredients.keys()
	return all_types.pick_random()
