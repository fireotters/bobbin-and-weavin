# written using tutorial from Soma Animus: https://www.youtube.com/watch?v=lILnUD3xph8
extends AudioStreamPlayer

# music tracks. Set OGG import settings to 'Loop'
const mainmenu_music = preload("res://assets/music/incompetech__menumusic__mischief_maker.ogg")
const tutorial_music = preload("res://assets/music/incompetech__tutorialmusic__derp_nugget.ogg")
const level_music = preload("res://assets/music/incompetech__levelmusic__march_of_the_spoons.ogg")
const saved_pompom_sound := preload("res://assets/sfx/Coin 6.wav")
const dead_sound_pompom := preload("res://assets/sfx/hit-2.wav")
const collision_sound_pompom := preload("res://assets/sfx/hit-2.wav")

# -------------------------------------
# Music
# -------------------------------------
func _ready():
	bus = "music"
	
func _play_music(music: AudioStream):
	if stream == music:
		return
	stream = music
	play()
	
func play_music__mainmenu():
	stream_paused = false
	_play_music(mainmenu_music)

func play_music__level():
	stream_paused = false
	_play_music(level_music)

func pause_music():
	stream_paused = true
func resume_music():
	stream_paused = false
	

# -------------------------------------
# SFX Summoning
# -------------------------------------
func play_FX(fx_stream: AudioStream, fx_name:String = "FX_UNNAMED", volume_modifier:float = 1.0):
	var fx_player = AudioStreamPlayer.new()
	fx_player.stream = fx_stream
	fx_player.name = fx_name
	fx_player.bus = "sfx"
	fx_player.volume_linear *= volume_modifier # if a sfx needs to be played quieter or louder
	add_child(fx_player)
	fx_player.play()
	
	# delete when done
	await fx_player.finished
	fx_player.queue_free()
	
func play_sound_pompom_saved():
	play_FX(saved_pompom_sound, "saved_pompom_sound")

func play_sound_pompom_dead():
	play_FX(dead_sound_pompom, "dead_sound_pompom")
	pass

func play_sound_pompom_collision():
	play_FX(collision_sound_pompom, "collision_sound_pompom")
	pass
