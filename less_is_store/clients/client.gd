extends CharacterBody2D

var map
@onready var main_node = get_node("/root/Main")
@onready var modules = {
	"state": $State,
	"path_walker": $PathWalker,
	"visuals": $Visuals,
	"backpack": $Backpack,
	"knockback": $Knockback
}

signal score(client)
signal removed(client)

func get_mod(key):
	if modules.has(key): return modules[key]
	print("Module with key " + key + " doesn't exist on Client node")
	return null

func activate(map):
	self.map = map
	modules.state.activate()
	modules.backpack.activate()

func remove():
	self.queue_free()
	self.remove_from_group("Clients")
	emit_signal("removed", self)

func give_feedback(txt:String):
	main_node.get_mod("feedback").add_for_node(self, { "text": txt })
