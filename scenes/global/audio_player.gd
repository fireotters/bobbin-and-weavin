# written using tutorial from Soma Animus: https://www.youtube.com/watch?v=lILnUD3xph8
extends AudioStreamPlayer

# music tracks. Set OGG import settings to 'Loop'
const mainmenu_music = preload("res://assets/music/ultimategamemusiccollection_title_piano_loop.ogg")
const level_music = preload("res://assets/music/ultimategamemusiccollection_jungle_2_loop.ogg")

# sound play functions
func _ready():
	bus = "music"
	
func _play_music(music: AudioStream):
	if stream == music:
		return
	stream = music
	play()
	
func play_music__mainmenu():
	_play_music(mainmenu_music)
	
func play_music__level():
	_play_music(level_music)

func play_FX(stream: AudioStream, name:String = "FX_UNNAMED", volume_modifier:float = 1.0):
	var fx_player = AudioStreamPlayer.new()
	fx_player.stream = stream
	fx_player.name = name
	fx_player.bus = "sfx"
	fx_player.volume_linear *= volume_modifier # if a sfx needs to be played quieter or louder
	add_child(fx_player)
	fx_player.play()
	
	# delete when done
	await fx_player.finished
	fx_player.queue_free()
