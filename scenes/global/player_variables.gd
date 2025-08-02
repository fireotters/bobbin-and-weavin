extends Node

# Level stats
var level = 1
var pom_rescues = 0
var pom_deaths = 0
var num_of_poms = 0
var allowed_max_deaths = 0

# Bounds for the npc spawning & random wandering
const npc_spawnlimit_left = 40
const npc_spawnlimit_right = 1000
const npc_spawnlimit_up = 40
const npc_spawnlimit_down = 600

func _ready() -> void:
	# First launch of game
	SignalBus.pompom_lasso.connect(_on_pompom_lasso)
	SignalBus.pompom_capture.connect(_on_pompom_capture)
	SignalBus.pompom_died.connect(_on_pompom_death)
	
func reset_game():
	level = 1
	pom_rescues = 0
	pom_deaths = 0
	num_of_poms = 0
	allowed_max_deaths = 0
	AudioPlayer.play_music__level()
	SignalBus.level_passed.emit()

func check_level_progress():
	print("LEVEL PROGRESS CHECK: deaths (" + str(pom_deaths) + "), max deaths allowed (" + str(allowed_max_deaths) + ")")
	print("LEVEL PROGRESS CHECK: rescues (" + str(pom_rescues) + "), total poms spawned (" + str(num_of_poms) + ")")
	if pom_deaths > allowed_max_deaths:
		SignalBus.level_death.emit()
	elif pom_rescues + pom_deaths >= num_of_poms:
		level += 1
		pom_rescues = 0
		pom_deaths = 0
		num_of_poms = 0
		allowed_max_deaths = 0
		SignalBus.level_passed.emit()
	SignalBus.update_ui.emit()

# Signals for in-game events
func _on_pompom_lasso():
	print("PlayerVariables: Lasso success")
func _on_pompom_capture():
	print("PlayerVariables: Capture success. Grant 1 rescue point.")
	pom_rescues += 1
	check_level_progress()
func _on_pompom_death():
	print("PlayerVariables: Death happened. Grant 1 death point.")
	pom_deaths += 1
	check_level_progress()
	
# Useful functions
@onready var rng := RandomNumberGenerator.new()
func random_onscreen_coord():
	var rndX = rng.randi_range(PlayerVariables.npc_spawnlimit_left, PlayerVariables.npc_spawnlimit_right)
	var rndY = rng.randi_range(PlayerVariables.npc_spawnlimit_up, PlayerVariables.npc_spawnlimit_down)
	return Vector2(rndX, rndY)
