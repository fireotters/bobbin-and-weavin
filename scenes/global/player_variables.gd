extends Node

var level = 0
var score = 0

func _ready() -> void:
	# First launch of game
	SignalBus.pompom_lasso.connect(_on_pompom_lasso)
	
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
func _on_pompom_lasso(points):
	print("PlayerVariables: Lasso success. Grant '" + str(points) + "' points.")
	_grant_points(points)
	
