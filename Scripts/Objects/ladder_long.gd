extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		var enemigos_restantes = get_tree().get_nodes_in_group("Exploding Cube").size()
		if enemigos_restantes == 0:
			# No queda ninguno → pasar de nivel
			GlobalCanvasLayer.change_stage(GlobalCanvasLayer.LEVEL_1)
		else:
			print("Todavía quedan %s enemigos por eliminar." % enemigos_restantes)


func _on_climb_body_entered(body: Node3D) -> void:
	pass


func _on_climb_body_exited(body: Node3D) -> void:
	pass
