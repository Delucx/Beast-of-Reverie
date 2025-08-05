extends Node2D

@export var grapple_speed: float = 2000
@export var retract_speed: float = 1200
@export var rest_length: float = 10
@export var stiffness: float = 5
@export var damping: float = 5
@export var max_grapple_distance: float = 600
@export var carry_pet_stiff: float = 2
@export var carry_pet_damp: float = 2

@onready var player = get_parent()
@onready var ray1 = $RayCast2D
@onready var rope1 = $Line2D
@onready var ray2 = $RayCast2D2
@onready var rope2 = $Line2D2

# Grapple 1
var launched1 = false
var traveling1 = false
var retracting1 = false
var grapple_tip1 = Vector2.ZERO
var target1 = Vector2.ZERO
var direction1 = Vector2.ZERO

# Grapple 2
var launched2 = false
var traveling2 = false
var retracting2 = false
var grapple_tip2 = Vector2.ZERO
var target2 = Vector2.ZERO
var direction2 = Vector2.ZERO

var last_grapple_used := 0  # 1 or 2

func _process(delta):
	ray1.look_at(get_global_mouse_position())
	ray2.look_at(get_global_mouse_position())

	input()

	if traveling1:
		move_grapple(1, delta)
	elif retracting1:
		return_grapple(1, delta)
	elif launched1:
		handle_grapple(1, delta)

	if traveling2:
		move_grapple(2, delta)
	elif retracting2:
		return_grapple(2, delta)
	elif launched2:
		handle_grapple(2, delta)

func input():
	if Input.is_action_just_pressed("grapple_shoot"):
		if not launched1 and not traveling1:
			begin_grapple(1)
		elif not launched2 and not traveling2:
			begin_grapple(2)

	if Input.is_action_just_pressed("grapple_return"):
		if last_grapple_used == 1 and launched2:
			retract(2)
		elif last_grapple_used == 2 and launched1:
			retract(1)
		elif launched2 or traveling2:
			retract(2)
		elif launched1 or traveling1:
			retract(1)


func begin_grapple(index: int):
	var tip = player.global_position
	var tgt = get_global_mouse_position()
	var dir = (tgt - tip).normalized()

	if index == 1:
		grapple_tip1 = tip
		target1 = tgt
		direction1 = dir
		traveling1 = true
		launched1 = true
		rope1.show()
	elif index == 2:
		grapple_tip2 = tip
		target2 = tgt
		direction2 = dir
		traveling2 = true
		launched2 = true
		rope2.show()
		
	last_grapple_used = index


func move_grapple(index: int, delta: float):
	var tip
	var dir
	var rope

	if index == 1:
		tip = grapple_tip1
		dir = direction1
		rope = rope1
	elif index == 2:
		tip = grapple_tip2
		dir = direction2
		rope = rope2

	var prev_tip = tip
	tip += dir * grapple_speed * delta

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(prev_tip, tip)
	query.exclude = get_tree().get_nodes_in_group("no_grapple")
	var result = space_state.intersect_ray(query)

	if result:
		tip = result.position
		if index == 1:
			grapple_tip1 = tip
			target1 = tip
			traveling1 = false
		else:
			grapple_tip2 = tip
			target2 = tip
			traveling2 = false
	else:
		if player.global_position.distance_to(tip) >= max_grapple_distance:
			retract(index)

	if index == 1:
		grapple_tip1 = tip
		update_rope(1)
	elif index == 2:
		grapple_tip2 = tip
		update_rope(2)

func handle_grapple(index: int, delta: float):
	var tip
	if index == 1:
		tip = grapple_tip1
	else:
		tip = grapple_tip2

	var direction = (tip - player.global_position).normalized()
	var distance = player.global_position.distance_to(tip)
	var displacement = distance - rest_length

	var current_stiff = stiffness
	var current_damp = damping

	if player.is_carrying_pet:
		current_stiff *= carry_pet_stiff
		current_damp *= carry_pet_damp

	var spring_force = direction * current_stiff * displacement
	var relative_velocity = player.velocity.dot(direction)
	var damping_force = -direction * current_damp * relative_velocity
	var force = spring_force + damping_force

	player.velocity += force * delta
	update_rope(index)

func update_rope(index: int):
	if index == 1:
		rope1.set_point_position(0, rope1.to_local(player.global_position))
		rope1.set_point_position(1, rope1.to_local(grapple_tip1))
	elif index == 2:
		rope2.set_point_position(0, rope2.to_local(player.global_position))
		rope2.set_point_position(1, rope2.to_local(grapple_tip2))

func retract(index: int):
	if index == 1:
		retracting1 = true
		traveling1 = false
	elif index == 2:
		retracting2 = true
		traveling2 = false

func return_grapple(index: int, delta: float):
	var tip
	var rope

	if index == 1:
		tip = grapple_tip1
		rope = rope1
	elif index == 2:
		tip = grapple_tip2
		rope = rope2

	var to_player = player.global_position - tip
	var dist = to_player.length()

	if dist < 10:
		if index == 1:
			grapple_tip1 = player.global_position
			end_grapple(1)
		elif index == 2:
			grapple_tip2 = player.global_position
			end_grapple(2)
		return

	tip += to_player.normalized() * retract_speed * delta

	if index == 1:
		grapple_tip1 = tip
		update_rope(1)
	elif index == 2:
		grapple_tip2 = tip
		update_rope(2)

func end_grapple(index: int):
	if index == 1:
		launched1 = false
		retracting1 = false
		rope1.hide()
	elif index == 2:
		launched2 = false
		retracting2 = false
		rope2.hide()
		
func get_grapple_lengths() -> Dictionary:
	var len1 = 0.0
	var len2 = 0.0
	if launched1:
		len1 = player.global_position.distance_to(grapple_tip1)
	if launched2:
		len2 = player.global_position.distance_to(grapple_tip2)
	return {
		"grapple1": len1,
		"grapple2": len2
	}
