extends BTAction

@export var interact_target_key: StringName = "pet_interact_target"
@export var tolerance: float = 10.0

func _tick(_delta: float) -> Status:
	if not blackboard.has_var(interact_target_key):
		return FAILURE

	var target: Node2D = blackboard.get_var(interact_target_key)
	if not is_instance_valid(target):
		blackboard.erase_var(interact_target_key)
		return FAILURE

	var to_target_x = target.global_position.x - agent.global_position.x
	var distance_x = abs(to_target_x)
	var dir_x = sign(to_target_x)

	if distance_x <= tolerance:
		agent.stop()
		return SUCCESS
	else:
		agent.move(dir_x)
		return RUNNING
