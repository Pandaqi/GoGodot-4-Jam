extends Node2D

@onready var body = get_parent()

var content = []
var max_content : int = 1
@onready var ingredient_list = $IngredientList
const SIZE_BOUNDS = { "min": 1, "max": 4 }

func activate():
	body.connect("removed", on_removed)
	
	max_content = randi_range(SIZE_BOUNDS.min, SIZE_BOUNDS.max)
	
	remove_child(ingredient_list)
	body.map.add_child(ingredient_list)
	ingredient_list.activate(self)
	update_visuals()

func add(data):
	if is_full(): return
	content.append(data)
	update_visuals()

func remove_by_index(idx):
	if is_empty(): return
	content.remove_at(idx)
	update_visuals()

func change_max_content(dc : int):
	max_content += dc
	while content.size() > max_content:
		remove_by_index(content.size()-1)
	update_visuals()

func is_full() -> bool:
	return content.size() >= max_content

func is_empty() -> bool:
	return content.size() <= 0

func get_content() -> Array:
	return content

func has_zero_size() -> bool:
	return max_content <= 0

func update_visuals():
	ingredient_list.visualize(content, max_content)

func on_removed():
	ingredient_list.queue_free()