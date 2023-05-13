extends Node2D

@onready var body = get_parent()
const DAMPING : float = 0.97
var force : Vector2 = Vector2.ZERO

func add_force(extra_force : Vector2):
	force += extra_force

func has_force() -> bool:
	return force.length() >= 1

func _physics_process(_dt: float):
	if not has_force(): return
	
	force *= DAMPING
	body.velocity = force
	body.move_and_slide()
