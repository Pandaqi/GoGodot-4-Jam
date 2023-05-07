extends Node3D

@onready var body = get_parent()
@onready var anim_player = $AnimationPlayer
@onready var ingredient_list = $IngredientList

func play_animation(key):
	anim_player.play(key)

func stop_animation(key):
	if anim_player.current_animation != key: return
	anim_player.stop(true)

func update_ui(content, max_slots):
	ingredient_list.show_slots(max_slots)
	ingredient_list.visualize(content)

func disappear():
	ingredient_list.set_visible(false)

func appear():
	ingredient_list.set_visible(true)
