extends BTAction

func _tick(_delta: float) -> Status:
	if not is_instance_valid(agent):
		return FAILURE

	if agent.pulled:
		var anim_player = agent.get_external_anim_player()
		if anim_player and not anim_player.is_playing():
			anim_player.play("tree_pulled")
		return SUCCESS

	return FAILURE
