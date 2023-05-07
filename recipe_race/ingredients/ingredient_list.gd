extends Node2D

@onready var icon_scene = preload("res://recipe_race/ingredients/ingredient_icon.tscn")
@onready var container = $Container
const ICON_CACHE : int = 10
const ICON_SIZE : Vector2 = Vector2(256,256)
const SCALE : float = 0.25
var icons = []
var num_slots : int = -1

var offset : Vector2 = Vector2(0,-50)

func _ready():
	cache_icons()

func cache_icons():
	for i in range(ICON_CACHE):
		var icon = icon_scene.instantiate()
		icon.set_visible(false)
		container.add_child(icon)
		icons.append(icon)
		icon.set_position(Vector2.RIGHT*i*ICON_SIZE.x)

func set_offset(o):
	offset = o

func visualize(content):
	for icon in icons:
		icon.set_visible(false)
	
	var icons_shown = content.size()
	for i in range(content.size()):
		var data = GDict.ingredients[content[i].type]
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
	var pos_3d = get_parent().global_transform.origin
	var pos_2d = get_viewport().get_camera_3d().unproject_position(pos_3d)
	pos_2d += offset
	set_position(pos_2d)

func show_slots(max_size):
	num_slots = max_size
