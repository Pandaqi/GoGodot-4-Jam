extends Node3D

func activate():
	pass

# TODO: proper implementation
func get_random_position():
	var x = randf_range(-20,20)
	var z = randf_range(-10, 10)
	var y = 2.5
	return Vector3(x, y, z)
