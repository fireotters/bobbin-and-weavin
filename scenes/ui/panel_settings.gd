extends Control

@onready var subpanel_audio = get_node("%subpanel_audio")
@onready var subpanel_video = get_node("%subpanel_video")
@onready var subpanel_game = get_node("%subpanel_game")

func _ready() -> void:
	_on_btn_audio_pressed() # By default, show audio settings first

func _on_btn_audio_pressed() -> void:
	subpanel_audio.visible = true
	subpanel_video.visible = false
	subpanel_game.visible = false

func _on_btn_video_pressed() -> void:
	subpanel_audio.visible = false
	subpanel_video.visible = true
	subpanel_game.visible = false

func _on_btn_game_pressed() -> void:
	subpanel_audio.visible = false
	subpanel_video.visible = false
	subpanel_game.visible = true

func _on_btn_back_pressed() -> void:
	queue_free() # close panel
