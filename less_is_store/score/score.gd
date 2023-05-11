extends Node2D

var score : int = 0

signal score_changed(new_score)

func activate():
	change(0)

func change(ds : int):
	score += ds
	print("SCORE: " + str(score))
	emit_signal("score_changed", score)

func too_high():
	return score >= GDict.cfg.max_score
