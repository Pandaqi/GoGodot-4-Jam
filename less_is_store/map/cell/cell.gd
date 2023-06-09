extends StaticBody2D

var data : Cell
const MAX_FLOOR_COLOR_VAR : float = 0.15
const OVERLAY_SCALE : float = 0.5
@onready var col_shape = $CollisionShape2D
@onready var buyable_icon = $Overlay/IngredientIcon
@onready var coin_list = $CoinList
@onready var layers = {
	"bg": $BG,
	"overlay": $Overlay
}

signal changed(cell)
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
	if at_floor_level and layers.overlay:
		layers.floor = layers.overlay
		layers.erase("overlay")

func sync_floor_to_data(map):
	var floor_color = Color(map.floor_color)
	var variation = randf() * MAX_FLOOR_COLOR_VAR
	if randf() <= 0.5: floor_color = floor_color.darkened(variation)
	else: floor_color = floor_color.lightened(variation)
	layers.bg.modulate = floor_color
	
	var tint_overlay = GDict.cell_types[data.type].has("tint_overlay_to_floor")
	if tint_overlay:
		layers.overlay.modulate = floor_color

func sync_type_to_data():
	var dict_data = GDict.cell_types[data.type]
	var disable_col = dict_data.has("passthrough")
	col_shape.set_deferred("disabled", disable_col)
	
	var show_overlay = dict_data.has("overlay")
	var overlay_node = layers.overlay if layers.has("overlay") else layers.floor
	
	var tw
	var rand_tween_duration = randf_range(0.2, 0.4)
	if show_overlay:
		var frame = GDict.cell_types[data.type].frame
		overlay_node.set_frame(frame)
		overlay_node.show()
		
		tw = get_tree().create_tween()
		overlay_node.set_scale(Vector2.ZERO)
		tw.tween_property(overlay_node, "scale", Vector2.ONE*OVERLAY_SCALE, rand_tween_duration).set_trans(Tween.TRANS_ELASTIC)
	else:
		tw = get_tree().create_tween()
		overlay_node.set_scale(Vector2.ONE*OVERLAY_SCALE)
		tw.tween_property(overlay_node, "scale", Vector2.ZERO, rand_tween_duration).set_trans(Tween.TRANS_LINEAR)
	
	await tw.finished
	
	if not show_overlay: overlay_node.hide()
	
	buyable_icon.hide()
	var show_item = dict_data.has("show_item")
	if show_item:
		buyable_icon.show()
		buyable_icon.set_frame(GDict.ingredients[data.buyable].frame)

func sync_number_to_data():
	coin_list.hide()
	if data.get_num() <= 0: return
	coin_list.show()
	coin_list.draw(data.get_num())

func sync_visuals_to_data(map):
	sync_position_to_data(map)
	sync_floor_to_data(map)
	sync_type_to_data()
	sync_number_to_data()

func on_hit_by_player(p) -> bool:
	var destroyable = GDict.cell_types[data.type].has("destroyable")
	var ignore_player_hits = (not destroyable) or (not GDict.cfg.dash_destroys_tiles)
	if ignore_player_hits: return false
	
	if GDict.cfg.destroying_tiles_empties_dash:
		p.get_mod("mover").empty_dash_meter()
	
	change_to_empty()
	return true

func change_to_empty():
	data.set_type(Enums.CellType.EMPTY)
	sync_type_to_data()
	emit_signal("changed", self)

# Never really use this, we only change type
func remove():
	emit_signal("removed")
	for layer in layers:
		var obj = layers[layer]
		obj.queue_free()
	self.queue_free()
