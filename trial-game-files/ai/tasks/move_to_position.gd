extends BTAction

@export var position : StringName = &"pos"
@export var direction : StringName = &"dir"

@export var tolerance : float = 50
@export var max_stuck_time : float = 1.5

var stuck_timer : float = 0.0
var last_x : float = 0.0

func _tick(delta: float) -> Status:
	var pos : Vector2 = blackboard.get_var(position, Vector2.ZERO)
	var dir = blackboard.get_var(direction)
	
	if abs(agent.global_position.x - pos.x) < tolerance:
		stuck_timer = 0.0
		agent.stop()
		return SUCCESS

	var delta_x = abs(agent.global_position.x - last_x)
	if delta_x < 1.0:
		stuck_timer += delta
	else:
		stuck_timer = 0.0 

	last_x = agent.global_position.x

	if stuck_timer > max_stuck_time:
		stuck_timer = 0.0
		return FAILURE
	
	agent.move(dir)
	return RUNNING
