extends Node3D

@onready var anim_player = $AnimationPlayer

func play_animation(key):
	anim_player.play(key)
