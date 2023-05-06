extends Node3D

var type : String = "what?"
var active : bool = false

@onready var modules = {
	"visuals": $Visuals,
	"ai": $AI,
	"mover": $Mover
}

signal removed

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on Ingredient node")
	return null

func _ready():
	get_mod("visuals").play_animation("appear")
	await get_mod("visuals").anim_player.animation_finished
	
	active = true
	
	# DEBUGGING; ingredients should turn evil randomly, over time, controlled by Ingredients
	get_mod("ai").set_active(true)

func set_type(t):
	type = t
	#TODO: update visuals

func _on_area_3d_body_entered(body):
	if not active: return
	if not body.is_in_group("Players"): return
	body.get_mod("backpack").add(self)
	remove()

func _on_area_3d_body_exited(body):
	if not body.is_in_group("Players"): return
	pass

func get_data_representation():
	return {
		"type": type
	}

func remove():
	queue_free() #TODO: should play a tween or something
	emit_signal("removed")
