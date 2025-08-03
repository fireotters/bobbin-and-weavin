extends NPC

class_name EnemyCat

var can_avoid_enemy := true
@export var follow_distance := 180
@export var pursue_velocity := 200
@export var non_target_speed := 75
var pompom_target: Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

static var targetted_pompoms := []

func _ready() -> void:
	isAlly = false

func _exit_tree() -> void:
	# Well, given it's static, we have to manually clear elements to avoid memory leaks
	if pompom_target != null: targetted_pompoms.erase(pompom_target)

func avoid_group(group: String, target_min : float, target_max: float):
	var enemies := get_tree().get_nodes_in_group(group)
	for enemy in enemies:
		var dir_to_enemy = global_position.direction_to(enemy.global_position)
		var similarity = velocity.normalized().dot(dir_to_enemy)
		
		# So, if the pompom is going towards the enemy (or kinda, I left some threshold) then it will change direction
		# because otherwise this is stupidly unfair
		if similarity > 0.7 and global_position.distance_to(enemy.global_position) < 110 and can_avoid_enemy:
			# There is a change they won't avoid the scissor
			can_avoid_enemy = false
			get_tree().create_timer(0.2).timeout.connect(func(): can_avoid_enemy = true)
					
			var dir_away = dir_to_enemy * -1
			var random_offset = Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)).normalized() * 0.5
			var dir_escape = (dir_away + random_offset).normalized()
			target = global_position + dir_escape * randf_range(target_min, target_max)
			
func _physics_process(_delta: float) -> void:
	avoid_group("enemies", 40, 100)
	
	if randf() < 0.006:
		print("Poor cute pompom, better not hurt it qwp")
		avoid_group("pompoms", 10, 40)
						
	var pompoms := get_tree().get_nodes_in_group("pompoms")
	
	# Check when to stop targetting
	if pompom_target != null and !pompom_target.being_pulled:
		targetted_pompoms.erase(pompom_target)
		pompom_target = null
		animated_sprite_2d.animation = "default"
		$target_lost.play()
		
	
	# Find new target
	if pompom_target == null:
		for pompom in pompoms:
			var distance = global_position.distance_to(pompom.global_position)
			
			if distance < follow_distance and pompom.being_pulled and !targetted_pompoms.has(pompom):
				pompom_target = pompom
				targetted_pompoms.append(pompom)
				$target_adquired.play()
				animated_sprite_2d.animation = "chase"
				print("What")
				break
		# If PomPom is null, but targeted_pompoms still has an entry, and a new one is not found immediately,
		# Then that means that a single PomPom has died while cat is targeting it
		# Perform 'stop targeting' behaviour
		if len(targetted_pompoms) > 0 and pompom_target == null:
			targetted_pompoms.clear()
			animated_sprite_2d.animation = "default"
			$target_lost.play()
			
	if pompom_target != null:
		velocity = velocity.lerp( global_position.direction_to(pompom_target.global_position) * pursue_velocity, 0.08)
	else:
		velocity = velocity.lerp(position.direction_to(target) * non_target_speed, .08)
				
	move_and_slide()
		

func pick_new_random_direction():
	target = PlayerVariables.random_onscreen_coord()

func _on_timer_movement_timeout() -> void:
	pick_new_random_direction()
