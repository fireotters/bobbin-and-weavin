extends Control

@export var panel_settings: PackedScene

func _ready() -> void:
	# Set version in menu
	var version_text: RichTextLabel = get_node('VersionText')
	version_text.text += ProjectSettings.get_setting('application/config/version', 'none')
	
	# Check if exit button should be present
	var exit_button: Button = get_node('ButtonContainer/ExitButton')
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
