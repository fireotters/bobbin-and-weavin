extends Polygon2D

@export var tween_duration := 0.35
@export var scale_modifier := 1.75

func _ready() -> void:
	var tween := get_tree().create_tween().bind_node(self).set_parallel(true)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, tween_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * scale_modifier, tween_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(queue_free)
