extends Node

var banks := Array()

func _ready() -> void:
	banks.append(FmodServer.load_bank("res://FMOD/Desktop/Master.strings.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL))
	banks.append(FmodServer.load_bank("res://FMOD/Desktop/Master.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL))
