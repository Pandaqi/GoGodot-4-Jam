extends Node3D

@onready var body = get_parent()
var active : bool = false
@onready var rand_timer = $RandomTimer
const TIMER_CONFIG = { "min": 4.0, "max": 10.0, "autostart": true }
const JUMP_SPEED = { "min": 25.0, "max": 40.0 }

var state : String = "idle"

func _ready():
	rand_timer.connect("on_timeout", on_timeout)

func set_active(val):
	active = val
	if active:
		rand_timer.activate(TIMER_CONFIG)
	else:
		rand_timer.stop()

func is_active() -> bool:
	return active

func on_timeout():
	body.get_mod("visuals").play_animation("jump_prepare")
	await body.get_mod("visuals").anim_player.animation_finished
	move()

func move():
	var cauldrons = get_tree().get_nodes_in_group("Cauldrons")
	var closest_cauldron = null
	var closest_dist = INF
	for c in cauldrons:
		var dist = (c.get_position() - body.get_position()).length()
		if dist >= closest_dist: continue
		closest_dist = dist
		closest_cauldron = c
	
	var vec = (closest_cauldron.get_position() - body.get_position()).normalized()
	var rand_rot = randf_range(-0.25, 0.25)*PI
	var rand_speed = randf_range(JUMP_SPEED.min, JUMP_SPEED.max)
	vec.y = 0
	vec = vec.rotated(Vector3.UP, rand_rot)
	
	var final_force = vec * rand_speed
	body.get_mod("mover").add_force(final_force)
	body.get_mod("visuals").play_idle()
	
