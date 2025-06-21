extends BTAction

func _tick(_delta: float) -> Status:
	if not is_instance_valid(agent):
		return FAILURE

	if agent.is_carrying:
		return SUCCESS

	return FAILURE
