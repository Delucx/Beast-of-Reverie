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
var is_carrying_pet:bool = false
var ui_node: Control

func _ready():
	pet = get_node(pet_path)
	ui_node = get_node(ui_path)

func gravity(delta):
	var grav = get_gravity()
	
	if gc.launched and not is_on_floor():
		grav *= player_grav
	
	velocity += grav * delta

func _physics_process(delta):
	gravity(delta)
	try_jump()
	input()
	handle_anim()
	handle_sprite_dir_auto()

func input():
	if not gc.launched:
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = lerp(velocity.x, physics.SPEED * direction * \
			(slow_factor if is_carrying_pet else 1.0), physics.ACCELERATION)
		else:
			velocity.x = lerp(velocity.x, 0.0, physics.DECELERATION)

		if Input.is_action_just_pressed("pet_pickup") and pet_in_range():
			toggle_pet_pickup()
		
		#handle_sprite_dir(direction)
	else:
		pass
	
	move_and_slide()
	
	if gc.launched and (velocity.y < 0 or velocity.y > 0):
		gc.grapple_speed = grapple_speed_air
		#gc.right_grapple.grapple_speed = grapple_speed_air

	else:
		gc.grapple_speed = grapple_speed_ground
		#gc.right_grapple.grapple_speed = grapple_speed_ground

func try_jump():
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

#func handle_sprite_dir(dir):
	#if dir == 1:
		#anim_sprite.flip_h = false
	#elif dir == -1:
		#anim_sprite.flip_h = true

# Function to check if the mouse cursor is over the pet
func pet_in_range() -> bool:
	var mouse_pos = get_global_mouse_position()
	var pet_pos = pet.global_position
	return mouse_pos.distance_to(pet_pos) <= 30  # Adjust range as needed

# Function to toggle pet pickup
func toggle_pet_pickup():
	if is_carrying_pet:
		# If already carrying, drop the pet
		is_carrying_pet = false
		pet.set_carried(false)  # Tell the pet it's no longer being carried
		pet.position = global_position + Vector2(20, 0)  # Place pet slightly below the player (adjust as needed)
		pet.velocity = Vector2.ZERO  # Stop pet's movement
	else:
		is_carrying_pet = true
		pet.set_carried(true)
		pet.position = global_position + Vector2(0, -pet_carried_pos)
		pet.velocity = Vector2.ZERO 

#func is_grappling() -> bool:
	#return gc.is_any_grappling()
