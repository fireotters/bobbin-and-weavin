# written using tutorial from The Shaggy Dev: https://www.youtube.com/watch?v=aFkRmtGiZCw
extends HSlider

@export var bus_name: String
var bus_index: int

const testsound_sfx = preload("res://assets/sfx/universalsoundfx_8bit_retro_jump_glide_up_classic.wav")
var sfxtest_timer = 0
var sfxtest_lastplay = 0

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)
 
func _process(delta: float) -> void:
	sfxtest_timer += delta

func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(new_value)
	)
	
	if bus_name == 'sfx':
		if sfxtest_timer - sfxtest_lastplay > 0.5:
			sfxtest_lastplay = sfxtest_timer
			AudioPlayer.play_FX(testsound_sfx, "FX_SFXTEST", 1.0)
