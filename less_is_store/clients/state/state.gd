extends Node2D

enum State {
	ARRIVING,
	WALKING,
	GRABBING,
	STUNNED,
	LEAVING
}

@onready var anim_player : AnimationPlayer = $AnimationPlayer

@onready var stun_timer : Timer = $StunTimer
const STUN_TIMER_BOUNDS = { "min": 3.0, "max": 8 }

@onready var grab_timer : Timer = $GrabTimer
const GRAB_TIMER_BOUNDS = { "min": 1.0, "max": 3.5 }

const KNOCKBACK_FORCE : float = 400.0

@onready var body = get_parent()
var state : State

func activate():
	change_state_to(State.ARRIVING)
	anim_player.play("appear")
	await anim_player.animation_finished
	
	body.get_mod("path_walker").connect("arrived", on_walking_arrived)
	change_state_to(State.WALKING)

func is_stunned() -> bool:
	return state == State.STUNNED

func get_map():
	return body.map

func get_cur_cell() -> Cell:
	return get_map().get_cell_for_node(body)

# TODO: also start/stop proper animations and stuff
func change_state_to(new_state):
	state = new_state
	
	if is_inactive(): return
	
	anim_player.play("idle")
	if state == State.WALKING:
		var our_cell = get_cur_cell()
		var target_cell = get_map().get_cell_next_to(Enums.CellType.BUYABLE)
		var head_to_checkout = body.get_mod("backpack").is_full()
		if head_to_checkout: target_cell = get_map().get_checkout()
		
		var path = get_map().get_path_to_cell(our_cell, target_cell)
		if(path.size() <= 2): return change_state_to(State.GRABBING)
		body.get_mod("path_walker").follow(path)
	
	if state == State.GRABBING:
		start_grab_timer()
	
	if state == State.STUNNED:
		anim_player.play("stunned")
		body.get_mod("path_walker").stop_following()
		start_stunned_timer()
		
		if GDict.cfg.dash_reduces_backpack:
			body.get_mod("backpack").change_max_content(-1)
			if body.get_mod("backpack").has_zero_size():
				return leave()

func is_inactive():
	return [State.ARRIVING, State.LEAVING].has(state)

func on_hit_by_player(player):
	if is_inactive(): return
	if GDict.cfg.touch_stops_people or GDict.cfg.dash_stops_people:
		return leave()
	stun(player)

func stun(player):
	if is_stunned(): return
	var repel_force = (body.global_position - player.global_position).normalized()
	repel_force *= KNOCKBACK_FORCE
	body.get_mod("knockback").add_force(repel_force)
	change_state_to(State.STUNNED)

func should_leave():
	var at_checkout = get_cur_cell().type == Enums.CellType.CHECKOUT
	return at_checkout and body.get_mod("backpack").is_full()

func on_walking_arrived():
	if should_leave(): return leave(true)
	
	#TODO: get a neighbor cell which has a buyable object thingy
	var nb = get_map().get_buyable_object_around(get_cur_cell())
	if nb.is_invalid(): return change_state_to(State.WALKING)
	
	body.get_mod("backpack").add(nb.get_backpack_version())
	change_state_to(State.GRABBING)

func start_grab_timer():
	grab_timer.wait_time = randf_range(GRAB_TIMER_BOUNDS.min, GRAB_TIMER_BOUNDS.max)
	grab_timer.start()

func _on_grab_timer_timeout():
	change_state_to(State.WALKING)

func start_stunned_timer():
	stun_timer.wait_time = randf_range(STUN_TIMER_BOUNDS.min, STUN_TIMER_BOUNDS.max)
	stun_timer.start()

func _on_stun_timer_timeout():
	change_state_to(State.WALKING)

func leave(pay : bool = false):
	if pay: body.emit_signal("score", body)
	change_state_to(State.LEAVING)
	
	anim_player.play_backwards("appear")

	# TODO: particles and feedback and stuff


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "appear" and state == State.LEAVING:
		body.remove()
