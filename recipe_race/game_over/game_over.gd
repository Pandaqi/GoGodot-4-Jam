extends CanvasLayer

var win : bool = false
var active : bool = false

func activate():
	hide()
	
	var cauldrons = get_tree().get_nodes_in_group("Cauldrons")
	for c in cauldrons:
		c.connect("overflow", on_loss)

func on_loss():
	print("You lost!")
	win = false
	goto_game_over()

func goto_game_over():
	get_tree().paused = true
	show()
	active = true
	
	# TODO: show some text / buttons, animate, etc

func restart():
	get_tree().reload_current_scene()

func _input(ev):
	if not active: return
	if ev.is_action_released("ui_accept"):
		restart()
