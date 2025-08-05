extends Area2D

@export var next_scene_path: String = "res://Stages/ForsakenWoods/forsaken.tscn"

func _on_body_entered(body):
	print_debug(body)
	if body.is_in_group("player"):  # Optional: only let the player trigger it
		print_debug("🔁 Entered scene transition area")
		get_tree().change_scene_to_file(next_scene_path)
