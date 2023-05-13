extends Node2D

@onready var body = get_parent()
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D

func _physics_process(_dt):
	check_speed()

func check_speed():
	var speed = body.get_mod("mover").get_speed()
	
	if speed.length() <= 0.5: 
		anim_player.play("idle")
	else: 
		sprite.flip_h = speed.x < 0
		anim_player.play("run")
