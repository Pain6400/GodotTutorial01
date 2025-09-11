extends Node3D

@onready var climb_area: Area3D = $ladder/Climb

		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		var enemigos_restantes = get_tree().get_nodes_in_group("Exploding Cube").size()
		if enemigos_restantes == 0:
			# No queda ninguno → pasar de nivel
			GlobalCanvasLayer.change_stage(GlobalCanvasLayer.LEVEL_1)
		else:
			print("Todavía quedan %s enemigos por eliminar." % enemigos_restantes)


func _on_climb_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		# Notificar al jugador que está en una escalera
		if body.has_method("set_ladder"):
			body.set_ladder(self)


func _on_climb_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		# Notificar al jugador que salió de la escalera
		if body.has_method("set_ladder"):
			body.set_ladder(null)
