extends Node2D

@export var max_line_distance := 500.0
@export var subdivisions := 5 # max num of points the line will have
@onready var point_distance: float = max_line_distance / subdivisions
@onready var line2d: Line2D = $line2d_path

var debug := true

func get_last_pos() -> Vector2: return line2d.to_global(line2d.get_point_position(line2d.get_point_count() -1))

func ccw(A, B, C):
	return (C.y - A.y) * (B.x - A.x) > (B.y - A.y) * (C.x - A.x)

# Return true if line segments AB and CD intersect
func intersect(A, B, C, D) -> bool:
	return ccw(A, C, D) != ccw(B, C, D) and ccw(A, B, C) != ccw(A, B, D)

func has_self_intersection() -> bool:
	var p_count = line2d.get_point_count()
	if p_count < 4: return false

	for i in range(p_count - 1):
		var A = line2d.get_point_position(i)
		var B = line2d.get_point_position(i + 1)

		for j in range(i + 2, p_count - 1):
			var C = line2d.get_point_position(j)
			var D = line2d.get_point_position(j + 1)

			if intersect(A, B, C, D):
				return true

	return false


func handle_line_completion():
	print("Completed area")
	init_new_line()

func init_new_line():
	line2d.clear_points()
	line2d.add_point(get_global_mouse_position()) # This might not work for mobile

func handle_line_creation():
	var current_pos = get_global_mouse_position()
	var last_pos = get_last_pos()

	while last_pos.distance_to(current_pos) >= point_distance:
		line2d.add_point(last_pos + last_pos.direction_to(current_pos) * point_distance)
		
		# If the line is longer than we want, we delete the first point, the rest of the points in the array will shift left
		# Not really efficient, O(n) operation, but given the amount of data we're managing we can allow it
		if line2d.get_point_count() * point_distance > max_line_distance:
			line2d.remove_point(0)
		
		last_pos = get_last_pos()

func _process(_delta: float) -> void:
	has_self_intersection()
	if Input.is_action_just_pressed("pointer_interaction"):
		init_new_line()
	elif Input.is_action_pressed("pointer_interaction"):
		handle_line_creation()
		if(has_self_intersection()): handle_line_completion()
