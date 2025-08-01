extends Control

@onready var label_score: RichTextLabel = %label_score
@onready var label_level: RichTextLabel = %label_level
@onready var panel_pause: CanvasLayer = $panel_pause

func _ready() -> void:
	SignalBus.update_ui.connect(_update_hud)
	_update_hud()

func _update_hud():
	print("HUD updated, signal told us to")
	label_score.text = "Score: " + str(PlayerVariables.score)
	label_level.text = "Level: " + str(PlayerVariables.level)

# Pause dialog
# TODO: consider another way to pause the game, Rioni says this way caused misc problems
func pause():
	Engine.time_scale = 0
	panel_pause.visible = true
func resume():
	Engine.time_scale = 1
	panel_pause.visible = false

func _on_btn_pause_pressed() -> void:
	pause()
func _input(event):
	if Input.is_action_just_pressed("pause"):
		if panel_pause.visible:
			resume()
		else:
			pause()
			
func _on_btn_resume_pressed() -> void:
	resume()
