extends Node2D

signal removed(elem)
var active : bool = false

@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready():
	anim_player.play("appear")
	await anim_player.animation_finished
	active = true
	anim_player.play("idle")

func _on_area_2d_body_entered(body):
	if not active: return
	if not body.is_in_group("Players"): return
	body.get_mod("powerups").receive(get_data_representation())
	remove()

func remove():
	active = false
	anim_player.play_backwards("appear")
	await anim_player.animation_finished
	queue_free()
	emit_signal("removed", self)

func get_data_representation():
	return { "type": "dash" } #TODO: actually different types
