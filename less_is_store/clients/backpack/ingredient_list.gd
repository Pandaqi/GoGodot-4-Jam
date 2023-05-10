extends Node2D

@onready var icon_scene = preload("res://less_is_store/ingredients/ingredient_icon.tscn")
@onready var container = $Container
const ICON_SIZE : Vector2 = Vector2(256,256)
const SCALE : float = 0.25
var icons = []
var num_slots : int = -1

var offset : Vector2 = Vector2(0,-125)
var backpack

func activate(b):
	backpack = b
	cache_icons(b.max_content)

func cache_icons(cache_size):
	for i in range(cache_size):
		var icon = icon_scene.instantiate()
		icon.set_visible(false)
		container.add_child(icon)
		icons.append(icon)
		icon.set_position(Vector2.RIGHT*i*ICON_SIZE.x)

func set_offset(o):
	offset = o

func visualize(content, num_slots = -1):
	if num_slots <= 0: num_slots = content.size()
	
	for icon in icons:
		icon.set_visible(false)
	
	var icons_shown = content.size()
	for i in range(content.size()):
		var data = GDict.ingredients[content[i].buyable]
		var icon = icons[i]
		icon.set_frame(data.frame)
		icon.set_visible(true)
	
	if num_slots >= 0:
		var empty_slot_frame = GDict.ingredients.empty_slot.frame
		for i in range(content.size(), num_slots):
			var icon = icons[i]
			icon.set_frame(empty_slot_frame)
			icon.set_visible(true)
		icons_shown = num_slots
	
	var half_size = 0.5*(icons_shown - 1)
	var offset = -half_size*ICON_SIZE.x*Vector2.RIGHT
	container.set_position(offset)
	set_scale(Vector2.ONE*SCALE)

func _physics_process(dt):
	var pos_2d = backpack.global_transform.origin
	pos_2d += offset
	set_position(pos_2d)
