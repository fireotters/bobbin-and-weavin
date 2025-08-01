extends Line2D

@export var rope_points := 40
@export var damping := 0.963
@export var tension := 0.741
@export var constraint_iterations := 5

var entity: Node2D # Kept as legacy as a toggle for when the rope is enabled

var prev_points := []
var segment_length := 0.0

func last_point_position() -> Vector2: return get_point_position(get_point_count() - 1)

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
	
	# Verlet integration
	for i in range(1, rope_points):
		var velocity = (get_point_position(i) - prev_points[i]) * damping
		prev_points[i] = get_point_position(i)
		points[i] += velocity
	
	# First point is a fixed anchor. 
	# Ideally I should make anchors optinal but well, game jam momento xD
	points[0] = start_pos
	
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
			
			points[i + 1] -= correction * 0.5

func detach_target():
	entity = null
	points = []
	prev_points = []
