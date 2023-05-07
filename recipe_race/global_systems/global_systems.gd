extends Node3D

@onready var main = get_parent()
@onready var input_track_timer : Timer = $InputTrackTimer
const INPUT_TRACK_TICK : float = 4.0
const INPUT_TRACK_THRESHOLD : float = 0.5
var last_input_tick : float = 0

func activate():
	input_track_timer.wait_time = INPUT_TRACK_TICK
	input_track_timer.start()

func time_since_last_tick():
	return (Time.get_ticks_msec() - last_input_tick) / 1000.0

func calculate_avg_input(clear = false):
	var players = get_tree().get_nodes_in_group("Players")
	var avg_input = 0
	for p in players:
		var val = p.get_mod("input_tracker").read_value()
		if(clear): p.get_mod("input_tracker").clear()
		avg_input += val
	avg_input /= players.size()
	avg_input /= time_since_last_tick()
	return avg_input

func _on_input_track_timer_timeout():
	var val = calculate_avg_input(true)
	var turned_too_much = val >= INPUT_TRACK_THRESHOLD
	last_input_tick = Time.get_ticks_msec()
	
	var dv : float = -1.0 if turned_too_much else 1.0
	change_cauldron_size(dv)

func change_cauldron_size(ds : float):
	if not GDict.cfg.turning_changes_size: return
	
	print("Changing cauldron size!")
	var cauldrons = get_tree().get_nodes_in_group("Cauldrons")
	for c in cauldrons:
		c.change_max_size(ds)

func _physics_process(dt):
	main.get_mod("ui").update_input_bar( calculate_avg_input() )
