class_name Cell

var id : int
var grid_pos : Vector2i
var type : Enums.CellType = Enums.CellType.UNKNOWN
var buyable : String = ""
var visual

func _init(id = -1, grid_pos = Vector2i(0,0)):
	self.id = id
	self.grid_pos = grid_pos

func set_type(t : Enums.CellType):
	type = t

func set_buyable(b : String):
	buyable = b

func is_invalid() -> bool:
	return id < 0

func get_backpack_version():
	return { "type": type, "buyable": buyable }
