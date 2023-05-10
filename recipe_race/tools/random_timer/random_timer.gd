extends Node

var base_cfg = { 
	"min": 1.0, 
	"max": 5.0,
	"autostart": false
}

var cfg = {}

@onready var timer = $Timer

signal timeout

func activate(config = {}):
	cfg = config # TODO: only override known keys on base_cfg
	if cfg.autostart: _on_timer_timeout()
	else: restart_timer()

func stop():
	timer.stop()

func restart_timer():
	timer.stop()
	timer.wait_time = randf_range(cfg.min, cfg.max)
	timer.start()

func _on_timer_timeout():
	emit_signal("timeout")
	restart_timer()
