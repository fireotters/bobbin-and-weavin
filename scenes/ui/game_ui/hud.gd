extends Control

@onready var label_level_value: Label = %label_level_value
@onready var label_remaining_value: Label = %label_remaining_value
@onready var label_rescued_value: Label = %label_rescued_value

@onready var panel_pause: CanvasLayer = $panel_pause
@onready var panel_gameover: CanvasLayer = $panel_gameover

var game_is_over = false

func _ready() -> void:
	SignalBus.update_ui.connect(_update_hud)
	SignalBus.level_death.connect(_game_over)
	_update_hud()

func _update_hud():
	print("HUD updated, signal told us to")
	label_level_value.text = str(PlayerVariables.level)
	label_remaining_value.text = str(
		PlayerVariables.num_of_poms - PlayerVariables.pom_rescues - PlayerVariables.pom_deaths
		)
	label_rescued_value.text = str(PlayerVariables.pom_rescues) + "/" + str(PlayerVariables.num_of_poms - PlayerVariables.allowed_max_deaths)


# -------------------------------------
# Pause dialog
# -------------------------------------
func pause():
	if not game_is_over:
		Engine.time_scale = 0
		panel_pause.visible = true
		AudioPlayer.pause_music()
func resume():
	if not game_is_over:
		Engine.time_scale = 1
		panel_pause.visible = false
		AudioPlayer.resume_music()

func _on_btn_pause_pressed() -> void:
	pause()
func _input(_event):
	if Input.is_action_just_pressed("pause"):
		if panel_pause.visible:
			resume()
		else:
			pause()
			
func _on_btn_resume_pressed() -> void:
	resume()
func _on_btn_restart_pressed() -> void:
	AudioPlayer.stop()
	PlayerVariables.reset_game()

# -------------------------------------
# Game Over
# -------------------------------------
func _game_over():
	game_is_over = true
	Engine.time_scale = 0
	panel_gameover.visible = true
	AudioPlayer.pause_music()
