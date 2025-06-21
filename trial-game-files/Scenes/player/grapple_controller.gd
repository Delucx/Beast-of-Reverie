extends Node2D

@export var grapple_speed: float = 2000
@export var rest_length: float = 10
@export var stiffness: float = 5
@export var damping: float = 5
@export var max_grapple_distance: float = 600
@export var carry_pet_stiff: float = 2
@export var carry_pet_damp: float = 2
@export var grapple_cooldown: float = 0.5

@onready var player := get_parent()
@onready var ray := $RayCast2D
@onready var rope := $Line2D

var launched = false
var traveling = false
var target: Vector2
var grapple_tip: Vector2
var direction: Vector2
var cooldown_timer: float = 0.0
var on_cooldown: bool = false
var retracting = false

func _process(delta):
	ray.look_at(get_global_mouse_position())
	
	#grapple_cd(delta)
	update_grapple_ui()
	input()

	if traveling:
		move_grapple(delta)
	elif retracting:
		return_grapple(delta)
	elif launched:
		handle_grapple(delta)

func grapple_cd(delta):
	if on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			on_cooldown = false
		
	if player.ui_node:
		player.ui_node.set_grapple_cooldown(grapple_cooldown - cooldown_timer, grapple_cooldown)

func update_grapple_ui():
	if player.ui_node and launched:
		var current_length = player.global_position.distance_to(grapple_tip)
		player.ui_node.set_grapple_length(current_length, max_grapple_distance)
	elif player.ui_node:
		player.ui_node.set_grapple_length(0.0, max_grapple_distance)

func input():
	if Input.is_action_just_pressed("grapple_shoot") and not launched and not traveling:
		print_debug("grapple shoot")
		begin_grapple()
	elif Input.is_action_just_pressed("grapple_return"):
		retract()
		
	if Input.is_action_just_pressed("switch_grapple_mode"):
		pass

func begin_grapple():
	traveling = true
	launched = true
	grapple_tip = player.global_position
	target = get_global_mouse_position()
	direction = (target - player.global_position).normalized()
	rope.show()

func move_grapple(delta):
	var previous_tip := grapple_tip
	grapple_tip += direction * grapple_speed * delta

	# Perform a raycast between the previous and new grapple tip
	var exclude_list:Array
	for node in get_tree().get_nodes_in_group("no_grapple"):
		exclude_list.append(node)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(previous_tip, grapple_tip)
	query.exclude = exclude_list  # Avoid hitting the player

	var result = space_state.intersect_ray(query)

	if result.size() > 0:
		grapple_tip = result["position"]
		target = grapple_tip
		launched = true
		traveling = false
	else:
		# No hit, just update rope visuals
		rope.set_point_position(0, rope.to_local(player.global_position))
		rope.set_point_position(1, rope.to_local(grapple_tip))

		if player.global_position.distance_to(grapple_tip) >= max_grapple_distance:
			retract()

func handle_grapple(delta):
	var target_dir = (target - player.global_position).normalized()
	var distance = player.global_position.distance_to(target)
	var displacement = distance - rest_length

	var current_stiffness = stiffness
	var current_damping = damping

	if player.is_carrying_pet:
		current_stiffness *= carry_pet_stiff
		current_damping *= carry_pet_damp

	var spring_force = target_dir * current_stiffness * displacement
	var relative_velocity = player.velocity.dot(target_dir)
	var damping_force = -target_dir * current_damping * relative_velocity
	var force = spring_force + damping_force

	player.velocity += force * delta

	update_rope()


func update_rope():
	rope.set_point_position(0, rope.to_local(player.global_position))
	rope.set_point_position(1, rope.to_local(target))
	
func retract():
	if not launched and not traveling:
		return

	retracting = true
	traveling = false

func return_grapple(delta):
	var return_speed := grapple_speed * 2  # Faster return speed (optional)
	var to_player = (player.global_position - grapple_tip)
	var distance = to_player.length()

	if distance < 10:
		# Fully retracted
		grapple_tip = player.global_position
		end_grapple()
		return

	grapple_tip += to_player.normalized() * return_speed * delta

	# Update visual
	rope.set_point_position(0, rope.to_local(player.global_position))
	rope.set_point_position(1, rope.to_local(grapple_tip))

func end_grapple():
	launched = false
	retracting = false
	rope.hide()
	on_cooldown = true
	cooldown_timer = grapple_cooldown
