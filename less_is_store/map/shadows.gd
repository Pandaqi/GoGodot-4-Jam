extends Node2D

const SHADOW_OPACITY : float = 0.15
const SHADOW_Y_SCALE : float = 0.4

func _ready():
	modulate.a = SHADOW_OPACITY
	scale.y = SHADOW_Y_SCALE

func _physics_process(_dt):
	queue_redraw()

func _draw():
	var nodes = get_tree().get_nodes_in_group("ShadowLocators")
	
	var shadow_color = Color.BLACK
	
	for node in nodes:
		var shadow_radius = node.size
		var pos = to_local(node.global_position)
		draw_circle(pos, shadow_radius, shadow_color)
