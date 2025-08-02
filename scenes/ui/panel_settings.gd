extends Control

@onready var subpanel_audio = get_node("%subpanel_audio")
@onready var subpanel_video = get_node("%subpanel_video")
@onready var subpanel_game = get_node("%subpanel_game")
@onready var slider_master: HSlider = %slider_master
@onready var slider_music: HSlider = %slider_music
@onready var slider_sfx: HSlider = %slider_sfx
@onready var cbox_fullscreen: CheckBox = %cbox_fullscreen

func _ready() -> void:
	# By default, show audio settings first
	_on_btn_audio_pressed()
	# Load settings from ConfigFile
	var audio_settings = ConfigfileHandler.load_audio_settings()
	slider_master.value = audio_settings.master_volume
	slider_music.value = audio_settings.music_volume
	slider_sfx.value = audio_settings.sfx_volume
	var video_settings = ConfigfileHandler.load_video_settings()
	cbox_fullscreen.button_pressed = video_settings.fullscreen


# Select which settings pane to open
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


# Settings functionality
func _on_cbox_fullscreen_toggled(toggled_on: bool) -> void:
	ConfigfileHandler.save_video_setting("fullscreen", toggled_on)
	ConfigfileHandler.apply_video_settings()

func _on_slider_master_value_changed(value: float) -> void:
	ConfigfileHandler.save_audio_setting("master_volume", value)
	ConfigfileHandler.apply_audio_settings()

func _on_slider_music_value_changed(value: float) -> void:
	ConfigfileHandler.save_audio_setting("music_volume", slider_music.value)
	ConfigfileHandler.apply_audio_settings()

func _on_slider_sfx_value_changed(value: float) -> void:
	ConfigfileHandler.save_audio_setting("sfx_volume", slider_sfx.value)
	ConfigfileHandler.apply_audio_settings()
