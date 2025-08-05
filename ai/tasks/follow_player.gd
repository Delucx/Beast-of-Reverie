extends BTAction

@export var last_pos_key: StringName = &"player_last_pos"
@export var follow_flag_key: StringName = "pet_should_follow_player"
@export var tolerance: float = 50
@export var wandering_range: float = 500

func _tick(_delta: float) -> Status:
	if not is_instance_valid(agent):
		return FAILURE

	var player = agent.player
	if not is_instance_valid(player):
		return FAILURE

	# Disable follow if pet is being manually controlled
	if blackboard.get_var("pet_is_following_cursor", false):
		blackboard.set_var(follow_flag_key, false)
		return FAILURE

	var to_player = player.global_position - agent.global_position
	var distance = to_player.length()
	var dir_x = to_player.normalized().x

	# Detect if player moved
	var last_x: float = blackboard.get_var(last_pos_key, player.global_position.x)
	var player_has_moved := not is_equal_approx(player.global_position.x, last_x)
	blackboard.set_var(last_pos_key, player.global_position.x)

	# Enable follow mode if player moved or pet is too far
	if player_has_moved or distance > wandering_range:
		blackboard.set_var(follow_flag_key, true)

	# Only follow if we're in follow mode
	if blackboard.get_var(follow_flag_key, false):
		if distance <= tolerance:
			agent.stop()
			blackboard.set_var(follow_flag_key, false) # Stop following
			return SUCCESS
		else:
			agent.move(dir_x)
			return RUNNING

	# Otherwise do nothing
	agent.stop()
	return FAILURE
