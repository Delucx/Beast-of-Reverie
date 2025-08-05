extends BTAction

@export var target_position_key: StringName = "pet_target_position"

func _tick(_delta: float) -> Status:
	if Input.is_action_just_pressed("pet_move"):
		var click_position = agent.get_global_mouse_position()
		blackboard.set_var(target_position_key, click_position)
		#print_debug("move here")
		return SUCCESS
	return FAILURE
