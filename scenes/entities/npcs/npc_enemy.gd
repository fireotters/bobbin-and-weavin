extends NPC

# Child Nodes
@export var rope_sprites: Array[Sprite2D] = []
@onready var _timer_recovery: Timer = %timer_recovery
# Health
var health_state = 0 # 0 = no damage. 1/2 = partly tied up. 3 = fully tied up
var is_immobilised = false
# Movement
const movement_wait_times = [3.0, 5.0, 7.0]
const speed = 30

func _ready() -> void:
	isAlly = false;

# Movement
# Helped by Godot docs: https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html#click-and-move
# And Godot forums: https://forum.godotengine.org/t/how-to-make-an-area2d-apears-on-random-position-in-the-screen/20456/2
func _physics_process(_delta: float) -> void:
	var health_modifier = 1.0 - 0.25 * health_state
	velocity = position.direction_to(target) * speed * health_modifier
	if position.distance_to(target) > 10:
		move_and_slide()

func _on_timer_movement_timeout() -> void:
	_choose_new_destination()
	$timer_movement.wait_time = _choose_from_array(movement_wait_times)



# Health States
func damage():
	_timer_recovery.start()
	if health_state < 3:
		print(name + ": I took damage")
		health_state += 1
		_update_ropes()
	if health_state == 3:
		print(name + ": I am now stuck")
		is_immobilised = true
	SignalBus.enemy_died.emit("testEnemy", 10)

func recover():
	if health_state > 0:
		print(name + ": I recovered health")
		is_immobilised = false
		health_state -= 1
		_update_ropes()
	if health_state == 0:
		_timer_recovery.stop()

func _update_ropes():
	for r in rope_sprites:
		r.visible = false

	for i in range(health_state):
		rope_sprites[i-1].visible = true

func _on_timer_recovery_timeout() -> void:
	recover()
