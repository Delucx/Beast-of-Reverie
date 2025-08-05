extends BTAction

@export var target_position_key: StringName = "pet_target_position"
@export var tolerance: float = 10.0

func _tick(_delta: float) -> Status:
	if not is_instance_valid(agent):
		return FAILURE

	if not blackboard.has_var(target_position_key):
		# Clear the flag in case it was stuck
		blackboard.erase_var("pet_is_following_cursor")
		return FAILURE

	var target_pos: Vector2 = blackboard.get_var(target_position_key, agent.global_position)
	var to_target_x = target_pos.x - agent.global_position.x
	var distance_x = abs(to_target_x)
	var dir_x = sign(to_target_x)

	if distance_x <= tolerance:
		agent.stop()
		blackboard.erase_var(target_position_key)
		blackboard.erase_var("pet_is_following_cursor")  # Done following
		return SUCCESS
	else:
		blackboard.set_var("pet_is_following_cursor", true)  # Actively following
		agent.move(dir_x)
		return RUNNING
