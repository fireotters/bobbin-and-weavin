extends Node2D

@export var npc_pompom: PackedScene
@export var npc_enemy_scissors: PackedScene
var max_num_of_pompoms = 12
var max_num_of_enemies = 8

func _ready() -> void:
	PlayerVariables.reset_game()
	prepare_next_level()
	
func prepare_next_level():
	# Decide NPC count, based on level number
	var num_of_pompoms = PlayerVariables.level * 3
	if num_of_pompoms > max_num_of_pompoms:
		num_of_pompoms = max_num_of_pompoms
	var num_of_enemies = PlayerVariables.level * 2
	if num_of_enemies > max_num_of_enemies:
		num_of_enemies = max_num_of_enemies
		
	# Spawn NPCs
	for i in range(0, num_of_enemies):
		var o = npc_enemy_scissors.instantiate()
		o.global_position = PlayerVariables.random_onscreen_coord()
		add_child(o)
	for i in range(0, num_of_pompoms):
		var p = npc_pompom.instantiate()
		p.global_position = PlayerVariables.random_onscreen_coord()
		add_child(p)
