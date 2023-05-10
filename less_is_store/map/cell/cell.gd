extends StaticBody2D

var data : Cell
const MAX_FLOOR_COLOR_VAR : float = 0.15
@onready var col_shape = $CollisionShape2D
@onready var buyable_icon = $Overlay/IngredientIcon
@onready var layers = {
	"bg": $BG,
	"overlay": $Overlay
}

signal removed

func get_real_pos(cell_size : Vector2):
	return (Vector2(data.grid_pos) + Vector2(0.5,0.5))  * cell_size

func sync_position_to_data(map):
	set_position(get_real_pos(map.get_cell_size()))
		
	var dict_data = GDict.cell_types[data.type]
	var rotate_to_match_edge = dict_data.has("match_rotation")
	if rotate_to_match_edge:
		var rot = map.get_rotation_index_for_edge(data)
		set_rotation(rot * 0.5 * PI)
	
	var at_floor_level = dict_data.has("overlay_on_floor")
	if at_floor_level:
		layers.floor = layers.overlay
		layers.erase("overlay")

func sync_floor_to_data(map):
	var floor_color = Color(map.floor_color)
	var variation = randf() * MAX_FLOOR_COLOR_VAR
	if randf() <= 0.5: floor_color = floor_color.darkened(variation)
	else: floor_color = floor_color.lightened(variation)
	layers.bg.modulate = floor_color

func sync_type_to_data():
	var dict_data = GDict.cell_types[data.type]
	var disable_col = dict_data.has("passthrough")
	col_shape.set_deferred("disabled", disable_col)
	
	var show_overlay = dict_data.has("overlay")
	var overlay_node = layers.overlay if layers.has("overlay") else layers.floor
	
	overlay_node.hide()
	if show_overlay:
		var frame = GDict.cell_types[data.type].frame
		overlay_node.set_frame(frame)
		overlay_node.show()
	
	buyable_icon.hide()
	var is_buyable = dict_data.has("buyable")
	if is_buyable:
		buyable_icon.show()
		buyable_icon.set_frame(GDict.ingredients[data.buyable].frame)
	
	

func sync_visuals_to_data(map):
	sync_position_to_data(map)
	sync_floor_to_data(map)
	sync_type_to_data()

# @TODO: _start_ destroy process, other checks, something
func on_hit_by_player(p):
	var ignore_player_hits = (data.type != Enums.CellType.BUYABLE)
	if ignore_player_hits: return
	
	data.set_type(Enums.CellType.EMPTY)
	sync_type_to_data()

# Never really use this, we only change type
func remove():
	emit_signal("removed")
	for layer in layers:
		var obj = layers[layer]
		obj.queue_free()
	self.queue_free()
