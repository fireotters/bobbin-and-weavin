extends NPC

# Child Nodes
@export var rope_sprites: Array[Sprite2D] = []
@onready var _timer_recovery: Timer = %timer_recovery
# Health
var rope_state = -1 # -1 = no ropes attached. 0/1 = partly tied up. 2 = fully tied up
var is_immobilised = false
# Movement
const movement_wait_times = [3.0, 5.0, 7.0]
const speed = 30

func _ready() -> void:
	isAlly = true;

# Movement
# Helped by Godot docs: https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html#click-and-move
# And Godot forums: https://forum.godotengine.org/t/how-to-make-an-area2d-apears-on-random-position-in-the-screen/20456/2
func _physics_process(_delta: float) -> void:
	var health_modifier = 1.0 - 0.25 * rope_state
	velocity = position.direction_to(target) * speed * health_modifier
	if position.distance_to(target) > 10:
		move_and_slide()

func _on_timer_movement_timeout() -> void:
	_choose_new_destination()
	$timer_movement.wait_time = _choose_from_array(movement_wait_times)



# Health States
func damage():
	_timer_recovery.start()
	if rope_state < 2:
		print(name + ": I took damage")
		rope_state += 1
		_update_ropes()
	if rope_state == 3:
		print(name + ": I am now stuck")
		is_immobilised = true
	SignalBus.enemy_died.emit("testEnemy", 10)

func recover():
	if rope_state > -1:
		print(name + ": I recovered health")
		is_immobilised = false
		rope_state -= 1
		_update_ropes()
	if rope_state == -1:
		_timer_recovery.stop()

func _update_ropes():
	for r in rope_sprites:
		r.visible = false

	if rope_state > -1:
		rope_sprites[rope_state].visible = true

func _on_timer_recovery_timeout() -> void:
	recover()
