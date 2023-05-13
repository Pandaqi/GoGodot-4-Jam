extends Node2D

@onready var body = get_parent()
@onready var player_area = $PlayerArea
@onready var cell_area = $CellArea
const BASE_SPEED : float = 360.0
const DASH_SPEED : float = 875.0
const DASH_DAMPING : float = 0.97
const DASH_END_THRESHOLD : float = 260.0
const MAX_SLIDE_ITERATIONS : int = 1
const MAX_DASH_POWER : int = 10

var input_vec : Vector2 = Vector2.ZERO
var facing_vec : Vector2 = Vector2.RIGHT
var dashing : bool = false
var speed : Vector2 = Vector2.ZERO
var dash_power : int = 0
var cell_hits_cur_dash : int = 0

const AUDIO_WALK_CONFIG = { "onoff": true, "stream": preload("res://less_is_store/player/sounds/walk_1.ogg"), "volume": -6 }
const AUDIO_CONFIG = { "dir": "res://less_is_store/player/sounds" }
@onready var audio_walk = $AudioWalk
@onready var audio_dash = $AudioDash

@onready var walk_particles = $WalkParticles
@onready var dash_particles = $DashParticles

signal dash_changed

func _ready():
	audio_walk.activate(AUDIO_WALK_CONFIG)
	audio_dash.activate(AUDIO_CONFIG)
	end_dash()

func no_input() -> bool:
	return is_zero_approx(get_input_vec().length())

func get_speed() -> Vector2:
	return speed

func _physics_process(_dt: float):
	check_move()
	check_dash()
	apply_move()
	
func get_input_vec():
	return input_vec

func get_facing_vec():
	return facing_vec

func no_dash_power():
	return dash_power <= 0

#TODO: if no current input, dash in current facing dir
func check_dash():
	if not GDict.cfg.dash_enabled: return
	
	if dashing: 
		speed *= DASH_DAMPING
		if speed.length() <= DASH_END_THRESHOLD: end_dash()
		return
	
	var dash_pressed = Input.is_action_just_released("ui_accept")
	var cant_start_dash = no_dash_power()
	if not dash_pressed: return
	if cant_start_dash: 
		body.give_feedback("no dash power!")
		return
	
	start_dash()

func start_dash():
	speed = get_facing_vec() * DASH_SPEED
	dashing = true
	cell_hits_cur_dash = 0
	change_dash_meter(-1)
	recheck_areas()
	dash_particles.set_emitting(true)
	
	audio_dash.play_from_list(["dash_1", "dash_2", "dash_3"])

func end_dash():
	dashing = false
	dash_particles.set_emitting(false)

func check_move():
	if not GDict.cfg.movement_enabled: return
	
	input_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dashing: return
	if no_input(): 
		speed = Vector2.ZERO
		return
	
	facing_vec = input_vec
	
	var movement = input_vec * BASE_SPEED
	speed = movement

func standing_still():
	return speed.length() <= 0.5

func apply_move():
	body.velocity = speed
	
	if standing_still(): 
		walk_particles.set_emitting(false)
		audio_walk.stop()
	else: 
		walk_particles.set_emitting(true)
		audio_walk.play()
	
	body.move_and_slide()
	
func apply_move_old(dt, iter = 0):
	if iter > MAX_SLIDE_ITERATIONS: return
	
	var new_pos = body.get_position() + speed * dt
	var cur_cell = body.get_map().get_cell_for_real_pos(body.get_position())
	var new_cell = body.get_map().get_cell_for_real_pos(new_pos)
	
	var no_cell_change = (cur_cell == new_cell)
	if no_cell_change: return move_to(speed)
	
	var can_enter = body.get_map().is_passthrough(new_cell)
	if can_enter: return move_to(speed)
	
	var cur_cell_pos = cur_cell.grid_pos
	var new_cell_pos = new_cell.grid_pos

	if(abs(new_cell_pos.x - cur_cell_pos.x) > 0.03): speed.x = 0
	if(abs(new_cell_pos.y - cur_cell_pos.y) > 0.03): speed.y = 0

	apply_move_old(dt, iter + 1)

func move_to(pos : Vector2):
	body.set_position(pos)

func change_dash_meter(dd : int, feedback : bool = true):
	dash_power = clamp(dash_power + dd, 0, MAX_DASH_POWER)
	if feedback: body.give_feedback(str(dd) + " dash!")
	emit_signal("dash_changed", dash_power)

func empty_dash_meter():
	body.give_feedback("dash emptied!")
	change_dash_meter(-dash_power, false)

func get_dash_meter() -> int:
	return dash_power

func recheck_areas():
	for other_body in player_area.get_overlapping_bodies():
		_on_area_2d_body_entered(other_body)
	
	for other_body in cell_area.get_overlapping_bodies():
		_on_cell_area_body_entered(other_body)

func ignore_area_hits(_other_body) -> bool:
	var ignore_hit = false
	if GDict.cfg.touch_stops_people: ignore_hit = false
	if (GDict.cfg.dash_stops_people or GDict.cfg.dash_reduces_backpack) and not dashing:
		ignore_hit = true

	return ignore_hit

func _on_area_2d_body_entered(other_body):
	if ignore_area_hits(other_body): return
	if not other_body.is_in_group("Clients"): return
	var success = other_body.get_mod("state").on_hit_by_player(body)
	if success: audio_dash.play_from_list(["client_hit"])

func _on_cell_area_body_entered(other_body):
	if ignore_area_hits(other_body): return
	
	var too_many_cells_already_hit = cell_hits_cur_dash >= GDict.cfg.max_cell_hits_per_dash
	if too_many_cells_already_hit: return
	
	var not_enough_dash = (get_dash_meter() < GDict.cfg.min_dash_required_for_destroying)
	if not_enough_dash: return
	
	if not other_body.is_in_group("Cells"): return
	var success = other_body.on_hit_by_player(body)
	if success: 
		audio_dash.play_from_list(["destruct"])
		cell_hits_cur_dash += 1
