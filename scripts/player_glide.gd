extends Node

@export var gravity: float = 980.0
@export var glide_factor: float = 0.3

func handle_glide(velocity: Vector2, delta: float, on_floor: bool) -> Vector2:
	if not on_floor:
		if Input.is_action_pressed("jump"):
			velocity.y += gravity * glide_factor * delta
		else:
			velocity.y += gravity * delta
	return velocity
