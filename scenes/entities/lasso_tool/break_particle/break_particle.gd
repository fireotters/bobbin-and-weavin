extends Sprite2D

@export var tween_duration := 0.45
@export var up_modifier := 40

func _ready() -> void:
	var tween := get_tree().create_tween().bind_node(self).set_parallel(true)
	tween.tween_property(self, "global_position", global_position + Vector2.UP * up_modifier, tween_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, tween_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)
