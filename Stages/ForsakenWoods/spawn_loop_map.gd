extends Area2D

@export var world_path : Node2D

@onready var trigger : Area2D = $"."

var start_loop_spawn = 2775.0

func _on_body_entered(body):
	if body.is_in_group("player"):
		print_debug("spawn map")
		trigger.queue_free()
		world_path.spawn_loop_map(Vector2(start_loop_spawn, 0))
	
