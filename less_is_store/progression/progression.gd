extends CanvasLayer

@onready var main_node = get_parent()

var stage : int = -1
var active : bool = false
var at_max_stage : bool = false
const IMAGE_DIR : String = "res://less_is_store/progression/stage_images/stage_"

var game_over : bool = false
var we_won : bool = false
const WIN_IMAGE = "win"
const LOSS_IMAGE = "loss"

const DEBUG_DURATION_SCALE : float = 1.0 #DEBUGGING; should be 1
const DEBUG_NO_IMAGES : bool = false #DEBUGGING; should be false
const DEBUG_GAME_OVER : bool = false #DEBUGGING; should be false

@onready var tut_img : TextureRect = $Control/MarginContainer/Tutorial
@onready var timer : Timer = $Timer
@onready var anim_player : AnimationPlayer = $AnimationPlayer

const STAGE_CHANGE_AUDIO = preload("res://less_is_store/progression/sounds/stage_change.ogg")
const WIN_AUDIO = preload("res://less_is_store/progression/sounds/game_win.ogg")
const LOSS_AUDIO = preload("res://less_is_store/progression/sounds/game_loss.ogg")
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

signal state_changed

var clock : int = 0
@onready var clock_timer : Timer = $ClockTimer
@onready var time_played_label : Label = $Control/MarginContainer/MarginContainer/Label

func activate():
	prepare_cfg()
	
	main_node.get_mod("score").connect("score_changed", on_score_changed)
	main_node.get_mod("map").connect("cell_changed", on_cell_changed)
	
	time_played_label.hide()

func prepare_cfg():
	var cfg = {}
	for key in GDict.base_cfg:
		cfg[key] = GDict.base_cfg[key]
	GDict.cfg = cfg

func on_score_changed(_new_score):
	check_game_over()

func on_cell_changed(_new_cell):
	check_game_over()

func check_game_over():
	var map = main_node.get_mod("map")
	if not map.generation_is_done(): return
	
	var no_buyables = map.get_cells_of_type(Enums.CellType.BUYABLE).size() <= 0
	if no_buyables: goto_game_over(true)
	
	var score_too_high = main_node.get_mod("score").too_high()
	if score_too_high: goto_game_over(false)

func goto_game_over(won : bool = false):
	game_over = true
	we_won = won
	
	var stream = WIN_AUDIO
	if not we_won: stream = LOSS_AUDIO
	audio_player.stream = stream
	audio_player.play()
	
	time_played_label.show()
	time_played_label.set_text(get_time_played())
	
	execute_stage_change()

func execute_stage_change():
	set_stage_image()
	add_stage_properties_to_cfg()
	enable()
	if DEBUG_NO_IMAGES: disable()
	anim_player.play("appear")
	emit_signal("state_changed")

func load_next_stage():
	if at_max_stage: return
	stage += 1
	at_max_stage = stage >= (GDict.stages.size() - 1)
	audio_player.stream = STAGE_CHANGE_AUDIO
	audio_player.play()
	execute_stage_change()

func set_stage_image():
	var tex_key = IMAGE_DIR + str(stage + 1) + ".webp"
	if game_over:
		if we_won: tex_key = IMAGE_DIR + WIN_IMAGE + ".webp"
		else: tex_key = IMAGE_DIR + LOSS_IMAGE + ".webp"
	
	var tex = load(tex_key)
	tut_img.set_texture(tex)

func get_stage_data():
	return GDict.stages[stage]

func add_stage_properties_to_cfg():
	var new_cfg = get_stage_data()
	for key in new_cfg:
		GDict.cfg[key] = new_cfg[key]

func enable():
	active = true
	show()
	get_tree().paused = true
	clock_timer.stop()

func disable():
	active = false
	hide()
	get_tree().paused = false
	restart_timer()
	clock_timer.start()

func restart_timer():
	timer.wait_time = get_stage_data().duration * DEBUG_DURATION_SCALE
	timer.start()

func is_busy() -> bool:
	return anim_player.is_playing()

func _input(ev):
	if not active: return
	if is_busy(): return
	
	if DEBUG_GAME_OVER:
		if ev.is_action_released("ui_accept"):
			goto_game_over(true)
			return
	
	if ev.is_action_released("ui_accept"):
		if game_over: return restart()
		anim_player.play_backwards("appear")
		await anim_player.animation_finished
		disable()

func restart():
	get_tree().reload_current_scene()

func _on_timer_timeout():
	load_next_stage()

func get_factor():
	if at_max_stage: return 1.0
	
	var num_stages : int = GDict.stages.size()
	var precise_stage : float = stage + (1.0 - timer.time_left / timer.wait_time)
	var factor = precise_stage / num_stages
	return factor

func get_time_played() -> String:
	var time = float(clock)
	var minutes = floor(time / 60)
	if minutes < 10: minutes = "0" + str(minutes)
	
	var seconds = int(floor(time)) % 60
	if seconds < 10: seconds = "0" + str(seconds)
	
	return str(minutes) + ":" + str(seconds)

func _on_clock_timer_timeout():
	clock += 1
