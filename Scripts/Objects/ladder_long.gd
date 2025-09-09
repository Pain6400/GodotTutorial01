extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		GlobalCanvasLayer.change_stage(GlobalCanvasLayer.LEVEL_1)
