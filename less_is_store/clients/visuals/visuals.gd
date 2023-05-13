extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var body = get_parent()

func on_type_changed(new_type : Enums.Client):
	var spritesheet = GDict.clients[new_type].spritesheet
	var tex_key = "res://less_is_store/clients/spritesheets/client_" + spritesheet + ".webp"
	sprite.set_texture(load(tex_key))

func _physics_process(_dt):
	sprite.flip_h = body.velocity.x < 0
