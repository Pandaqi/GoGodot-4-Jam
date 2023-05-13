extends Node2D

const ICON_CACHE : int = 5
var icons : Array = []
const ICON_SIZE = Vector2(256,256)
const SCALE : float = 0.1
@onready var container : Node2D = $Container
var icon_scene : PackedScene = preload("res://less_is_store/map/cell/coin_sprite.tscn")

func _ready():
	cache_icons(ICON_CACHE)

func cache_icons(cache_size):
	for i in range(cache_size):
		var icon = icon_scene.instantiate()
		icon.set_visible(false)
		container.add_child(icon)
		icons.append(icon)
		icon.set_position(Vector2.RIGHT*i*ICON_SIZE.x)

func draw(num):
	for icon in icons:
		icon.set_visible(false)

	for i in range(num):
		icons[i].set_visible(true)
	
	var half_size = 0.5*(num - 1)
	var offset = -half_size*ICON_SIZE.x*Vector2.RIGHT
	container.set_position(offset)
	set_scale(Vector2.ONE*SCALE)
