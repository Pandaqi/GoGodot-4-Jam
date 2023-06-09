extends Node2D

@onready var modules = {
	"map": $Map,
	"clients": $Clients,
	"camera": $Camera2D,
	"players": $Players,
	"score": $Score,
	"ui": $UI,
	"progression": $Progression,
	"powerups": $Powerups,
	"feedback": $Feedback
}

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on Main node")
	return null

func _ready():
	modules.progression.activate()
	modules.progression.load_next_stage()
	modules.map.activate()
	modules.clients.activate()
	modules.powerups.activate()
	modules.camera.activate()
	modules.players.activate()
	modules.ui.activate()
	modules.score.activate()
	
	
