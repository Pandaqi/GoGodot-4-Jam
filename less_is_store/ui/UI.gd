extends CanvasLayer

@onready var main_node = get_parent()
@onready var score_label = $Score/Label

func activate():
	main_node.get_mod("score").connect("score_changed", on_score_changed)

func on_score_changed(new_score : int):
	score_label.set_text(str(new_score))
	
