extends HSlider

@export var bus_name: String
var bus_index: int

const testsound_sfx = preload("res://assets/sfx/Action Misc 4.wav")
var sfxtest_timer = 0
var sfxtest_lastplay = 0
 
func _process(delta: float) -> void:
	sfxtest_timer += delta

func _on_value_changed(_new_value: float) -> void:
	if sfxtest_timer - sfxtest_lastplay > 0.35:
		sfxtest_lastplay = sfxtest_timer
		AudioPlayer.play_FX(testsound_sfx, "FX_SFXTEST", 1.0)
