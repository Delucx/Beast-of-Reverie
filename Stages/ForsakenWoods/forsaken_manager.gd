extends Node2D

@export var loop_map_scene: PackedScene

@onready var spawn := $forsaken_spawn
@onready var camera := $Player/Camera2D

var current_map: Node2D
var old_map: Node2D
var current_map_origin := Vector2.ZERO
var loop_map_width = 28513.0
var left_trigger
var right_trigger
var removed = false

func _ready():
	if TransitionManager.fade_rect.modulate.a == 1.0:
		var tween = TransitionManager.create_tween()
		tween.tween_property(TransitionManager.fade_rect, "modulate:a", 0.0, 5.0)

func spawn_loop_map(from_position: Vector2):
	current_map_origin = from_position
	var new_map = loop_map_scene.instantiate()
	new_map.position = current_map_origin
	add_child(new_map)
	old_map = current_map
	current_map = new_map

	# Setup triggers inside the loop map
	left_trigger = new_map.get_node("LeftTrigger")
	right_trigger = new_map.get_node("RightTrigger")
	left_trigger.body_entered.connect(_on_left_trigger)
	right_trigger.body_entered.connect(_on_right_trigger)

func current_width_map_pos(direction: Vector2):
	var right_side_map_pos = current_map.position.x + loop_map_width
	var left_side_map_pos = current_map.position.x - loop_map_width
	
	if direction.x == 1: # Right
		var new_right_side_map_pos = right_side_map_pos
		return new_right_side_map_pos
	else: # Left
		var new_left_side_map_pos = left_side_map_pos
		return new_left_side_map_pos

func _on_right_trigger(body):
	if body.is_in_group("player"):
		print_debug("right trigger")
		remove_spawner()
		right_trigger.queue_free()
		var new_pos = current_width_map_pos(Vector2(1, 0))
		print_debug("Right Side: ", new_pos)
		spawn_loop_map(Vector2(new_pos, 0))

func _on_left_trigger(body):
	if body.is_in_group("player"):
		print_debug("left trigger")
		remove_spawner()
		left_trigger.queue_free()
		var new_pos = current_width_map_pos(Vector2(-1, 0))
		print_debug("Left Side: ", new_pos)
		spawn_loop_map(Vector2(new_pos, 0))

func remove_spawner():
	if removed == false:
		spawn.queue_free()
		camera.limit_left = -10000000
		removed = true
	else:
		old_map.queue_free()
