extends Control

@onready var label_level_value: Label = %label_level_value
@onready var label_score_value: Label = %label_score_value
@onready var label_death_value: Label = %label_death_value

@onready var panel_pause: CanvasLayer = $panel_pause

func _ready() -> void:
	SignalBus.update_ui.connect(_update_hud)
	_update_hud()

func _update_hud():
	print("HUD updated, signal told us to")
	label_level_value.text = str(PlayerVariables.level)
	label_score_value.text = str(PlayerVariables.pom_rescues)
	label_death_value.text = str(PlayerVariables.pom_deaths)

# Pause dialog
# TODO: consider another way to pause the game, Rioni says this way caused misc problems
func pause():
	Engine.time_scale = 0
	panel_pause.visible = true
	AudioPlayer.pause_music()
func resume():
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
	PlayerVariables.reset_game()
