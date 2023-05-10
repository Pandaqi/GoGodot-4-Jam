extends CharacterBody2D

@onready var main_node = get_node("/root/Main")
@onready var modules = {
	"mover": $Mover
}

func get_map():
	return main_node.get_mod("map")
