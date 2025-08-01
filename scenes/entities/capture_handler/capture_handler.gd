extends Node

func _on_lasso_tool_capture_success(results: Array[Dictionary]) -> void:
	for result in results:
		if "rope_add" in result.collider: result.collider.rope_add()
