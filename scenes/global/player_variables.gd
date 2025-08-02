extends Node

var level = 0
var pom_rescues = 0
var pom_deaths = 0
var max_poms = 0

# Bounds for the npc spawning & random wandering
const npc_spawnlimit_left = 40
const npc_spawnlimit_right = 1000
const npc_spawnlimit_up = 40
const npc_spawnlimit_down = 600

func _ready() -> void:
	# First launch of game
	SignalBus.pompom_lasso.connect(_on_pompom_lasso)
	SignalBus.pompom_capture.connect(_on_pompom_capture)
	
func reset_game():
	level = 1
	pom_rescues = 0
	pom_deaths = 0
	AudioPlayer.play_music__level()

func _grant_rescues(points:int):
	pom_rescues += points
	SignalBus.update_ui.emit()

func go_to_next_level():
	level += 1

# Signals for in-game events
func _on_pompom_lasso():
	print("PlayerVariables: Lasso success")
func _on_pompom_capture():
	print("PlayerVariables: Capture success. Grant 1 rescue point.")
	_grant_rescues(1)
	
# Useful functions
func random_onscreen_coord():
	var rng = RandomNumberGenerator.new()
	var rndX = rng.randi_range(PlayerVariables.npc_spawnlimit_left, PlayerVariables.npc_spawnlimit_right)
	var rndY = rng.randi_range(PlayerVariables.npc_spawnlimit_up, PlayerVariables.npc_spawnlimit_down)
	return Vector2(rndX, rndY)
