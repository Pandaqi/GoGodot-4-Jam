extends Node2D

@onready var main_node = get_parent()

const MAP_SIZE : Vector2i = Vector2i(16, 9)
const CELL_SIZE : Vector2 = Vector2(128, 128)
const MIN_GENERATION_PATH_LENGTH : int = 8
const MIN_PERCENTAGE_FILLED : float = 0.4
const MAX_RANDOM_WALK_TRIES : int = 500
const MAX_ENTRANCES : int = 4
const MAX_CHECKOUTS : int = 6
const MAX_DIST_TO_CHECKOUT : float = 11.5 # this is MANHATTAN dist, not EULER
var grid : Array
var grid_flat : Array
var grid_visual : Array
var edge_cells : Array
var astar : AStar2D
var cell_scene : PackedScene = preload("res://less_is_store/map/cell/cell.tscn")

var entrance_cells : Array
var checkout_cells : Array

var available_buyables : Array
var generation_done : bool = false

var floor_color : Color

@onready var layers = {
	"bg": $BG,
	"floor": $Floor,
	"overlay": $Overlay
}

signal cell_changed(cell)

func activate():
	main_node.get_mod("progression").connect("state_changed", on_state_changed)
	
	determine_available_buyables()
	determine_floor_color()
	load_map()
	generation_done = true

func on_state_changed():
	add_sales_if_needed()

func add_sales_if_needed():
	var sales = get_cells_of_type(Enums.CellType.SALE)
	var num_sales = sales.size()
	while num_sales < GDict.cfg.num_sales:
		turn_random_cell_into_sale_sign()
		num_sales += 1

func generation_is_done() -> bool:
	return generation_done

func determine_floor_color():
	floor_color = Color.from_hsv(randf_range(0,360), 0.3, 0.8)

func determine_available_buyables():
	var all = GDict.ingredients.keys()
	var list = []
	for elem in all:
		if GDict.ingredients[elem].has("unpickable"): continue
		list.append(elem)
	available_buyables = list

func load_map():
	create_grid()
	create_pathfinding_map()
	walk_through_grid()
	finish_grid()
	draw_grid()
	add_walls()

func get_bounds():
	return {
		"top_left": Vector2(0,0),
		"bottom_right": Vector2(MAP_SIZE)*CELL_SIZE
	}

func get_total_map_size():
	return MAP_SIZE.x * MAP_SIZE.y

func get_cell_size() -> Vector2i:
	return CELL_SIZE

func get_pos_id(pos : Vector2i) -> int:
	return pos.x + pos.y * MAP_SIZE.x

func get_random_weight() -> float:
	return randf_range(10,20)

func get_grid_visual() -> Array:
	return grid_visual

func get_cell_at(pos : Vector2i) -> Cell:
	if out_of_bounds(pos): return Cell.new(-1, pos)
	return grid[pos.x][pos.y]

func get_cell_for_real_pos(pos : Vector2) -> Cell:
	var idx_x = floor(pos.x / CELL_SIZE.x)
	var idx_y = floor(pos.y / CELL_SIZE.y)
	return get_cell_at(Vector2i(idx_x, idx_y))

func get_cell_for_node(node) -> Cell:
	return get_cell_for_real_pos(node.get_position())

func create_grid():
	grid = []
	grid.resize(MAP_SIZE.x)
	astar = AStar2D.new()
	
	for x in range(MAP_SIZE.x):
		grid[x] = []
		grid[x].resize(MAP_SIZE.y)
		for y in range(MAP_SIZE.y):
			var pos = Vector2i(x,y)
			var id = get_pos_id(pos)
			var c = Cell.new(id, pos)
			grid[x][y] = c
			astar.add_point(id, pos, get_random_weight())
	
	grid_flat = []
	edge_cells = []
	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			grid_flat.append(grid[x][y])
			if is_on_edge(Vector2i(x,y)):
				edge_cells.append(grid[x][y])

func get_grid_flat():
	return grid_flat

func get_edge_cells():
	return edge_cells

func is_on_edge(pos : Vector2i) -> bool:
	return pos.x == 0 or pos.x == (MAP_SIZE.x - 1) or pos.y == 0 or pos.y == (MAP_SIZE.y - 1)

func out_of_bounds(pos : Vector2i) -> bool:
	return pos.x < 0 or pos.x >= MAP_SIZE.x or pos.y < 0 or pos.y >= MAP_SIZE.y

func get_neighbors(cell) -> Array:
	var offsets = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
	var arr = []
	for offset in offsets:
		var pos = cell.grid_pos + offset
		if out_of_bounds(pos): continue
		arr.append(get_cell_at(pos))
	return arr

func shake_non_passthrough_cells(list) -> Array:
	var new_list = []
	for elem in list:
		if not is_passthrough(elem): continue
		new_list.append(elem)
	return new_list

func shake_non_edge_cells(list) -> Array:
	var new_list = []
	for elem in list:
		if not is_on_edge(elem.grid_pos): continue
		new_list.append(elem)
	return new_list

func shake_cells_with_type_assigned(list):
	var new_list = []
	for elem in list:
		if elem.type != Enums.CellType.UNKNOWN: continue
		new_list.append(elem)
	return new_list

func create_pathfinding_map():
	var list = get_grid_flat()
	
	for cell in list:
		var nbs = get_neighbors(cell)
		for nb in nbs:
			astar.connect_points(cell.id, nb.id, true)

func walk_through_grid():
	var too_few_objects = true
	var tries = 0
	var paths_placed = 0
	while too_few_objects:
		tries += 1
		if tries >= MAX_RANDOM_WALK_TRIES: break
		
		var valid_cells = get_edge_cells()
		valid_cells = shake_non_passthrough_cells(valid_cells)
		if valid_cells.size() < 2: break
		
		var edge_cell_1 = valid_cells.pick_random()
		var edge_cell_2 = valid_cells.pick_random()
		
		var use_existing_cells = (paths_placed > 3)
		if use_existing_cells:
			edge_cell_1 = get_entrance()
			edge_cell_2 = get_checkout()
		
		var use_rare_cell = (paths_placed > 4)
		var rare_cells = get_cells_of_type(Enums.CellType.UNKNOWN)
		if use_rare_cell and rare_cells.size() > 0:
			edge_cell_2 = rare_cells.pick_random()
		
		var path = astar.get_point_path(edge_cell_1.id, edge_cell_2.id)
		var too_short = path.size() <= MIN_GENERATION_PATH_LENGTH
		if too_short: continue
		
		paths_placed += 1
		place_objects_next_to_path(path)
		
		var percentage_filled = float(get_cells_of_type(Enums.CellType.BUYABLE).size()) / float(get_total_map_size())
		print(percentage_filled)
		too_few_objects = percentage_filled < MIN_PERCENTAGE_FILLED

func place_objects_next_to_path(path):
	var indices = [0]
	var cur_index = 0
	while cur_index < path.size():
		var rand_jump = randi_range(3,6)
		cur_index += rand_jump
		indices.append(cur_index)
	
	indices.append(path.size() - 1)
	
	# have to do this beforehand, otherwise we might place objects
	# on our OWN path (as that is also a neighbor)
	for i in range(path.size()):
		var cell = get_cell_at(path[i])
		if cell.type == Enums.CellType.UNKNOWN:
			change_cell_type(cell, Enums.CellType.EMPTY)
	
	for i in range(path.size()):
		var place_object = indices.has(i)
		if not place_object: continue
		
		var cell = get_cell_at(path[i])
		var type = Enums.CellType.BUYABLE
		if i == 0 and is_on_edge(cell.grid_pos): 
			type = Enums.CellType.ENTRANCE
		elif i == (path.size() - 1) and is_on_edge(cell.grid_pos): 
			type = Enums.CellType.CHECKOUT
		
		# TODO: generalize this to a "too_many_of_type" function?
		var too_many_entrances = type == Enums.CellType.ENTRANCE and get_cells_of_type(type).size() >= MAX_ENTRANCES
		var too_many_checkouts = type == Enums.CellType.CHECKOUT and get_cells_of_type(type).size() >= MAX_CHECKOUTS
		var too_many_of_type = too_many_entrances or too_many_checkouts
		if too_many_of_type: continue
		
		var changed_cell = place_object_next_to_cell(cell, type)
		if changed_cell.is_invalid(): continue
		
		if is_buyable(changed_cell):
			changed_cell.set_buyable(get_random_buyable())

func finish_grid():
	pass

func turn_random_cell_into_sale_sign():
	print("Wanna turn random cell into sale")
	
	var buyables = get_cells_of_type(Enums.CellType.BUYABLE)
	var sales = get_cells_of_type(Enums.CellType.SALE)
	var types_already_used = []
	for sale in sales:
		types_already_used.append(sale.get_buyable())
	
	var valid_buyables = []
	for buyable in buyables:
		if types_already_used.has(buyable.get_buyable()): continue
		valid_buyables.append(buyable)
	
	if valid_buyables.size() <= 0: return
	
	print("Should turn random cell into sale")
	
	var rand_buyable = valid_buyables.pick_random()
	change_cell_type(rand_buyable, Enums.CellType.SALE)

func get_random_buyable() -> Enums.Item:
	return available_buyables.pick_random()

# TO DO: re-use existing cells from time to time??
func place_object_next_to_cell(cell : Cell, type : Enums.CellType) -> Cell:
	var can_be_same_cell = GDict.cell_types[type].has("passthrough")
	var nbs = get_neighbors(cell)
	nbs = shake_cells_with_type_assigned(nbs)
	
	if can_be_same_cell: 
		nbs = [cell]
		nbs = shake_non_passthrough_cells(nbs)
	
	var needs_edge = GDict.cell_types[type].has("needs_edge")
	if needs_edge: nbs = shake_non_edge_cells(nbs)
	
	if nbs.size() <= 0: return Cell.new()
	
	var nb = nbs.pick_random()
	change_cell_type(nb, type)
	return nb

func change_cell_type(cell : Cell, type : Enums.CellType):
	cell.set_type(type)
	
	if needs_number(cell):
		cell.set_num(randi_range(2,4))

	if is_passthrough(cell):
		astar.set_point_disabled(cell.id, false)
		astar.set_point_weight_scale(cell.id, 0.01)
	else: 
		astar.set_point_disabled(cell.id, true)
	
	if generation_is_done():
		cell.visual.sync_visuals_to_data(self)
	
	emit_signal("cell_changed", cell)

func get_rotation_index_for_edge(cell : Cell) -> int:
	var pos = cell.grid_pos
	if pos.x == 0: return 1
	elif pos.x == (MAP_SIZE.x-1): return -1
	elif pos.y == 0: return 2
	return 0

func is_buyable(cell : Cell) -> bool:
	if cell.is_invalid(): return false
	return GDict.cell_types[cell.type].has("buyable")

func needs_number(cell : Cell) -> bool:
	if cell.is_invalid(): return false
	return GDict.cell_types[cell.type].has("number")

func is_passthrough(cell : Cell) -> bool:
	if cell.is_invalid(): return false
	return GDict.cell_types[cell.type].has("passthrough")

func draw_grid():
	var arr = get_grid_flat()
	grid_visual = []
	for cell in arr:
		var c = cell_scene.instantiate()
		add_child(c)
		grid_visual.append(c)
		
		c.data = cell
		cell.visual = c
		c.sync_visuals_to_data(self)
		transfer_visual_layers(c)

func add_walls():
	var list = []
	for x in range(-1,MAP_SIZE.x+1):
		var pos_top = Vector2i(x, -1)
		var pos_bottom = Vector2i(x, MAP_SIZE.y)
		list.append(Cell.new(-1,pos_top))
		list.append(Cell.new(-1,pos_bottom))
	
	for y in range(MAP_SIZE.y):
		var pos_left = Vector2i(-1, y)
		var pos_right = Vector2i(MAP_SIZE.x, y)
		list.append(Cell.new(-1,pos_left))
		list.append(Cell.new(-1,pos_right))
	
	for elem in list:
		var c = cell_scene.instantiate()
		add_child(c)
		
		elem.set_type(Enums.CellType.WALL)
		c.data = elem
		c.sync_visuals_to_data(self)
		transfer_visual_layers(c)

func transfer_visual_layers(cell):
	for layer in cell.layers:
		var obj = cell.layers[layer]
		var old_transform : Transform2D = obj.global_transform
		cell.remove_child(obj)
		self.layers[layer].add_child(obj)
		obj.global_transform = old_transform

func get_cells_of_type(tp : Enums.CellType):
	var arr = get_grid_flat()
	var list = []
	for cell in arr:
		if cell.type != tp: continue
		list.append(cell)
	
	return list

func get_random_point_on_cell(cell : Cell):
	var rand_x = randf_range(-0.25, 0.25)*CELL_SIZE.x
	var rand_y = randf_range(-0.25, 0.25)*CELL_SIZE.y
	var offset = Vector2(rand_x, rand_y)
	return cell.visual.get_real_pos(CELL_SIZE) + offset

# TODO: we should give TWO points per cell, in opposite halves/quadrants, which would ensure more smooth paths
func get_path_to_cell(from : Cell, to : Cell) -> Array:
	var path = astar.get_point_path(from.id, to.id)
	var path_real = []
	for point in path:
		var cell = get_cell_at(point)
		var real_point = get_random_point_on_cell(cell)
		path_real.append(real_point)
	return path_real

func is_next_to_type(cell : Cell, tp : Enums.CellType) -> bool:
	var nbs = get_neighbors(cell)
	for nb in nbs:
		if nb.type == tp: return true
	return false

func get_buyable_object_around(cell) -> Cell:
	var nbs = get_neighbors(cell)
	var list = []
	for nb in nbs:
		if not is_buyable(nb): continue
		list.append(nb)
	if list.size() <= 0: return Cell.new()
	return list.pick_random()

func get_passthrough_cell_next_to_another(cell):
	var nbs = get_neighbors(cell)
	nbs = shake_non_passthrough_cells(nbs)
	var nb = nbs.pick_random()
	return nb

# TODO: super unsafe, needs checks if things even exist, and retries if not
func get_cell_next_to(type):
	var options = get_cells_of_type(type)
	var option = options.pick_random()
	return get_passthrough_cell_next_to_another(option)

func get_within_manhattan_distance(pos : Vector2i, list : Array, dist : float):
	var valid_list = []
	for elem in list:
		var elem_pos = elem.grid_pos
		var elem_dist = abs(pos.x - elem_pos.x) + abs(pos.y - elem_pos.y)
		if elem_dist > dist: continue
		valid_list.append(elem)
	return valid_list

func get_entrance():
	return get_cells_of_type(Enums.CellType.ENTRANCE).pick_random()

func get_checkout(node = null):
	var all = get_cells_of_type(Enums.CellType.CHECKOUT)
	if node != null:
		var grid_pos = get_cell_for_node(node).grid_pos
		var valid = get_within_manhattan_distance(grid_pos, all, MAX_DIST_TO_CHECKOUT)
		if valid.size() > 0: return valid.pick_random()
	
	return all.pick_random()


		
		
		
		
		
		
		
