extends Node3D
@onready var animation_player: AnimationPlayer = $lever/AnimationPlayer

var player_in_range: bool = false
var toggled: bool = false
signal lever_toggled 

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		player_in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	player_in_range = false 
	
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("player_interact") and player_in_range:
		if toggled:
			animation_player.play("toggle-off")
			toggled = false
		else:
			animation_player.play("toggle-on")
			toggled = true
			emit_signal("lever_toggled")
