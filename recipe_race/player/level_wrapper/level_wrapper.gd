extends Node3D

@onready var body = get_parent()
@onready var timer = $Timer

var model_copy
var boundaries = []
var allow_teleport = true
var active : bool = false

func activate():
	cache_model()
	active = true
	body.add_to_group("LevelWrappers")

func cache_model():
	model_copy = get_original_visuals().duplicate(true)
	self.add_child(model_copy)

func _physics_process(dt):
	if not active: return
	
	mirror_original_model()
	if not overlapping_boundary(): return
	place_copy_at_other_boundary()
	check_level_wrap()

func overlapping_boundary():
	return boundaries.size() > 0

func get_first_boundary():
	return boundaries[0]

func get_original_visuals():
	return body.get_mod("visuals")

func mirror_original_model():
	model_copy.global_transform = get_original_visuals().global_transform
	model_copy.set_visible(false)

func place_copy_at_other_boundary():
	var b = get_first_boundary()
	var start_pos = get_original_visuals().global_transform.origin
	var offset = b.get_vector_to_other_side()
	model_copy.global_transform.origin = start_pos + offset
	model_copy.set_visible(true)

func check_level_wrap():
	var b = get_first_boundary()
	var dist = (b.global_transform.origin - get_original_visuals().global_transform.origin)
	var dist_perpendicular = (dist * b.get_vector_to_other_side())
	var dist_summed = dist_perpendicular.x + dist_perpendicular.y + dist_perpendicular.z
	if dist_summed <= 0: return
	teleport()

func teleport():
	if not allow_teleport: return
	body.global_transform.origin = model_copy.global_transform.origin
	allow_teleport = false
	timer.start()

func register_boundary(b):
	boundaries.append(b)

func unregister_boundary(b):
	boundaries.erase(b)

func _on_timer_timeout():
	allow_teleport = true
