extends NPC

@export var rope_sprites: Array[Sprite2D] = []
@onready var _timer_recovery: Timer = %timer_recovery

var health_state = 0 # 0 = no damage. 1/2 = partly tied up. 3 = fully tied up
var is_immobilised = false

func _ready() -> void:
	isAlly = false;

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
