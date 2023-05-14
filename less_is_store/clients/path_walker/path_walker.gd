extends Node2D

@onready var body = get_parent()
var cur_path : Array = []
var active : bool = false

const MAX_ERROR_POINT_RADIUS : float = 5.0
const SPEED_BOUNDS : Dictionary = { "min": 120, "max": 160 }
var speed : float = 0.0
const DEBUG : bool = false #DEBUGGING (should be false)

const AUDIO_WALK_CONFIG = { "onoff": true, "stream": preload("res://less_is_store/player/sounds/walk_1.ogg"), "volume": -12 }
@onready var audio_walk = $AudioWalk
@onready var walk_particles : CPUParticles2D = $WalkParticles

signal arrived

func activate():
	determine_walking_speed()
	
	audio_walk.activate(AUDIO_WALK_CONFIG)

func determine_walking_speed():
	var speed_factor = 1.0
	if body.get_data().has("speed_factor"): speed_factor = body.get_data().speed_factor
	
	speed = randf_range(SPEED_BOUNDS.min, SPEED_BOUNDS.max)
	speed *= speed_factor

func has_path():
	return cur_path.size() > 0

func follow(path):
	cur_path = path
	active = true
	audio_walk.play()
	walk_particles.set_emitting(true)

func stop_following():
	cur_path = []
	active = false
	audio_walk.stop()
	walk_particles.set_emitting(false)

func _physics_process(dt):
	if not active: return
	continue_on_path(dt)
	if DEBUG: queue_redraw()

func get_next_point():
	if not has_path(): return null
	return cur_path[0]

func check_if_arrived():
	var has_arrived = not has_path()
	if not has_arrived: return
	
	stop_following()
	emit_signal("arrived")

func continue_on_path(_dt):
	var vec = (get_next_point() - body.get_position()).normalized()
	var movement = vec * speed
	
	body.velocity = movement
	body.move_and_slide()
	
	var dist_to_point = (get_next_point() - body.get_position()).length()
	var arrived_at_point = (dist_to_point <= MAX_ERROR_POINT_RADIUS)
	if arrived_at_point:
		cur_path.pop_front()
		check_if_arrived()

func _draw():
	if not DEBUG: return

	var line_color = Color.RED
	var line_width = 5
	for i in range(cur_path.size()-1):
		var p1 = cur_path[i]
		var p2 = cur_path[i+1]
		draw_line(to_local(p1), to_local(p2), line_color, line_width)
