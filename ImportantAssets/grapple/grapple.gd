extends Node2D

@export var speed: float = 800.0
@export var max_distance: float = 500.0

var start_pos: Vector2
var target_pos: Vector2
var is_firing := false
var is_attached := false
var player: CharacterBody2D = null
var initialized := false  # NEW: Track if fire() was called

func _ready():
	$Area2D.connect("area_entered", _on_area_entered)
	hide()

func fire(from: Vector2, to: Vector2, _player: CharacterBody2D):
	player = _player
	start_pos = from
	global_position = from
	target_pos = to
	is_firing = true
	is_attached = false
	initialized = true  # ✅ Mark initialized
	show()

	$Line2D.clear_points()
	$Line2D.add_point(Vector2.ZERO)
	$Line2D.add_point(Vector2.ZERO)

func _physics_process(delta):
	if not initialized or player == null:
		return

	if is_firing and not is_attached:
		var dir = (target_pos - global_position).normalized()
		global_position += dir * speed * delta

		$Line2D.set_point_position(0, to_local(player.global_position))
		$Line2D.set_point_position(1, Vector2.ZERO)

		if start_pos.distance_to(global_position) > max_distance:
			reset()

	elif is_attached:
		var pull_dir = global_position - player.global_position
		player.velocity = pull_dir.normalized() * speed * 0.5

		if pull_dir.length() < 10:
			reset()

func _on_area_entered(_area):
	is_attached = true
	is_firing = false

func reset():
	hide()
	is_firing = false
	is_attached = false
	$Line2D.clear_points()
	queue_free()
