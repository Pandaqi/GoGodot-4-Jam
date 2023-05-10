extends Camera2D

@onready var main_node = get_parent()
const EDGE_MARGIN : Vector2 = Vector2(50,50)
const LERP_SPEED : float = 10.0
var bounds

func activate():
	bounds = main_node.get_mod("map").get_bounds()

func _physics_process(dt):
	center(dt)

func center(dt):
	var center = 0.5 * (bounds.top_left + bounds.bottom_right)
	var size = bounds.bottom_right - bounds.top_left + 2*EDGE_MARGIN
	var vp = get_viewport().size
	
	var factor = LERP_SPEED * dt
	var new_pos = lerp(get_position(), center, factor)
	set_position(new_pos)
	
	var wanted_zoom = Vector2(vp) / size
	var min_zoom = min(wanted_zoom.x, wanted_zoom.y)
	var desired_zoom = Vector2.ONE*min_zoom
	var new_zoom = lerp(get_zoom(), desired_zoom, factor)
	set_zoom(new_zoom)
