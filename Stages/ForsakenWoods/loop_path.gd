# World.gd
extends Node2D

@export var loop_map_scene: PackedScene
@export var player_path: NodePath
@export var start_map_width: float = 28000.0
@export var loop_map_width: float = 26600.0

var player: Node2D
var current_map: Node2D
var current_map_origin := Vector2.ZERO

func _ready():
	player = get_node(player_path)

func spawn_loop_map(direction: Vector2, from_position: Vector2):
	if not loop_map_scene:
		push_error("❌ loop_map_scene is not assigned!")
		return

	current_map_origin = from_position
	if direction.x > 0:
		current_map_origin.x += start_map_width
	elif direction.x < 0:
		current_map_origin.x -= loop_map_width

	var new_map = loop_map_scene.instantiate()
	new_map.position = current_map_origin
	add_child(new_map)
	current_map = new_map

	# Setup triggers inside the loop map
	var left_trigger = new_map.get_node("LeftTrigger")
	var right_trigger = new_map.get_node("RightTrigger")
	left_trigger.body_entered.connect(_on_left_trigger)
	right_trigger.body_entered.connect(_on_right_trigger)

func _on_right_trigger(body):
	if body.is_in_group("player"):
		spawn_loop_map(Vector2(1, 0), current_map.position)

func _on_left_trigger(body):
	if body.is_in_group("player"):
		spawn_loop_map(Vector2(-1, 0), current_map.position)
