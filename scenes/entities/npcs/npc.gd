extends CharacterBody2D
class_name NPC

var isAlly = true;

@onready var screenSize = get_viewport().get_visible_rect().size
var target = position

func _choose_new_destination():
	var rng = RandomNumberGenerator.new()
	var rndX = rng.randi_range(0, screenSize.x)
	var rndY = rng.randi_range(0, screenSize.y)
	target = Vector2(rndX, rndY)

func _choose_from_array(array):
	return array.pick_random()
