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

#const AUDIO_CONFIG = { "dir": "res://less_is_store/clients/sounds/" }
@onready var audio_player_coins = $AudioPlayerCoins
@onready var audio_player_leave = $AudioPlayerLeave

@onready var appear_particles = $AppearParticles
@onready var coin_particles = $CoinParticles

const KNOCKBACK_FORCE : float = 400.0

@onready var body = get_parent()
var state : State
var type : Enums.Client

func activate():
	#audio_player.activate(AUDIO_CONFIG)
	
	change_state_to(State.ARRIVING)
	anim_player.play("appear")
	await anim_player.animation_finished
	
	body.get_mod("path_walker").connect("arrived", on_walking_arrived)
	change_state_to(State.WALKING)

func set_type(t : Enums.Client):
	type = t
	body.get_mod("visuals").on_type_changed(t)

func get_type() -> Enums.Client:
	return type

func is_stunned() -> bool:
	return state == State.STUNNED

func get_map():
	return body.map

func get_cur_cell() -> Cell:
	return get_map().get_cell_for_node(body)

func stop_current_state():
	stun_timer.stop()
	grab_timer.stop()
	body.get_mod("path_walker").stop_following()

func change_state_to(new_state):
	state = new_state
	
	stop_current_state()
	
	if new_state == State.ARRIVING or new_state == State.LEAVING:
		appear_particles.set_emitting(true)
	
	if is_inactive(): return
	
	anim_player.play("idle")
	if state == State.WALKING:
		var speed_scale = 1.0
		if body.get_data().has("anim_speed"): speed_scale = body.get_data().anim_speed
		
		anim_player.speed_scale = speed_scale
		anim_player.play("run")
		
		var our_cell = get_cur_cell()
		var target_cell = get_map().get_cell_next_to(Enums.CellType.BUYABLE)
		var head_to_checkout = body.get_mod("backpack").is_full()
		if head_to_checkout: target_cell = get_map().get_checkout(body)
		
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

func on_hit_by_player(player) -> bool:
	if is_inactive(): return false
	if GDict.cfg.touch_stops_people or GDict.cfg.dash_stops_people:
		leave()
		return true
	return stun(player)

func stun(player) -> bool:
	if is_stunned(): return false
	var repel_force = (body.global_position - player.global_position).normalized()
	repel_force *= KNOCKBACK_FORCE
	body.get_mod("knockback").add_force(repel_force)
	body.give_feedback("Stunned!")
	change_state_to(State.STUNNED)
	return true

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
	change_state_to(State.LEAVING)	
	
	if pay: 
		audio_player_coins.pitch_scale = 1.0 + randf_range(-0.05, 0.05)
		audio_player_coins.play()
		coin_particles.set_emitting(true)
		body.emit_signal("score", body)
	else:
		audio_player_leave.play()
	
	anim_player.play_backwards("appear")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "appear" and state == State.LEAVING:
		body.remove()
