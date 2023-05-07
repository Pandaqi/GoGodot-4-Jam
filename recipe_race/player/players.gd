extends Node3D

func activate():
	# TODO: actually _place_ these, instead of reading them
	var players = get_tree().get_nodes_in_group("Players")
	for p in players:
		p.activate()
