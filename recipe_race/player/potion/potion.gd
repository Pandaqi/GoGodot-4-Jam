extends Node3D

signal potion_taken(content)

func apply_from_cauldron(content):
	#TODO
	emit_signal("potion_taken", content)
