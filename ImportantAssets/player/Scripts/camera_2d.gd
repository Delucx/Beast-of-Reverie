extends Camera2D

@export var edge_threshold := 100               # Distance from screen edge to start peeking
@export var max_peek_offset := Vector2(100, 60) # Max offset for peek
@export var peek_lerp_speed := 5.0              # Smoothness of peek

var current_offset := Vector2.ZERO

func _process(delta):
	var viewport_size = get_viewport_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var half_view = viewport_size / 2

	var desired_offset := Vector2.ZERO

	# Mouse X axis
	if mouse_pos.x < edge_threshold:
		desired_offset.x = lerp(0.0, -max_peek_offset.x, (edge_threshold - mouse_pos.x) / edge_threshold)
	elif mouse_pos.x > viewport_size.x - edge_threshold:
		desired_offset.x = lerp(0.0, max_peek_offset.x, (mouse_pos.x - (viewport_size.x - edge_threshold)) / edge_threshold)

	# Mouse Y axis
	if mouse_pos.y < edge_threshold:
		desired_offset.y = lerp(0.0, -max_peek_offset.y, (edge_threshold - mouse_pos.y) / edge_threshold)
	elif mouse_pos.y > viewport_size.y - edge_threshold:
		desired_offset.y = lerp(0.0, max_peek_offset.y, (mouse_pos.y - (viewport_size.y - edge_threshold)) / edge_threshold)

	# Clamp offset within safe range (manual version)
	var max_safe_offset = viewport_size / 4
	desired_offset.x = clamp(desired_offset.x, -max_safe_offset.x, max_safe_offset.x)
	desired_offset.y = clamp(desired_offset.y, -max_safe_offset.y, max_safe_offset.y)

	# Predict new camera center with offset
	var camera_center = global_position + desired_offset

	# Only apply offset if within limits
	if (camera_center.x - half_view.x >= limit_left and camera_center.x + half_view.x <= limit_right):
		current_offset.x = lerp(current_offset.x, desired_offset.x, delta * peek_lerp_speed)
	else:
		current_offset.x = lerp(current_offset.x, 0.0, delta * peek_lerp_speed)

	if (camera_center.y - half_view.y >= limit_top and camera_center.y + half_view.y <= limit_bottom):
		current_offset.y = lerp(current_offset.y, desired_offset.y, delta * peek_lerp_speed)
	else:
		current_offset.y = lerp(current_offset.y, 0.0, delta * peek_lerp_speed)

	offset = current_offset
