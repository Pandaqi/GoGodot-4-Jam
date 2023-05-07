extends Node

var base_cfg = {
	"cauldron_size_bounds": { "min": 1, "max": 6 },
	"num_ingredient_bounds": { "min": 3, "max": 5 },
	"player_auto_moves": true,
	"backpacks_are_exclusive": true,
	"handle_unaccepted_ingredients": "destroy", # destroy, repel, makeai, skip
	"cauldrons_need_to_cook": true,
	"cauldron_moves_after_change": true,
	"turning_changes_size": true,
	"player_has_backpack": true,
	"player_can_drink_potion": true,
	"auto_increase_score": false,
	"score_bonus_for_destroying_ingredient": false,
	"score_penalty_for_entering_cauldron": false
}

var cfg = {}

var ingredients = {
	"empty_slot": {
		"frame": 0,
		"unpickable": true
	},
	
	"tomato": {
		"frame": 1
	},
	
	"carrot": {
		"frame": 2
	},
	
	"blueberry": {
		"frame": 3
	}
}

# TODO: we either need to add cooking or appearing/disappearing from stage 4 onwards
var stages = [
	# stage 1
	{
		"duration": 30.0,
		"turning_changes_size": false,
		"player_has_backpack": false,
		"cauldrons_need_to_cook": false,
		"cauldron_moves_after_change": false,
		"cauldron_size_bounds": { "min": 3, "max": 3 },
		"num_ingredient_bounds": { "min": 1, "max": 3 },
		"auto_increase_score": true,
		"score_bonus_for_destroying_ingredient": true,
		"score_penalty_for_entering_cauldron": true
	},
	
	# stage 2
	{
		"duration": 60.0,
		"turning_changes_size": true,
		"cauldron_size_bounds": { "min": 1, "max": 6 },
		"num_ingredient_bounds": { "min": 4, "max": 7 }
	},
	
	# stage 3
	{
		"duration": 120.0,
		"player_can_drink_potion": true,
		"num_ingredient_bounds": { "min": 6, "max": 10 },
		"auto_increase_score": false,
		"score_bonus_for_destroying_ingredient": false,
		"score_penalty_for_entering_cauldron": false
	},
	
	# stage 4
	{
		"duration": 240.0,
		"player_has_backpack": true,
		"num_ingredient_bounds": { "min": 7, "max": 13 },
		"cauldron_moves_after_change": true
	}
]
