extends Control

@export var panel_settings: PackedScene
@onready var high_score_text: RichTextLabel = %HighScoreText


func _ready() -> void:
	# Set version in menu
	var version_text: RichTextLabel = get_node('VersionText')
	version_text.text += ProjectSettings.get_setting('application/config/version', 'none')
	
	# Set high score in menu
	var high_score = ConfigfileHandler.load_high_score_settings()
	if "score" in high_score and high_score["score"] > 0:
		high_score_text.visible = true
		var entry = "Best Score: " + str(high_score["score"])
		if high_score["nickname"] != "":
			entry += "\n(by '" + high_score["nickname"] + "')"
		high_score_text.text = entry
	
	# Check if exit button should be present
	var exit_button: Button = get_node('ButtonContainer/row_bottom/ExitButton')
	if OS.has_feature('web'):
		exit_button.hide()
		
	# Start mainmenu music
	AudioPlayer.play_music__mainmenu()

func _on_exit_button_pressed() -> void:
	# notify other nodes we're trying to quit
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func _on_settings_button_pressed() -> void:
	var settings_scene = panel_settings.instantiate()
	add_child(settings_scene)
