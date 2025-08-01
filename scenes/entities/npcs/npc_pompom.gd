extends NPC

# Child Nodes
@export var rope_sprites: Array[Sprite2D] = []
@onready var _timer_rope_remove: Timer = %timer_rope_remove
# Health
var rope_state = -1 # -1 = no ropes attached. 0/1 = partly tied up. 2 = fully tied up
var is_immobilised = false
# Movement
const movement_wait_times = [3.0, 5.0, 7.0]
const speed = 30

var being_pulled := false
@export var pull_force := .4
@export var distance_influence := .4

func _ready() -> void:
	isAlly = true;

# Movement
# Helped by Godot docs: https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html#click-and-move
# And Godot forums: https://forum.godotengine.org/t/how-to-make-an-area2d-apears-on-random-position-in-the-screen/20456/2
func _physics_process(_delta: float) -> void:
	if !being_pulled:
		var health_modifier = 1.0 - 0.25 * rope_state
		velocity = velocity.lerp(position.direction_to(target) * speed * health_modifier, .08)
		if position.distance_to(target) > 10:
			move_and_slide()
	else:
		if Input.is_action_just_released("pointer_interaction"): 
			$Rope.detach_target()
			being_pulled = false
		
		velocity += global_position.direction_to(get_global_mouse_position()) * pull_force * (distance_influence * global_position.distance_to(get_global_mouse_position()))
		move_and_slide()

func _on_timer_movement_timeout() -> void:
	_choose_new_destination()
	$timer_movement.wait_time = _choose_from_array(movement_wait_times)



# Rope States
func rope_add():
	_timer_rope_remove.start()
	if rope_state < 2:
		print(name + ": I took damage")
		rope_state += 1
		_update_ropes()
	if rope_state == 3:
		print(name + ": I am now stuck")
		is_immobilised = true
	SignalBus.pompom_lasso.emit(5)

func rope_remove():
	if rope_state > -1:
		print(name + ": I recovered health")
		is_immobilised = false
		rope_state -= 1
		_update_ropes()
	if rope_state == -1:
		_timer_rope_remove.stop()

func _update_ropes():
	for r in rope_sprites:
		r.visible = false

	if rope_state > -1:
		rope_sprites[rope_state].visible = true

func _on_timer_rope_remove_timeout() -> void:
	if not is_immobilised:
		rope_remove()


# Pickup & Rescue
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# TODO: Ensure this actually works for touchscreen!
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or event is InputEventScreenTouch:
		if event.pressed:
			if rope_state == 2:
				is_immobilised = true
				# TODO: Handle the capturing game mechanic. For now, clicking a tied-up pompom will capture them
				SignalBus.pompom_capture.emit(100)
				being_pulled = true
				$Rope.attach_target(self)
				#print(name + ": *was Thanos snapped*")
				#queue_free()
			else:
				print(name + ": Hehe, you can't capture me yet!")
				$Sprite2D/temp_capturefailgiggle.visible = true
				await get_tree().create_timer(1).timeout
				$Sprite2D/temp_capturefailgiggle.visible = false
			
