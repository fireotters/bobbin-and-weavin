extends Control

@onready var label_score: RichTextLabel = %label_score
@onready var label_level: RichTextLabel = %label_level

func _ready() -> void:
	SignalBus.update_ui.connect(_update_hud)
	_update_hud()

func _update_hud():
	print("HUD updated, signal told us to")
	label_score.text = "Score: " + str(PlayerVariables.score)
	label_level.text = "Level: " + str(PlayerVariables.level)
