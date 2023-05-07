extends CanvasLayer

@onready var main_node = get_parent()

@onready var input_bar_container : Node2D = $InputBarContainer
@onready var input_bar : TextureProgressBar = $InputBarContainer/InputBar

@onready var score_container : Node2D = $ScoreContainer
@onready var score_label : Label = $ScoreContainer/Label

const INPUT_BAR_SIZE = 96

func activate():
	get_tree().get_root().connect("size_changed", on_viewport_changed)
	on_viewport_changed()
	
	main_node.get_mod("progression").connect("state_changed", on_state_changed)

func on_state_changed():
	input_bar_container.set_visible(GDict.cfg.turning_changes_size)

func on_viewport_changed():
	var vp = get_viewport().size
	
	var top_margin = 0.5 * input_bar_container.scale.x * INPUT_BAR_SIZE
	input_bar_container.set_position(Vector2(0.5*vp.x, top_margin))

func update_input_bar(val : float):
	input_bar.set_value(val)

func update_score(val : float):
	var pretty_val = str(round(val))
	score_label.set_text(pretty_val)
