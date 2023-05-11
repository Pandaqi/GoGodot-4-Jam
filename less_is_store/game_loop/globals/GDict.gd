extends Node

var base_cfg = {
	"backpack_size": { "min": 1, "max": 1 },
	
	# these two work best in tandem
	"destroying_tiles_empties_dash": true,
	"min_dash_required_for_destroying": 1
}

var cfg = {}

var cell_types = {
	Enums.CellType.UNKNOWN: {
		"frame": 0,
		"passthrough": true
	},
	
	Enums.CellType.EMPTY: {
		"frame": 0,
		"passthrough": true
	},
	
	Enums.CellType.WALL: {
		"frame": 4,
		"overlay": true,
		"tint_overlay_to_floor": true
	},
	
	Enums.CellType.ENTRANCE: {
		"frame": 1,
		"passthrough": true,
		"overlay": true,
		"overlay_on_floor": true,
		"match_rotation": true,
		"needs_edge": true
	},
	
	Enums.CellType.CHECKOUT: {
		"frame": 2,
		"passthrough": true,
		"overlay": true,
		"overlay_on_floor": true,
		"match_rotation": true,
		"needs_edge": true
	},
	
	Enums.CellType.BUYABLE: {
		"frame": 3,
		"buyable": true,
		"overlay": true
	}
}

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

var stages = [
	# WASD + touch to remove
	{
		"frame": 0,
		"duration": 20,
		"backpack_size": { "min": 1, "max": 1 },
		"num_clients": { "min": 1, "max": 2 },
		"num_powerups": { "min": 0, "max": 0 },
		"max_score": 6,
		"movement_enabled": true,
		"dash_enabled": false,
		"touch_stops_people": true,
		"dash_stops_people": false,
		"dash_reduces_backpack": false,
		"dash_destroys_tiles": false
	},
	
	{
		"frame": 1,
		"duration": 90,
		"backpack_size": { "min": 1, "max": 2 },
		"num_clients": { "min": 2, "max": 4 },
		"num_powerups": { "min": 2, "max": 5 },
		"max_score": 10,
		"dash_enabled": true,
		"touch_stops_people": false,
		"dash_stops_people": true
	},
	
	{
		"frame": 2,
		"duration": 135,
		"backpack_size": { "min": 1, "max": 3 },
		"num_clients": { "min": 3, "max": 7 },
		"num_powerups": { "min": 4, "max": 6 },
		"max_score": 14,
		"dash_stops_people": false,
		"dash_reduces_backpack": true
	},
	
	{
		"frame": 3,
		"duration": 180,
		"backpack_size": { "min": 1, "max": 4 },
		"num_clients": { "min": 5, "max": 10 },
		"num_powerups": { "min": 6, "max": 10 },
		"dash_destroys_tiles": true,
		"max_score": 20
	}
]
