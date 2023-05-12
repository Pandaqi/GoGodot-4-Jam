extends Node2D

var base_config = { "onoff": false, "volume": 0, "autoplay": true, "stream": null, "dir": null, "pitch_variation": 0.075 }
var config = {}
var cache = {}
@onready var player : AudioStreamPlayer2D = $Player

signal finished

func activate(cfg):
	for key in base_config:
		config[key] = base_config[key]
	
	for key in cfg:
		config[key] = cfg[key]
	
	player.volume_db = config.volume
	player.autoplay = config.autoplay
	if config.stream: player.stream = config.stream
	
	cache_audio()

func cache_audio():
	if config.dir == null: return
	
	var dir = DirAccess.open(config.dir)
	if dir == null:
		print("No correct audio player folder!")
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir(): continue
		if file_name.get_extension() != "ogg": 
			file_name = dir.get_next()
			continue
		
		var file_name_no_ext = file_name.get_basename()
		cache[file_name_no_ext] = load(config.dir + "/" + file_name)
		file_name = dir.get_next()

func play_from_list(list):
	var rand = list.pick_random()
	play(cache[rand])

func play(stream_resource = null):
	if config.onoff and player.is_playing(): return
	
	player.pitch_scale = 1.0 + randf_range(-1,1) * config.pitch_variation
	if stream_resource: player.stream = stream_resource
	player.play()

func stop():
	player.stop()

func _on_player_finished():
	if config.onoff: play()
	emit_signal("finished")
