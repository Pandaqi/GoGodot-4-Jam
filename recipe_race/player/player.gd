extends CharacterBody3D

const SPEED = 10.0
const ACCEL_SPEED = 20.0
const DECEL_SPEED = 20.0
const ROTATE_SPEED = 2*PI
const JUMP_VELOCITY = 4.5

@onready var modules = {
	"backpack": $Backpack,
	"visuals": $Visuals,
	"level_wrapper": $LevelWrapper,
	"potion": $Potion,
	"input_tracker": $InputTracker
}

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on the player node")
	return null

func _ready():
	get_mod("level_wrapper").activate()

func _physics_process(delta):
	apply_gravity(delta)
	handle_jump(delta)
	handle_move(delta)
	rotate_to_match_velocity(delta)
	
	move_and_slide()

func apply_gravity(delta):
	if is_on_floor(): return
	velocity.y -= gravity * delta

func handle_jump(delta):
	var jump_btn_pressed = Input.is_action_just_pressed("ui_accept")
	if not jump_btn_pressed: return
	
	var jump_allowed = is_on_floor()
	if not jump_allowed: return
	
	velocity.y = JUMP_VELOCITY

func get_forward_vec():
	return -transform.basis.z

func handle_move(delta):
	var rotate_dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	get_mod("input_tracker").register_input(abs(rotate_dir)*delta)
	
	var direction = get_forward_vec()
	var rotate_amount = -rotate_dir * ROTATE_SPEED * delta
	direction = direction.rotated(Vector3.UP, rotate_amount)
	
	var player_wants_accel = false
	var auto_accel = GDict.cfg.player_auto_moves
	if not auto_accel and not player_wants_accel:
		direction = Vector3.ZERO
	
	var should_accel = direction.length() > 0.03
	
	if should_accel:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCEL_SPEED * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCEL_SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL_SPEED * delta)
		velocity.z = move_toward(velocity.z, 0, DECEL_SPEED * delta)

func standing_still():
	return vel_no_y().length() < 0.03

func vel_no_y(vec = velocity):
	return Vector3(vec.x, 0, vec.z)

func rotate_to_match_velocity(delta):
	var cur_vel = vel_no_y()
	if standing_still(): return
	
	var point_ahead = transform.origin + cur_vel
	transform.basis = transform.looking_at(point_ahead).basis


