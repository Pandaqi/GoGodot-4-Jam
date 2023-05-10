extends CharacterBody2D

var map
@onready var modules = {
	"state": $State,
	"path_walker": $PathWalker,
	"visuals": $Visuals,
	"backpack": $Backpack
}

signal score(client)
signal removed

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on Client node")
	return null

func activate(map):
	self.map = map
	modules.state.activate()
	modules.backpack.activate()

func remove():
	emit_signal("removed")
	self.queue_free()
