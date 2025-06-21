extends BTAction

@export var min_range_dir : float = 100
@export var max_range_dir : float = 400

@export var position : StringName = &"pos"
@export var direction : StringName = &"dir"

func _tick(_delta : float) -> Status:
	var dir = random_dir()
	var pos = random_pos(dir)
	
	blackboard.set_var(position, pos)
	blackboard.set_var(direction, dir)
	
	return SUCCESS
	
func random_dir():
	var dir = randi_range(-2, 1)
	if abs(dir) != dir:
		dir = -1
	else:
		dir = 1
	return dir

func random_pos(dir : int) -> Vector2:
	var vector : Vector2
	var distance = randf_range(min_range_dir, max_range_dir) * dir
	var final_pos = (distance + agent.global_position.x)
	vector.x = final_pos
	return vector
