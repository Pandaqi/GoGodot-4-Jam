extends Area3D

@export var other_side : Area3D
@export var vec : Vector3 = Vector3(0,0,-1)

func get_vector_to_other_side():
	return vec.abs() * (other_side.transform.origin - self.transform.origin)

func on_enter(body):
	if not body.is_in_group("LevelWrappers"): return
	body.get_mod("level_wrapper").register_boundary(self)

func on_exit(body):
	if not body.is_in_group("LevelWrappers"): return
	body.get_mod("level_wrapper").unregister_boundary(self)

func _on_body_entered(body):
	on_enter(body)

func _on_body_exited(body):
	on_exit(body)

func _on_area_entered(area):
	on_enter(area.get_parent())

func _on_area_exited(area):
	on_enter(area.get_parent())
