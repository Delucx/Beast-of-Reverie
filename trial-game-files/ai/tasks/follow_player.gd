extends BTAction

@export var last_pos_key: StringName = &"player_last_pos"
@export var tolerance : float = 30
@export var wandering_range : float = 500
var pet_reach : bool = false

func _tick(_delta: float) -> Status:
	if not is_instance_valid(agent):
		return FAILURE

	var player = agent.player
	if not is_instance_valid(player):
		return FAILURE

	var to_player = player.global_position - agent.global_position
	var distance = to_player.length()
	var dir_x = to_player.normalized().x
	
	if not blackboard.has_var(last_pos_key):
		blackboard.set_var(last_pos_key, player.global_position.x)
	
	var last_x: float = blackboard.get_var(last_pos_key, player.global_position.x)
	var player_has_moved := not is_equal_approx(player.global_position.x, last_x)
	blackboard.set_var(last_pos_key, player.global_position.x)
	pet_reach = false
	
	if distance <= tolerance:
		agent.stop()
		if not player_has_moved:
			pet_reach = true
	
	if wandering_range >= distance and pet_reach:
		return FAILURE
	else:
		agent.move(dir_x)
		return RUNNING
