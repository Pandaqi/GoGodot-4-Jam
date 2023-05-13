class_name Cell

var id : int
var grid_pos : Vector2i
var type : Enums.CellType = Enums.CellType.UNKNOWN
var buyable : Enums.Item
var number : int = -1

var visual

func _init(new_id = -1, new_grid_pos = Vector2i(0,0)):
	id = new_id
	grid_pos = new_grid_pos

func set_type(t : Enums.CellType):
	type = t

func set_buyable(b : Enums.Item):
	buyable = b

func get_buyable() -> Enums.Item:
	return buyable

func set_num(i):
	number = i

func get_num() -> int:
	return number

func is_invalid() -> bool:
	return id < 0

func get_backpack_version():
	return { "type": type, "buyable": buyable }
