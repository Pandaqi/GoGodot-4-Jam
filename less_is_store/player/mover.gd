extends Node2D

@onready var body = get_parent()
@onready var area = $Area2D
const BASE_SPEED : float = 360.0
const DASH_SPEED : float = 750.0
const DASH_DAMPING : float = 0.97
const DASH_END_THRESHOLD : float = 240.0
const MAX_SLIDE_ITERATIONS : int = 1
const MAX_DASH_POWER : int = 10
var input_vec : Vector2 = Vector2.ZERO
var facing_vec : Vector2 = Vector2.RIGHT
var dashing : bool = false
var speed : Vector2 = Vector2.ZERO
var dash_power : int = 0

signal dash_changed

func no_input() -> bool:
	return is_zero_approx(get_input_vec().length())

func _physics_process(dt: float):
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
		if speed.length() <= DASH_END_THRESHOLD: dashing = false
		return
	
	var dash_pressed = Input.is_action_just_released("ui_accept")
	var cant_start_dash = no_dash_power()
	if not dash_pressed or cant_start_dash: return
	
	speed = get_facing_vec() * DASH_SPEED
	dashing = true
	change_dash_meter(-1)
	recheck_area()

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

func apply_move():
	body.velocity = speed
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

func change_dash_meter(dd : int):
	dash_power = clamp(dash_power + dd, 0, MAX_DASH_POWER)
	emit_signal("dash_changed", dash_power)

func empty_dash_meter():
	change_dash_meter(-dash_power)

func get_dash_meter() -> int:
	return dash_power

func recheck_area():
	for other_body in area.get_overlapping_bodies():
		_on_area_2d_body_entered(other_body)

func ignore_area_hits(other_body) -> bool:
	var ignore_hit = false
	if GDict.cfg.touch_stops_people: ignore_hit = false
	if (GDict.cfg.dash_stops_people or GDict.cfg.dash_reduces_backpack) and not dashing:
		ignore_hit = true

	return ignore_hit

func _on_area_2d_body_entered(other_body):
	if ignore_area_hits(other_body): return
	if not other_body.is_in_group("Clients"): return
	other_body.get_mod("state").on_hit_by_player(body)

func _on_cell_area_body_entered(other_body):
	if ignore_area_hits(other_body): return
	if not other_body.is_in_group("Cells"): return
	other_body.on_hit_by_player(body)
