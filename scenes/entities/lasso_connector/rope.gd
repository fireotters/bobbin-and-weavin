extends Line2D

@export var rope_points := 40
@export var damping := 0.963
@export var tension := 0.741
@export var constraint_iterations := 5

@export_flags_2d_physics var path_collision_layermask := (1 << 1)
@export var particle: PackedScene
@export var rope_collision_enabled := true
var entity: Node2D # Kept as legacy as a toggle for when the rope is enabled

var prev_points := []
var segment_length := 0.0

func last_point_position() -> Vector2: return get_point_position(get_point_count() - 1)

func attach_target(target: Node2D):
	$CapturingSound.play()
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
func _physics_process(_delta: float) -> void:
	if entity == null:
		return
	
	if detect_collision_with_path() && rope_collision_enabled: 
		$RopeBreakSFX.play()
		particles_from_path()
		detach_target()
		return
	
	var start_pos := get_global_mouse_position()
	var last_pos := get_point_position(0)
	
	var clamped_distance := clampf(last_pos.distance_to(start_pos), 0, 50)
	var normalized_distance := inverse_lerp(0, 150, clamped_distance)
	$CapturingSound.pitch_scale = move_toward($CapturingSound.pitch_scale, 0.7 + lerpf(0, 6, normalized_distance), 0.04)
	
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

func detect_collision_with_path() -> bool:
	var shape := SegmentShape2D.new()
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	var _transform := Transform2D()
	params.transform = _transform
	params.collision_mask = path_collision_layermask
	params.collide_with_areas = true
	params.collide_with_bodies = true
	
	for i in range(get_point_count() - 1):
		shape.a = get_point_position(i)
		shape.b = get_point_position(i + 1)
		var result := space_state.intersect_shape(params)
		if result.size() > 0: return true
		
	return false


func is_attached() -> bool: return entity != null

func detach_target():
	$CapturingSound.stop()
	entity = null
	points = []
	prev_points = []
	
	
func particles_from_path():
	for i in range(get_point_count()):
		var new_particle: Sprite2D = particle.instantiate()
		new_particle.global_position = get_point_position(i)
		new_particle.modulate = modulate
		add_child(new_particle)
