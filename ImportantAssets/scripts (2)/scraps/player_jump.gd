extends Node

@export var jump_force: float = -400.0

func handle_jump(velocity: Vector2, delta: float, on_floor: bool) -> Vector2:
	if Input.is_action_just_pressed("jump") and on_floor:
		velocity.y = jump_force
	return velocity
