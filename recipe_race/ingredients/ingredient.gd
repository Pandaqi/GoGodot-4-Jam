extends Node3D

var type : String = "what?"
var active : bool = false

@onready var modules = {
	"visuals": $Visuals,
	"ai": $AI,
	"mover": $Mover,
	"level_wrapper": $LevelWrapper
}

signal removed(cause)
signal type_changed(tp)

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on Ingredient node")
	return null

func _ready():
	get_mod("visuals").play_animation("appear")
	await get_mod("visuals").anim_player.animation_finished
	
	active = true
	get_mod("level_wrapper").activate()
	get_mod("visuals").play_idle()

func is_active():
	return active

func set_type(t):
	type = t
	emit_signal("type_changed", t)

func on_unaccepted_by(body):
	var val = GDict.cfg.handle_unaccepted_ingredients
	
	if val == "skip": return
	elif val == "destroy": remove()
	elif val == "makeai": get_mod("ai").set_active(true)
	elif val == "repel":
		get_mod("mover").repel_from(body.get_position())

func _on_area_3d_body_entered(body):
	if not active: return
	if not body.is_in_group("Players"): return
	
	var data = get_data_representation()
	if not body.get_mod("backpack").can_accept(data): 
		on_unaccepted_by(body)
		return
	
	body.get_mod("backpack").add(data)
	remove()

func _on_area_3d_body_exited(body):
	if not body.is_in_group("Players"): return
	pass

func get_data_representation():
	return {
		"type": type
	}

func remove(reason = "player"):
	queue_free() #TODO: should play a tween or something
	emit_signal("removed", reason)

func on_state_changed():
	pass
