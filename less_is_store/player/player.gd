extends CharacterBody2D

@onready var main_node = get_node("/root/Main")
@onready var modules = {
	"mover": $Mover,
	"powerups": $Powerups
}

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on Player node")
	return null

func get_map():
	return main_node.get_mod("map")

func give_feedback(txt:String):
	main_node.get_mod("feedback").add_for_node(self, { "text": txt })
