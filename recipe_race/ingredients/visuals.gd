extends Node3D

@onready var body = get_parent()
@onready var anim_player = $AnimationPlayer
@onready var mesh_container = $MeshContainer

var model = null

func _ready():
	body.connect("type_changed", on_type_changed)

func play_idle():
	play_animation("idle")

func play_animation(key):
	anim_player.play(key)

func on_type_changed(tp):
	print("TYPE CHANGED")
	print(tp)
	
	if model != null:
		model.queue_free()
	
	var model_key = "res://recipe_race/ingredients/models/" + tp + ".tscn"
	var mesh = load(model_key).instantiate()
	mesh_container.add_child(mesh)
	model = mesh
