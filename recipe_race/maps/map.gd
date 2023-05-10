extends Node3D

@export var level_bounds : Vector3 = Vector3(30, 0, 18)

func activate():
	var cauldrons = get_tree().get_nodes_in_group("Cauldrons")
	for c in cauldrons:
		c.activate()

func get_random_valid_position(config):
	var avoid = [] if not config.has("avoid") else config.avoid
	var radius = 10 if not config.has("radius") else config.radius
	
	var bad_pos : bool = true
	var pos : Vector3 = Vector3.ZERO
	var tries_per_radius_decrease = 50
	var num_tries = 0
	while bad_pos:
		num_tries += 1
		pos = get_random_position()
		
		bad_pos = false
		for node in avoid:
			var dist = (node.get_position() - pos).length()
			if dist > radius: continue
			bad_pos = true
			break
		
		if num_tries % tries_per_radius_decrease == 0:
			radius *= 0.5
	
	return pos

func get_random_position():
	var x = randf_range(-1,1)*level_bounds.x
	var z = randf_range(-1,1)*level_bounds.z
	var y = level_bounds.y
	return Vector3(x, y, z)
