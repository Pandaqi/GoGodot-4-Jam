extends Node2D

@onready var body = get_parent()
#const AUDIO_CONFIG = { "dir": "res://less_is_store/player/sounds" }
@onready var audio_player = $AudioPlayer

func _ready():
	pass
	#audio_player.activate(AUDIO_CONFIG)

func receive(data):
	#audio_player.play_from_list(["powerup_1", "powerup_2"])
	audio_player.pitch_scale = 1.0 + randf_range(-0.05, 0.05)
	audio_player.play()
	
	if data.type == "dash":
		body.get_mod("mover").change_dash_meter(+1)
