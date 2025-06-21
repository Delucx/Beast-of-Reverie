extends BTAction

@export var last_pos_key: StringName = &"player_last_pos"

func _tick(_delta: float) -> Status:
	if not is_instance_valid(agent):
		return FAILURE

	var player = agent.player
	if not is_instance_valid(player):
		return FAILURE

	# Fetch only the 'x' value as a float
	var last_pos_x = blackboard.get_var(last_pos_key, 0.0)  # default to 0.0 as float

	# Compare player position x with last recorded position x
	if is_equal_approx(player.global_position.x, last_pos_x):
		return SUCCESS

	# Store only the x position as a float
	blackboard.set_var(last_pos_key, player.global_position.x)
	return FAILURE
