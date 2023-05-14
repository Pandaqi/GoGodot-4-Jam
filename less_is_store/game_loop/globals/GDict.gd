extends Node

var base_cfg = {
	"backpack_size": { "min": 1, "max": 1 },
	
	"destroying_tiles_empties_dash": true,
	"max_cell_hits_per_dash": 1,
	"min_dash_required_for_destroying": 0
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
		"show_item": true,
		"overlay": true,
		"destroyable": true
	},
	
	Enums.CellType.SALE: {
		"frame": 5,
		"overlay": true,
		"show_item": true,
		"number": true,
		"destroyable": true
	}
}

var ingredients = {
	Enums.Item.EMPTY_SLOT: {
		"frame": 0,
		"unpickable": true
	},
	
	Enums.Item.TOMATO: {
		"frame": 1
	},
	
	Enums.Item.CARROT: {
		"frame": 2
	},
	
	Enums.Item.BLUEBERRY: {
		"frame": 3
	},
	
	Enums.Item.PEAR: {
		"frame": 4
	},
	
	Enums.Item.BEETROOT: {
		"frame": 5
	}
}

var clients = {
	# nothing special
	Enums.Client.BASIC: {
		"spritesheet": "basic",
		"max_allowed": INF
	},
	
	# tiny backpack + huge speed
	Enums.Client.KID: {
		"spritesheet": "kid",
		"backpack_size": { "min": 1, "max": 1 },
		"speed_factor": 1.66,
		"max_allowed": 6
	},
	
	# leaves without paying
	Enums.Client.THIEF: {
		"spritesheet": "thief",
		"leave_without_paying": true,
		"backpack_size": { "min": 1, "max": 2 },
		"max_allowed": 2
	},
	
	# very slow walking
	Enums.Client.ELDERLY: {
		"spritesheet": "elderly",
		"speed_factor": 0.45,
		"anim_speed": 0.5,
		"max_allowed": 3
	}
}

var stages = [
	
	# WASD + touch to remove
	{
		"duration": 17,
		"backpack_size": { "min": 1, "max": 1 },
		"num_clients": { "min": 1, "max": 2 },
		"num_powerups": { "min": 0, "max": 0 },
		"client_types": [Enums.Client.BASIC],
		"num_sales": 0,
		"max_score": 5,
		"movement_enabled": true,
		"dash_enabled": false,
		"touch_stops_people": true,
		"dash_stops_people": false,
		"dash_reduces_backpack": false,
		"dash_destroys_tiles": false
	},
	
	# collect dash powerups + dash to remove
	{
		"duration": 45,
		"backpack_size": { "min": 1, "max": 2 },
		"num_clients": { "min": 2, "max": 4 },
		"num_powerups": { "min": 2, "max": 5 },
		"client_types": [Enums.Client.BASIC, Enums.Client.ELDERLY, Enums.Client.KID],
		"max_score": 7,
		"dash_enabled": true,
		"touch_stops_people": false,
		"dash_stops_people": true,
		"num_sales": 1
	},
	
	# dash destroys tiles
	{
		"duration": 45,
		"backpack_size": { "min": 1, "max": 3 },
		"num_clients": { "min": 3, "max": 6 },
		"num_powerups": { "min": 4, "max": 6 },
		"client_types": [Enums.Client.BASIC, Enums.Client.ELDERLY, Enums.Client.KID],
		"max_score": 10,
		"dash_destroys_tiles": true,
	},
	
	# adds the THIEF character
	{
		"duration": 45,
		"num_clients": { "min": 4, "max": 7 },
		"num_powerups": { "min": 5, "max": 8 },
		"client_types": [Enums.Client.BASIC, Enums.Client.ELDERLY, Enums.Client.KID, Enums.Client.THIEF],
		"max_score": 13,
		"num_sales": 2
	},
	
	# dash merely lowers backpack size
	{
		"duration": 45,
		"backpack_size": { "min": 1, "max": 4 },
		"num_clients": { "min": 5, "max": 9 },
		"num_powerups": { "min": 6, "max": 10 },
		"max_score": 16,
		"dash_stops_people": false,
		"dash_reduces_backpack": true,
	},
	
	
]
