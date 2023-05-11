extends CanvasLayer

@onready var main_node = get_parent()
@onready var score_bar = $Score/MarginContainer/TextureProgressBar
@onready var dash_bar_container = $Dash
@onready var dash_bar = $Dash/MarginContainer/TextureProgressBar

func activate():
	main_node.get_mod("score").connect("score_changed", on_score_changed)
	main_node.get_mod("progression").connect("state_changed", on_state_changed)
	on_state_changed()

func on_state_changed():
	var max_score = GDict.cfg.max_score
	score_bar.max_value = max_score
	
	var powerups_can_appear = GDict.cfg.num_powerups.max > 0
	dash_bar_container.set_visible(powerups_can_appear)

func on_score_changed(new_score : int):
	score_bar.set_value(new_score)

func on_dash_changed(new_dash : int):
	dash_bar.set_value(new_dash)
