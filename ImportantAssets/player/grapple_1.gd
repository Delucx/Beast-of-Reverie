extends Node2D

@export var player_path: NodePath
@export var gc_path: NodePath

@onready var ray := $RayCast2D
@onready var rope := $Line2D

var launched = false
var traveling = false
var retracting = false
var target: Vector2
var grapple_tip: Vector2
var direction: Vector2
var cooldown_timer: float = 0.0
var on_cooldown: bool = false

var player: CharacterBody2D
var gc: Node2D

func _ready():
	player = get_node(player_path)
	gc = get_node(gc_path)

func _process(delta):
	grapple_cd(delta)

func grapple_cd(delta):
	if on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			on_cooldown = false
		
	if player.ui_node:
		player.ui_node.set_grapple_cooldown(gc.grapple_cooldown - cooldown_timer, gc.grapple_cooldown)

func move_grapple(delta):
	var previous_tip := grapple_tip
	grapple_tip += direction * gc.grapple_speed * delta

	var exclude_list:Array
	for node in get_tree().get_nodes_in_group("no_grapple"):
		exclude_list.append(node)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(previous_tip, grapple_tip)
	query.exclude = exclude_list

	var result = space_state.intersect_ray(query)

	if result.size() > 0:
		grapple_tip = result["position"]
		target = grapple_tip
		launched = true
		traveling = false
	else:
		rope.set_point_position(0, rope.to_local(player.global_position))
		rope.set_point_position(1, rope.to_local(grapple_tip))

		if player.global_position.distance_to(grapple_tip) >= gc.max_grapple_distance:
			retract()

func begin_grapple():
	traveling = true
	retracting = false
	launched = false  # make sure it's false at the start
	grapple_tip = player.global_position
	target = get_global_mouse_position()
	direction = (target - player.global_position).normalized()
	rope.show()

func handle_grapple(delta):
	var target_dir = (target - player.global_position).normalized()
	var distance = player.global_position.distance_to(target)
	var displacement = distance - gc.rest_length

	var current_stiffness = gc.stiffness
	var current_damping = gc.damping

	if player.is_carrying_pet:
		current_stiffness *= gc.carry_pet_stiff
		current_damping *= gc.carry_pet_damp

	var spring_force = target_dir * current_stiffness * displacement
	var relative_velocity = player.velocity.dot(target_dir)
	var damping_force = -target_dir * current_damping * relative_velocity
	#var force = spring_force + damping_force
	#player.velocity += force * delta
	
	var pull_multiplier = 1.0
	if gc.grapple_mode == gc.GrappleMode.SINGLE:
		pull_multiplier = 0.5

	var force = (spring_force + damping_force) * pull_multiplier
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
	var return_speed = gc.grapple_speed * 2
	var to_player = (player.global_position - grapple_tip)
	var distance = to_player.length()

	if distance < 10:
		grapple_tip = player.global_position
		end_grapple()
		return

	grapple_tip += to_player.normalized() * return_speed * delta

	rope.set_point_position(0, rope.to_local(player.global_position))
	rope.set_point_position(1, rope.to_local(grapple_tip))

func end_grapple():
	launched = false
	retracting = false
	on_cooldown = true
	cooldown_timer = gc.grapple_cooldown
	
	if player.global_position.distance_to(grapple_tip) >= gc.max_grapple_distance:
		end_grapple()
