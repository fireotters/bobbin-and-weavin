extends Node2D

@export var max_line_distance := 500.0
@export var subdivisions := 5 # max num of points the line will have
@onready var point_distance: float = max_line_distance / subdivisions
@onready var line2d: Line2D = $line2d_path



# This should not be here but whatever
@export var area: PackedScene
@export var particle: PackedScene

var intersection_index_a: int
var intersection_index_b: int
var intersection_point: Vector2

func get_last_pos() -> Vector2: return line2d.to_global(line2d.get_point_position(line2d.get_point_count() -1))

# https://stackoverflow.com/questions/3838329/how-can-i-check-if-two-segments-intersect#9997374
func ccw(A, B, C):
	return (C.y - A.y) * (B.x - A.x) > (B.y - A.y) * (C.x - A.x)

# Return true if line segments AB and CD intersect
func intersect(A, B, C, D) -> bool:
	return ccw(A, C, D) != ccw(B, C, D) and ccw(A, B, C) != ccw(A, B, D)

# https://stackoverflow.com/questions/20677795/how-do-i-compute-the-intersection-point-of-two-lines
func find_intersection(A: Vector2, B: Vector2, C: Vector2, D: Vector2):
	var px := ((A.x*B.y - A.y*B.x)*(C.x - D.x) - (A.x - B.x)*(C.x*D.y - C.y*D.x)) / ((A.x - B.x)*(C.y - D.y) - (A.y - B.y)*(C.x - D.x))
	var py := ((A.x*B.y - A.y*B.x)*(C.y - D.y) - (A.y - B.y)*(C.x*D.y - C.y*D.x)) / ((A.x - B.x)*(C.y - D.y) - (A.y - B.y)*(C.x - D.x))
	return Vector2(px, py)

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
				intersection_index_a = i
				intersection_index_b = j
				intersection_point = line2d.to_global(find_intersection(A,B,C,D))
				return true

	return false

func handle_line_completion():
	var vertices := create_pollygon_from_intersection()
	build_area_geometry(vertices)
	detect_collisions(vertices)
	init_new_line()

func detect_collision_with_path() -> bool:
	var shape := SegmentShape2D.new()
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	var _transform := Transform2D()
	params.transform = _transform
	params.collision_mask = (1 << 32) - 1 # detect everything for now
	params.collide_with_areas = true
	params.collide_with_bodies = true
	
	for i in range(line2d.get_point_count() - 1):
		shape.a = line2d.get_point_position(i)
		shape.b = line2d.get_point_position(i + 1)
		var result := space_state.intersect_shape(params)
		if result.size() > 0: return true
		
	return false

func detect_collisions(vertices: PackedVector2Array):
	var shape := ConvexPolygonShape2D.new()
	shape.set_point_cloud(vertices)
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	var _transform := Transform2D()
	params.transform = _transform
	params.collision_mask = 1 # only detect enemies
	params.collide_with_areas = true
	params.collide_with_bodies = true
	var result := space_state.intersect_shape(params)
	if result.size() > 0:
		for i in range(result.size()):
			result[i].collider.damage()
			print("Collided with ", result[i].collider)
	else:
		print("No collisions")
	

# https://en.wikipedia.org/wiki/Centroid
# Used "Of a finite set of points"
func calculate_pollygon_centroid(polygon: PackedVector2Array) -> Vector2:
	var x_acc: float = 0
	var y_acc: float = 0
	for vec in polygon:
		x_acc += vec.x
		y_acc += vec.y
	
	return Vector2(x_acc, y_acc) / polygon.size()

func create_pollygon_from_intersection() -> PackedVector2Array:
	var vertices : PackedVector2Array
	
	vertices.append(intersection_point)
	for i in range(intersection_index_a + 1, intersection_index_b):
		vertices.append(line2d.get_point_position(i))
	
	return vertices

func build_area_geometry(vertices: PackedVector2Array):
	var new_area:Polygon2D = area.instantiate()
	new_area.global_position = calculate_pollygon_centroid(vertices)
	new_area.offset = -new_area.global_position
	new_area.set_polygon(vertices)
	add_child(new_area)
	pass

func init_new_line():
	line2d.clear_points()
	line2d.add_point(get_global_mouse_position()) # This might not work for mobile

func handle_path_break(): 
	# I will copy pokemon ranger here too because why not, I love adding quick juice
	# When the line breaks, well spawn point particles that go up
	if line2d.get_point_count() > 3:
		particles_from_path()

	line2d.clear_points()
	# Here we should raise an event to play a sound to reflect the collision


func particles_from_path():
	for i in range(line2d.get_point_count()):
		var new_particle: Sprite2D = particle.instantiate()
		new_particle.global_position = line2d.get_point_position(i)
		add_child(new_particle)

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
	if Input.is_action_just_pressed("pointer_interaction"):
		init_new_line()
	elif Input.is_action_pressed("pointer_interaction") and line2d.get_point_count() > 0:
		if detect_collision_with_path(): handle_path_break()
		else:
			handle_line_creation()
			if(has_self_intersection()): handle_line_completion()
	elif Input.is_action_just_released("pointer_interaction"):
		line2d.clear_points()
		
