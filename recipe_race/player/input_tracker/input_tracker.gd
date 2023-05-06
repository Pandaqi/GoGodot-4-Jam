extends Node3D

var num : float = 0.0

func register_input(dv):
	num += dv

func read_value() -> float:
	return num

func read_and_clear_value() -> float:
	var val = num
	clear()
	return val

func clear():
	num = 0
