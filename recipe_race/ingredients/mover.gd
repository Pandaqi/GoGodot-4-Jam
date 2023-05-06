extends Node3D

@onready var body = get_parent()
var velocity : Vector3 = Vector3.ZERO
const DAMPING : float = 0.95

func add_force(f : Vector3):
	velocity += f

func _physics_process(dt : float):
	if velocity.length() <= 0.05:
		velocity = Vector3.ZERO
		return
	
	velocity *= DAMPING
	body.set_position(body.get_position() + velocity*dt)
