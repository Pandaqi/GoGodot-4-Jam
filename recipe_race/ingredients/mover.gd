extends Node3D

@onready var body = get_parent()
var velocity : Vector3 = Vector3.ZERO
const DAMPING : float = 0.95
const REPEL_FORCE : float = 10.0

func repel_from(pos : Vector3, force = REPEL_FORCE):
	var vec = (body.get_position() - pos).normalized()
	add_force(vec * force)

func add_force(f : Vector3):
	velocity += f

func _physics_process(dt : float):
	if velocity.length() <= 0.05:
		velocity = Vector3.ZERO
		return
	
	velocity *= DAMPING
	body.set_position(body.get_position() + velocity*dt)
