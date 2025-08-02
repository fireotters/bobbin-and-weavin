# Helped by guide from DashNothing: https://www.youtube.com/watch?v=tfqJjDw0o7Y
extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("audio", "master_volume", 0.5)
		config.set_value("audio", "music_volume", 0.5)
		config.set_value("audio", "sfx_volume", 0.5)
		config.set_value("video", "fullscreen", false)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
	# On launch, apply settings
	apply_audio_settings()
	apply_video_settings()

# Save, load, apply settings
func save_audio_setting(key:String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)
func save_video_setting(key:String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings
func load_video_settings():
	var video_settings = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings

func apply_audio_settings():
	var audio_settings = load_audio_settings()
	AudioServer.set_bus_volume_db(0, linear_to_db(audio_settings.master_volume))
	AudioServer.set_bus_volume_db(1, linear_to_db(audio_settings.music_volume))
	AudioServer.set_bus_volume_db(2, linear_to_db(audio_settings.sfx_volume))
	
func apply_video_settings():
	var video_settings = load_video_settings()
	print("Video settings - not implemented")
