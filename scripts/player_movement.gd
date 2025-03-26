extends Node

@export var speed: float = 200.0
@export var sprint_speed: float = 350.0
@export var acceleration: float = 15.0
@export var friction: float = 10.0

func handle_movement(velocity: Vector2, delta: float) -> Vector2:
	var direction: float = Input.get_axis("move_left", "move_right")
	var current_speed = sprint_speed if Input.is_action_pressed("sprint") else speed

	if direction:
		velocity.x = lerp(velocity.x, direction * current_speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
	
	return velocity
