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

var pet: CharacterBody2D
var is_carrying_pet: bool = false
var ui_node: Control

var in_quicksand := false
var sink_depth := 0.0
var can_move := true

func _ready():
	pet = get_node(pet_path)
	ui_node = get_node(ui_path)

func gravity(delta):
	if in_quicksand and not gc.launched:
		var target_sink_speed = clamp(sink_depth / 10.0, 1.0, 2.0)
		velocity.y = lerp(velocity.y, target_sink_speed, delta * 70.0)
		return

	var grav = get_gravity()
	if gc.launched and not is_on_floor():
		grav *= player_grav
	velocity += grav * delta

func _physics_process(delta):
	gravity(delta)
	try_jump()
	
	if can_move and not in_quicksand:
		input()
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.2)  # Fully trapped
		
	move_and_slide()
	handle_anim()
	handle_sprite_dir_auto()
	
		# Apply visual sinking
	var target_y = 0.0
	if in_quicksand:
		target_y = sink_depth / 2.0
	anim_sprite.position.y = lerp(anim_sprite.position.y, target_y, delta * 5.0)


func set_quicksand_state(active: bool, depth: float):
	in_quicksand = active
	sink_depth = depth
	can_move = not active or depth < 20.0  # Can still move if only slightly in

	if in_quicksand:
		velocity.x = lerp(velocity.x, 0.0, 0.1)  # Slowly stop motion

func die_by_quicksand():
	queue_free()
	print("Player sank and died in quicksand.")

func input():
	if not gc.launched:
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
	
		# Optional: Clamp horizontal velocity
		velocity.x = clamp(velocity.x, -physics.SPEED, physics.SPEED)

		move_and_slide()

	else:
		# Do NOT apply slow_factor here — let the grapple pull at full strength
		move_and_slide()

	# Adjust grapple speed
	if gc.launched and (velocity.y < 0 or velocity.y > 0):
		gc.grapple_speed = grapple_speed_air
	else:
		gc.grapple_speed = grapple_speed_ground

func try_jump():
	if gc.launched or in_quicksand:
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += physics.JUMP_VELOCITY

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

# Function to check if the mouse cursor is over the pet
func pet_in_range() -> bool:
	var mouse_pos = get_global_mouse_position()
	var pet_pos = pet.global_position
	return mouse_pos.distance_to(pet_pos) <= 30  # Adjust range as needed

# Function to toggle pet pickup
func toggle_pet_pickup():
	if is_carrying_pet:
		# Drop the pet
		is_carrying_pet = false
		pet.set_carried(false)
		pet.position = global_position + Vector2(20, 0)
		pet.velocity = Vector2.ZERO
	else:
		# Pick up the pet
		is_carrying_pet = true
		pet.set_carried(true)
		pet.position = global_position + Vector2(0, -pet_carried_pos)
		pet.velocity = Vector2.ZERO
