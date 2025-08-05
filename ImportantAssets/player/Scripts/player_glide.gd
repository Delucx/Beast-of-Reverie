extends Node

@export var glide_factor: float = 0.3
@export var grapple_gravity_factor: float = 0.01

func handle_glide(velocity: Vector2, gravity: float, delta: float, on_floor: bool, is_grappling1: bool, is_grappling2: bool) -> Vector2:
	if not on_floor:
		if is_grappling1 or is_grappling2:
			velocity.y += gravity * grapple_gravity_factor * delta
		elif Input.is_action_pressed("glide"):
			velocity.y += gravity * glide_factor * delta
		else:
			velocity.y += gravity * delta
	return velocity
