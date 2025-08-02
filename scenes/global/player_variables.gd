extends Node

var level = 0
var score = 0

func _ready() -> void:
	# First launch of game
	SignalBus.pompom_lasso.connect(_on_pompom_lasso)
	SignalBus.pompom_capture.connect(_on_pompom_capture)
	
func reset_game():
	level = 0
	score = 0
	AudioPlayer.play_music__level()

func _grant_points(points:int):
	score += points
	SignalBus.update_ui.emit()

func go_to_next_level():
	level += 1

# Signals for in-game events
func _on_pompom_lasso():
	print("PlayerVariables: Lasso success")
func _on_pompom_capture():
	print("PlayerVariables: Capture success. Grant 1 rescue point.")
	_grant_points(1)
	
