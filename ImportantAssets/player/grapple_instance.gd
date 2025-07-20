extends Node2D

@export var grapple_speed: float = 800.0
@export var rest_length: float = 100.0
@export var stiffness: float = 20.0
@export var damping: float = 8.0
@export var max_grapple_distance: float = 300.0
@export var grapple_cooldown: float = 2.0
@export var carry_pet_stiff: float = 2.0
@export var carry_pet_damp: float = 2.0

@export var gc_path: NodePath  # Path to GrappleController
@onready var gc := get_node(gc_path)
@onready var player: CharacterBody2D = get_parent().get_parent()
@onready var ray := $RayCast2D
@onready var rope := $Line2D

var launched := false
var traveling := false
var retracting := false
var target: Vector2
var grapple_tip: Vector2
var direction: Vector2
var cooldown_timer := 0.0
var on_cooldown := false

func _ready():
	rope.hide()

func _process(delta):
	grapple_cd(delta)

	if traveling:
		move_grapple(delta)
	elif retracting:
		return_grapple(delta)
	elif launched:
		handle_grapple(delta)

func begin_grapple():
	if on_cooldown or launched or traveling:
		return
	traveling = true
	launched = false
	grapple_tip = player.global_position
	target = get_global_mouse_position()
	direction = (target - player.global_position).normalized()
	update_rope()
	rope.show()

func move_grapple(delta):
	var prev_tip = grapple_tip
	grapple_tip += direction * grapple_speed * delta
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(prev_tip, grapple_tip)
	query.exclude = get_tree().get_nodes_in_group("no_grapple")
	var result = space_state.intersect_ray(query)

	if result:
		grapple_tip = result.position
		target = grapple_tip
		launched = true
		traveling = false
	else:
		update_rope()
		if player.global_position.distance_to(grapple_tip) > max_grapple_distance:
			retract()

func handle_grapple(delta):
	var dir = (target - player.global_position).normalized()
	var distance = player.global_position.distance_to(target)
	var displacement = distance - rest_length

	var stiffness_value = stiffness
	var damping_value = damping

	if player.is_carrying_pet:
		stiffness_value *= carry_pet_stiff
		damping_value *= carry_pet_damp

	var spring_force = dir * stiffness_value * displacement
	var relative_velocity = player.velocity.dot(dir)
	var damping_force = -dir * damping_value * relative_velocity
	var pull_multiplier = 1.0

	if gc.grapple_mode == gc.GrappleMode.SINGLE:
		pull_multiplier = 0.5

	var force = (spring_force + damping_force) * pull_multiplier
	player.velocity += force * delta
	update_rope()

func update_rope():
	rope.set_point_position(0, rope.to_local(player.global_position))
	rope.set_point_position(1, rope.to_local(grapple_tip))

func retract():
	if not launched and not traveling:
		return
	retracting = true
	traveling = false

func return_grapple(delta):
	var return_speed = grapple_speed * 2
	var to_player = player.global_position - grapple_tip
	if to_player.length() < 10:
		grapple_tip = player.global_position
		end_grapple()
		return
	grapple_tip += to_player.normalized() * return_speed * delta
	update_rope()

func end_grapple():
	launched = false
	retracting = false
	rope.hide()
	on_cooldown = true
	cooldown_timer = grapple_cooldown

func grapple_cd(delta):
	if on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			on_cooldown = false
			cooldown_timer = 0.0
