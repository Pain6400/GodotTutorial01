extends CanvasLayer

const LEVEL_0 = preload("res://Scenes/Levels/level 0.tscn")
const LEVEL_1 = preload("res://Scenes/Levels/level 1.tscn")
@onready var anim: AnimationPlayer = $Anim



func change_stage(stage: PackedScene):
	get_tree().paused = true
	anim.play("Trans_In")
	await anim.animation_finished
	if stage:
		get_tree().change_scene_to_packed(stage)
	await get_tree().process_frame
	anim.play("Trans_Out")
	await anim.animation_finished
	get_tree().paused = false
