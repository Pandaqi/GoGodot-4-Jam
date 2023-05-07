extends Node3D

@onready var modules = {
	"map": $Map,
	"ingredients": $Ingredients,
	"global_systems": $GlobalSystems,
	"ui": $UI,
	"game_over": $GameOver,
	"score": $Score,
	"progression": $Progression,
	"players": $Players
}

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on Main node")
	return null

func _ready():
	modules.progression.activate()
	modules.map.activate()
	modules.players.activate()
	modules.ingredients.activate()
	modules.global_systems.activate()
	modules.game_over.activate()
	modules.score.activate()
	modules.ui.activate()
	
	modules.progression.load_next_stage()
