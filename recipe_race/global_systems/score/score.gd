extends Node3D

@onready var main = get_parent()
@onready var auto_timer : Timer = $AutoTimer
const POTION_SCORES = { "min": 10, "max": 1 }
const DIVERSITY_SCORES = { "min": 5, "max": 1 }
const AUTO_SCORE_PER_SECOND = 0.25
var score : float = 0.0

func activate():
	var players = get_tree().get_nodes_in_group("Players")
	for p in players:
		p.get_mod("potion").connect("potion_taken", on_potion_taken)

func update_score(ds):
	score = max(score + ds, 0)
	main.get_mod("ui").update_score(score) #TODO: might want to decouple, handle all this via signals

func on_potion_taken(content):
	var extra_score = calculate_score_from_potion(content)
	update_score(extra_score)

func count_unique_ingredients(arr):
	var obj = {}
	for elem in arr:
		if not obj.has(elem.type): obj[elem.type] = 0
		obj[elem.type] += 1
	return obj.keys().size()

func calculate_score_from_potion(content):
	var num_ingredients = content.size()
	var max_ingredients = GDict.cfg.cauldron_size_bounds.max
	var percentage = num_ingredients / max_ingredients
	var score_from_number = round(lerp(POTION_SCORES.min, POTION_SCORES.max, percentage))
	
	var unique_ingredients = count_unique_ingredients(content)
	var max_different_ingredients = main.get_mod("ingredients").get_available_types().size()
	var diversity_percentage = unique_ingredients / max_different_ingredients
	var score_from_diversity = round(lerp(DIVERSITY_SCORES.min, DIVERSITY_SCORES.max, diversity_percentage))
	
	var final_score = score_from_number + score_from_diversity
	return final_score

func _on_auto_timer_timeout():
	if not GDict.cfg.auto_increase_score: return
	update_score(AUTO_SCORE_PER_SECOND)
