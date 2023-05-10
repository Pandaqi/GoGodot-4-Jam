extends Node3D

@onready var rand_timer = $RandomTimer
@onready var ai_timer = $TimerAI
@onready var ingredient_scene = preload("res://recipe_race/ingredients/ingredient.tscn")
@onready var main_node = get_node("/root/Main")

const TIMER_CONFIG = { "min": 1.0, "max": 5.0, "autostart": true }
const TIMER_AI_CONFIG = { "min": 0.5, "max": 2.0, "autostart": false }
const AI_PERC_BOUNDS = { "min": 0.0, "max": 0.75 } #NOTE: min value never used right now

const SCORE_BONUS_ING_DESTROY : float = 2.0
const SCORE_PENALTY_ING_ENTER : float = -2.0

const MIN_DIST_WHEN_PLACING : float = 5.0
var available_types : Array = []

func activate():
	determine_available_types()
	
	rand_timer.connect("on_timeout", on_timeout)
	rand_timer.activate(TIMER_CONFIG)
	
	ai_timer.connect("on_timeout", on_ai_timeout)
	ai_timer.activate(TIMER_AI_CONFIG)
	
	main_node.get_mod("progression").connect("state_changed", on_state_changed)

func determine_available_types():
	var all_types = GDict.ingredients.keys()
	var arr = []
	for type in all_types:
		if GDict.ingredients[type].has("unpickable"): continue
		arr.append(type)
	available_types = arr

func get_available_types():
	return available_types

func on_timeout():
	place_new_ingredients()

func place_new_ingredients():
	check_ingredients(true)

func check_ingredients(place_new : bool = false):
	var ings = get_tree().get_nodes_in_group("Ingredients")
	var num = ings.size()
	var bounds = GDict.cfg.num_ingredient_bounds
	while num < bounds.min:
		place_new_ingredient()
		num += 1
	
	if num >= bounds.max: return
	
	if place_new: place_new_ingredient()

func place_new_ingredient():
	var ing = ingredient_scene.instantiate()
	
	var nodes_to_avoid = get_tree().get_nodes_in_group("Cauldrons") + get_tree().get_nodes_in_group("Players")
	var query_params = {
		"avoid": nodes_to_avoid,
		"radius": MIN_DIST_WHEN_PLACING 
	}
	var map = main_node.get_mod("map")
	var rand_pos = map.get_random_valid_position(query_params)
	ing.set_position(rand_pos)
	
	add_child(ing)
	
	var rand_type = get_random_ingredient_type()
	ing.set_type(rand_type)
	
	ing.connect("removed", on_ingredient_removed)
	main_node.get_mod("progression").connect("state_changed", ing.on_state_changed)
	
	print("Placing new ingredient")

func on_ingredient_removed(reason):
	check_ingredients()
	
	if GDict.cfg.score_bonus_for_destroying_ingredient and reason == "player":
		main_node.get_mod("score").update_score(SCORE_BONUS_ING_DESTROY)
	
	if GDict.cfg.score_penalty_for_entering_cauldron and reason == "cauldron":
		main_node.get_mod("score").update_score(SCORE_PENALTY_ING_ENTER)

func get_random_ingredient_type():
	return available_types.pick_random()

func get_all_ingredients():
	return get_tree().get_nodes_in_group("Ingredients")

func get_non_ai_ingredients():
	var ings = get_all_ingredients()
	var arr = []
	for ing in ings:
		if ing.get_mod("ai").is_active(): continue
		if not ing.is_active(): continue
		arr.append(ing)
	return arr

func on_ai_timeout():
	print("Wanna turn AI")
	
	var all_ings = get_all_ingredients()
	if all_ings.size() <= 0: return
	
	var valid_ings = get_non_ai_ingredients()
	if valid_ings.size() <= 0: return
	
	var percentage_ai = 1.0 - (float(valid_ings.size()) / float(all_ings.size()))
	if percentage_ai > AI_PERC_BOUNDS.max: return
	
	print("Turning AI")
	
	var ing = valid_ings.pick_random()
	ing.get_mod("ai").set_active(true)

func on_state_changed():
	check_ingredients()
