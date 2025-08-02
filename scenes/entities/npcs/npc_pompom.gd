extends NPC

# Child Nodes
@export var rope_sprites: Array[Sprite2D] = []
@onready var _timer_rope_remove: Timer = %timer_rope_remove
@onready var _capturefailgiggle: Label = $Sprite2D/capturefailgiggle
@onready var _timer_capturefail: Timer = $timer_capturefail


# Health
var rope_state = -1 # -1 = no ropes attached. 0/1 = partly tied up. 2 = fully tied up
# Movement
const movement_wait_times = [3.0, 5.0, 7.0]
const speed = 30

@export_flags_2d_physics var enemy_layermask := (1 << 1)
@export_flags_2d_physics var box_layermask := (1 << 2)
# Extra time that the entity will be able to collide with the
# bpx after being released from the pull
@export var inertia_time:= 1.0

@export var life_points := 2

var being_pulled := false
@export var on_release_inertia_multiplier := 40

@export var collision_repulse_force_multiplier := 900

func _ready() -> void:
	isAlly = true;
	collision_mask = enemy_layermask


# -------------------------------------
# Movement (random movement & while being pulled)
# -------------------------------------
# Helped by Godot docs: https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html#click-and-move
# And Godot forums: https://forum.godotengine.org/t/how-to-make-an-area2d-apears-on-random-position-in-the-screen/20456/2
func _physics_process(delta: float) -> void:
	if !being_pulled:
		var health_modifier = 1.0 - 0.25 * rope_state
		velocity = velocity.lerp(position.direction_to(target) * speed * health_modifier, .08)
		if position.distance_to(target) > 10:
			do_movement(delta)
	else:
		if !$Rope.is_attached():
			stop_pulling()
			return
		
		var rope_last = $Rope.last_point_position()
		if Input.is_action_just_released("pointer_interaction"): 
			$Rope.detach_target()
			stop_pulling()
		else:
			# This is like doing global_position = rope_last but with physics
			var delta_pos = rope_last - global_position
			velocity = delta_pos / delta
			do_movement(delta)

func stop_pulling():
	$Rope.detach_target()
	being_pulled = false
	_timer_rope_remove.start() # resume struggle-free mechanic
	
	# Start timer to restore box layermask
	get_tree().create_timer(inertia_time).timeout.connect(func(): if !being_pulled: collision_mask = enemy_layermask)

func do_movement(delta: float):
	var collision := move_and_collide(velocity * delta)
	if collision != null:
		var entity := collision.get_collider()
		if entity is NPC && "isAlly" in entity && !entity.isAlly:
			handle_collision_with_enemy(collision)
		if entity is PompomBox:
			handle_collision_with_box(collision)

# -------------------------------------
# Collisions
# -------------------------------------
func handle_collision_with_box(_collision: KinematicCollision2D):
	print("I have been freed, Yippee!")
	SignalBus.pompom_capture.emit()
	queue_free()

func handle_collision_with_enemy(collision: KinematicCollision2D):
	life_points -= 1
	
	print("Collided, I have now " ,life_points)
	if life_points <= 0:
		SignalBus.pompom_died.emit()
		queue_free()
		return
	
	$Rope.detach_target()
	being_pulled = false
	velocity = collision.get_normal() * collision_repulse_force_multiplier
	move_and_slide()

func _on_timer_movement_timeout() -> void:
	target = PlayerVariables.random_onscreen_coord()
	$timer_movement.wait_time = _choose_from_array(movement_wait_times)

# -------------------------------------
# Rope States
# -------------------------------------
func rope_add():
	_timer_rope_remove.start()
	if rope_state < 2:
		rope_state += 1
		print(name + ": I have been tied up! State: " + str(rope_state))
		_update_ropes()
		SignalBus.pompom_lasso.emit()

func rope_remove():
	if rope_state > -1:
		rope_state -= 1
		print(name + ": I've removed a rope! State: " + str(rope_state))
		_update_ropes()
	if rope_state == -1:
		_timer_rope_remove.stop()

func _update_ropes():
	for r in rope_sprites:
		r.visible = false

	if rope_state > -1:
		rope_sprites[rope_state].visible = true

func _on_timer_rope_remove_timeout() -> void:
	if not being_pulled:
		rope_remove()


# -------------------------------------
# Pickup & Rescue
# -------------------------------------
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# TODO: Ensure this actually works for touchscreen!
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or event is InputEventScreenTouch:
		if event.pressed:
			if rope_state == 2:
				being_pulled = true
				_timer_rope_remove.stop() # pompom will not struggle free while being pulled
				collision_mask |= box_layermask
				$Rope.attach_target(self)
			else:
				print(name + ": Hehe, you can't capture me yet!")
				_capturefailgiggle.visible = true
				_timer_capturefail.start()
			
func _on_timer_capturefail_timeout() -> void:
	_capturefailgiggle.visible = false
