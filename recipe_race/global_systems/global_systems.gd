extends Node3D

@onready var input_track_timer = $InputTrackTimer
const INPUT_TRACK_TICK = 4.0
const INPUT_TRACK_THRESHOLD = 0.5

func activate():
	input_track_timer.wait_time = INPUT_TRACK_TICK
	input_track_timer.start()

func _on_input_track_timer_timeout():
	var players = get_tree().get_nodes_in_group("Players")
	var avg_input = 0
	for p in players:
		avg_input += p.get_mod("input_tracker").read_and_clear_value()
	avg_input /= players.size()
	
	var turned_too_much = avg_input >= INPUT_TRACK_THRESHOLD
	if turned_too_much:
		change_cauldron_size(-1)
	else:
		change_cauldron_size(+1)

func change_cauldron_size(ds):
	print("Changing cauldron size!")
	var cauldrons = get_tree().get_nodes_in_group("Cauldrons")
	for c in cauldrons:
		c.change_max_size(ds)
	
	
