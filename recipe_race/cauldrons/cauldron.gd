extends Node3D

var content = []
var max_content_score = 5.0
const SIZE_BOUNDS = { "min": 1, "max": 6 }

@onready var modules = {
	"visuals": $Visuals
}

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on Cauldron node")
	return null

func change_max_size(ds):
	max_content_score = clamp(max_content_score + ds, SIZE_BOUNDS.min, SIZE_BOUNDS.max)

func is_empty():
	return content.size() <= 0

func empty():
	if is_empty(): return
	
	for i in range(content.size()-1, -1, -1):
		remove_at_index(i)
	content = []

func remove_at_index(idx):
	content.remove_at(idx)
	update_visuals()

func add(obj):
	content.append(obj)
	update_visuals()

func add_from_backpack(new_content):
	if new_content.size() <= 0: return
	
	for obj in new_content:
		add(obj)
	
	check_overflow()

func overflow():
	print("SHOULD OVERFLOW!!!")

func check_overflow():
	var content_score = calculate_content_score()
	if content_score <= max_content_score: return
	overflow()

func calculate_content_score():
	var sum = 0
	for obj in content:
		sum += 1
	return sum

func handle_player_entered(body):
	if body.get_mod("backpack").is_empty():
		body.get_mod("potion").apply_from_cauldron(content)
		empty()
		return
	
	add_from_backpack(body.get_mod("backpack").get_content())
	body.get_mod("backpack").empty()

func handle_ingredient_entered(body):
	add(body.get_data_representation())
	body.remove()

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
	get_mod("visuals").update_ui(content)
