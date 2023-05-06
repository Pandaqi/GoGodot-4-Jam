extends Node3D

@onready var modules = {
	"map": $Map,
	"ingredients": $Ingredients,
	"global_systems": $GlobalSystems
}

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on Main node")
	return null

func _ready():
	modules.map.activate()
	modules.ingredients.activate()
	modules.global_systems.activate()
