extends RayCast2D

@onready var raycast = $"."
@onready var foot_target = $"../../../../../FootTarget_R1"  # Adjust based on path

func _process(delta):
	if raycast.is_colliding():
		var hit_point = raycast.get_collision_point()
		foot_target.global_position = hit_point
