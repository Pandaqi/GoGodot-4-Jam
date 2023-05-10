extends Node

var base_cfg = {
	
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
