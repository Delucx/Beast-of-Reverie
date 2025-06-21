extends BTAction

@export var target_var : StringName = &"target"
@export var tolerance : float = 30

func _tick(_delta: float) -> Status:
	var target : CharacterBody2D = blackboard.get_var(target_var)
	
	if target != null:
		var target_pos = target.global_position
		var dir = agent.global_position.direction_to(target_pos)
		
		if abs(agent.global_position.x - target_pos.x) < tolerance:
			return SUCCESS
		else:
			return FAILURE
	
	return FAILURE
