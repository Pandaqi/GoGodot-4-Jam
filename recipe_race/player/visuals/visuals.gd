extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var ingredient_list = $IngredientList

func play_animation(key):
	anim_player.play(key)

func update_ui(content):
	if not GDict.cfg.player_has_backpack:
		ingredient_list.hide()
		return
	ingredient_list.visualize(content)
