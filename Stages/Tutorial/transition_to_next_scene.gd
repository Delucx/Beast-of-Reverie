extends Area2D

@export var next_scene_path: String = "res://Stages/ForsakenWoods/forsaken.tscn"

func _on_body_entered(body):
	if body.is_in_group("player"):
		print_debug("🔁 Entered scene transition area")
		
		# Fade to black and then load the new scene
		TransitionManager.fade_to_scene(next_scene_path)
		queue_free()
