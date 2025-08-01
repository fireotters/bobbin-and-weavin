extends Node

var level = 0
var score = 0

func _ready() -> void:
	# First launch of game
	SignalBus.enemy_died.connect(_on_enemy_died)
	
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
func _on_enemy_died(enemyType:String, points:int):
	print("Hey, '" + enemyType + "' died. Let's grant '" + str(points) + "' points.")
	_grant_points(points)
	
