extends Node3D

@onready var main_node = get_node("/root/Main")

var content = []
var max_content_score : float = -1.0
const SCALE_BOUNDS = { "min": 0.25, "max": 1.33 }

signal overflow
signal ingredient_added(data)
signal ingredient_removed(data)
signal emptied

@onready var modules = {
	"visuals": $Visuals,
	"cooker": $Cooker,
	"teleporter": $Teleporter
}

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on Cauldron node")
	return null

func activate():
	main_node.get_mod("progression").connect("state_changed", on_state_changed)

func set_default_cauldron_size():
	var data = GDict.cfg.cauldron_size_bounds
	max_content_score = round(0.5*(data.min + data.max))

func get_main_node():
	return main_node

func change_max_size(ds : float):
	var b = GDict.cfg.cauldron_size_bounds
	max_content_score = clamp(max_content_score + ds, b.min, b.max)
	var scale_factor = (max_content_score - b.min) / (b.max - b.min)
	var new_scale = lerp(SCALE_BOUNDS.min, SCALE_BOUNDS.max, scale_factor)
	set_scale(Vector3.ONE * new_scale)

	update_visuals()

func get_max_size():
	return ceil(max_content_score)

func is_empty():
	return content.size() <= 0

func empty():
	if is_empty(): return
	
	for i in range(content.size()-1, -1, -1):
		remove_at_index(i)
	content = []
	
	emit_signal("emptied")

func remove_at_index(idx):
	emit_signal("ingredient_removed", content[idx])
	content.remove_at(idx)
	update_visuals()

func add(obj):
	emit_signal("ingredient_added", obj)
	content.append(obj)
	update_visuals()
	check_overflow()

func add_from_backpack(new_content):
	if new_content.size() <= 0: return
	
	for obj in new_content:
		add(obj)

func check_overflow():
	var content_score = calculate_content_score()
	if content_score <= max_content_score: return
	emit_signal("overflow")

func calculate_content_score():
	var sum = 0
	for obj in content:
		sum += 1
	return sum

func handle_player_entered(body):
	var backpack_empty : bool = body.get_mod("backpack").is_empty()
	var player_can_drink = GDict.cfg.player_can_drink_potion
	var give_potion_to_player : bool = backpack_empty and player_can_drink and (not get_mod("cooker").is_cooking())
	
	if give_potion_to_player:
		body.get_mod("potion").apply_from_cauldron(content)
		empty()
		return
	
	if backpack_empty: return
	
	add_from_backpack(body.get_mod("backpack").get_content())
	body.get_mod("backpack").empty()

func handle_ingredient_entered(body):
	add(body.get_data_representation())
	body.remove("cauldron")

func _on_area_3d_body_entered(body):
	if not body.is_in_group("Players"): return
	handle_player_entered(body)

func _on_area_3d_body_exited(body):
	pass # Replace with function body.

func _on_area_3d_area_entered(area):
	if not area.get_parent().is_in_group("Ingredients"): return
	handle_ingredient_entered(area.get_parent())

func update_visuals():
	print("Cauldron")
	print(content)
	
	get_mod("visuals").play_animation("change")
	get_mod("visuals").update_ui(content, get_max_size())

func on_state_changed():
	if max_content_score <= 0: set_default_cauldron_size()
	
	update_visuals()
