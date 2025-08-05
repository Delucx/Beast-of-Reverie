extends BTAction

@export var interact_target_key: StringName = "pet_interact_target"

func _tick(_delta: float) -> Status:
	if Input.is_action_just_pressed("pet_interact"):
		var click_position = agent.get_global_mouse_position()

		var query = PhysicsPointQueryParameters2D.new()
		query.position = click_position
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.collision_mask = 1 << 3  # Adjust if needed

		var space_state = agent.get_world_2d().direct_space_state
		var results = space_state.intersect_point(query, 32)

		for result in results:
			if result.collider.is_in_group("pet_interactable"):
				blackboard.set_var(interact_target_key, result.collider)
				#print("Pet clicked on interactable:", result.collider.name)
				return SUCCESS

	return FAILURE
