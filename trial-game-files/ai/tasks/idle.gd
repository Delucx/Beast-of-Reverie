extends BTAction

func _tick(_delta: float) -> Status:
	agent.stop()
	return FAILURE
