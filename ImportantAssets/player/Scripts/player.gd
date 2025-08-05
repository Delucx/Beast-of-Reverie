extends CharacterBody2D

@export var physics: Physics
@export var pet_path: NodePath
@export var ui_path: NodePath
@export var slow_factor: float = 0.8
@export var grapple_speed_ground: float = 2000
@export var grapple_speed_air: float = 1500
@export var player_grav: float = 0.01
@export var pet_carried_pos: float = 30


@onready var gc: Node2D = $GrappleController
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var glide = $Scripts/glide
@onready var jump_bar: TextureProgressBar 
@onready var grapple_bar1: TextureProgressBar
@onready var grapple_bar2: TextureProgressBar


var pet: CharacterBody2D
var is_carrying_pet: bool = false
var ui_node: Control


var in_quicksand := false
var sink_depth := 0.0
var can_move := true


var jump_charge := 0.0
const MAX_JUMP_CHARGE := 1.5  # seconds for full charge


func _ready():
	pet = get_node(pet_path)
	ui_node = get_node(ui_path)
	if Global.player == null:
		Global.player = self
	
	# Cache references to the progress bars
	jump_bar = ui_node.get_node("ChargeJumpBar")
	grapple_bar1 = ui_node.get_node("GrappleBar1")
	grapple_bar2 = ui_node.get_node("GrappleBar2")


func _physics_process(delta):
	# Handle quicksand sinking
	if in_quicksand and not (gc.launched1 or gc.launched2):
		# Gradually increase sink depth to simate sinking
		sink_depth = min(sink_depth + delta * 2.0, 60.0)

		# Sink velocity based on depth
		var sink_gravity: float = clamp(sink_depth * 1.0, 2.0, 20.0)
		velocity.y = lerp(velocity.y, sink_gravity, delta * 70.0)

		# Optional death condition
		if anim_sprite.position.y >= 28.0:
			die_by_quicksand()
	else:
		# Normal gravity / glide handling
		velocity = glide.handle_glide(velocity, get_gravity().y, delta, is_on_floor(), gc.launched1, gc.launched2)

	try_jump(delta)

	if can_move and not in_quicksand:
		input()
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.2)  # Fully trapped

	move_and_slide()
	handle_anim()
	handle_sprite_dir_auto()
	update_grapple_bars()


	# Apply visual sinking offset
	var target_y = 0.0
	if in_quicksand:
		target_y = sink_depth / 2.0
	anim_sprite.position.y = lerp(anim_sprite.position.y, target_y, delta * 5.0)


func update_grapple_bars():
	var lengths = gc.get_grapple_lengths()

	# Grapple 1
	if gc.launched1:
		#var percent1 = clamp(lengths["grapple1"] / gc.max_grapple_distance, 0.0, 1.0) * 100.0 # fill
		var percent1 = (1.0 - clamp(lengths["grapple1"] / gc.max_grapple_distance, 0.0, 1.0)) * 100.0 # reduce
		grapple_bar1.value = percent1
	else:
		grapple_bar1.value = 100.0

	# Grapple 2
	if gc.launched2:
		#var percent2 = clamp(lengths["grapple2"] / gc.max_grapple_distance, 0.0, 1.0) * 100.0 # fill
		var percent2 = (1.0 - clamp(lengths["grapple2"] / gc.max_grapple_distance, 0.0, 1.0)) * 100.0 #reduce
		grapple_bar2.value = percent2
	else:
		grapple_bar2.value = 100.0


func set_quicksand_state(active: bool, depth: float):
	in_quicksand = active
	sink_depth = depth
	can_move = not active or depth < 20.0  # Can still move if only slightly in

	if in_quicksand:
		velocity.x = lerp(velocity.x, 0.0, 0.1)  # Slowly stop motion


func die_by_quicksand():
	get_tree().change_scene_to_file("res://MainMenu/GUI/main_menu.tscn")
	queue_free()
	print("Player sank and died in quicksand.")


func input():
	if not (gc.launched1 or gc.launched2):
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			var target_speed = physics.SPEED * direction
			if is_carrying_pet:
				target_speed *= slow_factor
			velocity.x = lerp(velocity.x, target_speed, physics.ACCELERATION)
		else:
			velocity.x = lerp(velocity.x, 0.0, physics.DECELERATION)

		if Input.is_action_just_pressed("pet_pickup") and pet_in_range():
			toggle_pet_pickup()

		velocity.x = clamp(velocity.x, -physics.SPEED, physics.SPEED)
		move_and_slide()
	else:
		move_and_slide()

	if (gc.launched1 or gc.launched2) and (velocity.y < 0 or velocity.y > 0):
		gc.grapple_speed = grapple_speed_air
	else:
		gc.grapple_speed = grapple_speed_ground


func try_jump(delta):
	if (gc.launched1 or gc.launched2) or in_quicksand:
		return
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y += physics.JUMP_VELOCITY
	
	# Charge jump logic
	if Input.is_action_pressed("jump") and is_on_floor() and not (gc.launched1 or gc.launched2):
		print_debug("charging")
		jump_charge = min(jump_charge + delta, MAX_JUMP_CHARGE)
	else:
		if jump_charge > 0.0 and Input.is_action_just_released("jump") and is_on_floor():
			var power = lerp(physics.JUMP_VELOCITY, physics.JUMP_VELOCITY * 2, jump_charge / MAX_JUMP_CHARGE)
			velocity.y += power
			print_debug("jumping", jump_charge)
		#print_debug("not jumping", jump_charge)
		jump_charge = 0.0

	# Update bar
	jump_bar.value = (jump_charge / MAX_JUMP_CHARGE) * 100.0


func handle_anim():
	if is_on_floor():
		if velocity.x:
			anim_sprite.play("run")
		else:
			anim_sprite.play("idle")
	else:
		if velocity.y < 0:
			anim_sprite.play("jump")
		elif velocity.y > 0:
			anim_sprite.play("fall")


func handle_sprite_dir_auto():
	if velocity.x > 10:
		anim_sprite.flip_h = false
	elif velocity.x < -10:
		anim_sprite.flip_h = true


func pet_in_range() -> bool:
	var mouse_pos = get_global_mouse_position()
	var pet_pos = pet.global_position
	return mouse_pos.distance_to(pet_pos) <= 30


func toggle_pet_pickup():
	if is_carrying_pet:
		is_carrying_pet = false
		pet.set_carried(false)
		pet.position = global_position + Vector2(20, 0)
		pet.velocity = Vector2.ZERO
	else:
		is_carrying_pet = true
		pet.set_carried(true)
		pet.position = global_position + Vector2(0, -pet_carried_pos)
		pet.velocity = Vector2.ZERO
