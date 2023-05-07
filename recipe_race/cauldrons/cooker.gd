extends Node3D

@onready var body = get_parent()
@onready var timer : Timer = $Timer
@onready var cook_particles = $CookParticles
const TIME_PER_INGREDIENT = 3.0

func _ready():
	body.connect("ingredient_added", on_ingredient_added)

func on_ingredient_added(data):
	if not GDict.cfg.cauldrons_need_to_cook: return
	update_timer(TIME_PER_INGREDIENT)

func update_timer(dt):
	var new_time = timer.time_left + dt
	timer.stop()
	timer.wait_time = new_time
	timer.start()
	
	print("Wanna COOK")
	print(timer.wait_time)
	print(timer.time_left)
	
	cook_particles.show()
	body.get_mod("visuals").play_animation("cooking")

func is_cooking():
	return timer.time_left >= 0.03

func _on_timer_timeout():
	cook_particles.hide()
	body.get_mod("visuals").stop_animation("cooking")
