extends Node2D

@export var npc_pompom: PackedScene
@export var npc_enemy_scissors: PackedScene
@export var npc_enemy_cat: PackedScene
var max_num_of_pompoms = 12
var max_num_of_enemies = 8
var max_num_of_cats = 5

func _ready() -> void:
	PlayerVariables.reset_game()
	prepare_level()
	SignalBus.level_passed.connect(prepare_level)
	
func prepare_level():
	# Delete contents of old level
	clear_old_level()
	
	# Decide NPC count, based on level number
	var num_of_pompoms = PlayerVariables.level * 3
	if num_of_pompoms > max_num_of_pompoms:
		num_of_pompoms = max_num_of_pompoms
	PlayerVariables.num_of_poms = num_of_pompoms
	PlayerVariables.allowed_max_deaths = int(floor(num_of_pompoms * 0.34))
	var num_of_enemies = PlayerVariables.level * 2
	if num_of_enemies > max_num_of_enemies:
		num_of_enemies = max_num_of_enemies
	var num_of_cats = clamp(1,max_num_of_cats, PlayerVariables.level)
	SignalBus.update_ui.emit()
		
	# Spawn NPCs
	for i in range(0, num_of_enemies):
		var o = npc_enemy_scissors.instantiate()
		o.global_position = PlayerVariables.random_onscreen_coord()
		o.rotation = randf_range(0, 360)
		add_child(o)
	
	for i in range(0, num_of_cats):
		var cat = npc_enemy_cat.instantiate()
		cat.global_position = PlayerVariables.random_onscreen_coord()
		add_child(cat)
		
	for i in range(0, num_of_pompoms):
		var p = npc_pompom.instantiate()
		p.global_position = PlayerVariables.random_onscreen_coord()
		
		# While the pompom collides with an enemy, we'll keep trying to pick a new on_screen coordinate
		var enemies := get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			while enemy.global_position.distance_to(p.global_position) < 100:
				p.global_position = PlayerVariables.random_onscreen_coord()
				
		add_child(p)

func clear_old_level():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		e.queue_free()
	# PomPoms should all be gone by the time level is reset, however this is a failsafe
	var pompoms = get_tree().get_nodes_in_group("pompoms")
	for p in pompoms:
		p.queue_free()
