extends Area3D

@export var other_side : Area3D
@export var vec : Vector3 = Vector3(0,0,-1)

func get_vector_to_other_side():
	return vec.abs() * (other_side.transform.origin - self.transform.origin)

func _on_body_entered(body):
	if not body.is_in_group("Players"): return
	body.get_mod("level_wrapper").register_boundary(self)

func _on_body_exited(body):
	if not body.is_in_group("Players"): return
	body.get_mod("level_wrapper").unregister_boundary(self)
