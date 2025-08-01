extends Line2D

@export var rope_points := 40
@export var damping := 0.95
@export var tension := 0.5
@export var constraint_iterations := 5

var entity: Node2D

var prev_points := []
var segment_length := 0.0

func attach_target(target: Node2D):
	entity = target
	points = []
	prev_points = []
	
	# Lengh
	var start_pos := get_global_mouse_position()
	var end_pos := entity.global_position
	var total_length = start_pos.distance_to(end_pos)
	segment_length = total_length / (rope_points - 1)
	
	# State initialization
	for i in range(rope_points):
		var t = float(i) / (rope_points - 1)
		var pos = start_pos.lerp(end_pos, t)
		add_point(pos)
		prev_points.append(pos)

# Resources: 
# https://toqoz.fyi/game-rope.html
# https://www.youtube.com/watch?v=MeFZbiJM8zo
func _physics_process(delta: float) -> void:
	if entity == null:
		return
	
	var start_pos := get_global_mouse_position()
	var end_pos := entity.global_position
	
	# Verlet integration
	for i in range(1, rope_points - 1):
		var velocity = (get_point_position(i) - prev_points[i]) * damping
		prev_points[i] = get_point_position(i)
		points[i] += velocity
	
	# Given the entity and the mouse are fixed position we fix it her
	# I'm not sure if this is the correct way to handle that but eh, it works
	points[0] = start_pos
	points[rope_points - 1] = end_pos
	
	# Distance contraint
	for _iter in range(constraint_iterations):
		for i in range(0, rope_points - 1):
			var vec = points[i + 1] - get_point_position(i)
			var dist = vec.length()
			var error = dist - segment_length
			var correction = vec.normalized() * error * tension
			
			# Ignoring extremes again.
			if i > 0:
				points[i] += correction * 0.5
			if i < rope_points - 2:
				points[i + 1] -= correction * 0.5
	

func detach_target():
	entity = null
	points = []
	prev_points = []
