extends CanvasLayer

var stage : int = -1
var active : bool = false
var at_max_stage : bool = false

const DEBUG_DURATION_SCALE : float = 0.33 #DEBUGGING
const DEBUG_NO_IMAGES : bool = false

@onready var tut_img : TextureRect = $Control/Tutorial
@onready var timer : Timer = $Timer

signal state_changed

func activate():
	prepare_cfg()

func prepare_cfg():
	var cfg = {}
	for key in GDict.base_cfg:
		cfg[key] = GDict.base_cfg[key]
	GDict.cfg = cfg

func load_next_stage():
	if at_max_stage: return
	
	stage += 1
	at_max_stage = stage >= (GDict.stages.size() - 1)
	
	set_stage_image()
	add_stage_properties_to_cfg()
	enable()
	emit_signal("state_changed")
	
	if DEBUG_NO_IMAGES: disable()

func set_stage_image():
	var tex_key = "res://recipe_race/progression/stage_images/tutorial_stage_" + str(stage + 1) + ".webp"
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

func disable():
	active = false
	hide()
	get_tree().paused = false
	restart_timer()

func restart_timer():
	timer.wait_time = get_stage_data().duration * DEBUG_DURATION_SCALE
	timer.start()

func _input(ev):
	if not active: return
	if ev.is_action_released("ui_accept"):
		disable()

func _on_timer_timeout():
	load_next_stage()

func get_factor():
	if at_max_stage: return 1.0
	
	var num_stages : int = GDict.stages.size()
	var precise_stage : float = stage + (1.0 - timer.time_left / timer.wait_time)
	var factor = precise_stage / num_stages
	return factor
