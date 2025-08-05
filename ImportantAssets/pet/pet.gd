extends CharacterBody2D

@export var physics: Physics
@export var player_path: NodePath
@export var pickup_range: float = 30.0
@export var carried_position: float = -30
@onready var anim_sprite:AnimatedSprite2D = $AnimatedSprite2D

var player: CharacterBody2D
var is_carrying: bool = false

var pulled: bool = false

func _ready():
	player = get_node(player_path)

func _physics_process(delta):
	if player == null:
		return
	
	handle_anim()
	handle_sprite_dir_auto()
	
	if is_carrying:
		anim_sprite.play("idle")
		position = player.global_position + Vector2(0, carried_position)
		velocity = Vector2.ZERO
		return
	
	velocity += get_gravity() * delta
	
	move_and_slide()

func move(dir: float):
	velocity.x = lerp(velocity.x, dir * physics.SPEED, physics.ACCELERATION)
	
	if is_on_floor() and is_on_wall():
		jump()

func handle_anim():
	if is_on_floor() and not is_carrying:
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
		
	if is_carrying:
		if player.velocity.x > 10:
			anim_sprite.flip_h = false
		elif player.velocity.x < -10:
			anim_sprite.flip_h = true

func stop():
	velocity.x = lerp(velocity.x, 0.0, physics.DECELERATION)

func jump():
	velocity.y = physics.JUMP_VELOCITY

func set_carried(is_carried: bool):
	is_carrying = is_carried

func set_rope(rope: bool):
	pulled = rope

func get_external_anim_player() -> AnimationPlayer:
	return get_tree().get_root().get_node("Tutorial/Anima/AnimationPlayer")
