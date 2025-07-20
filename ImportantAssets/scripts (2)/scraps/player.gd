extends CharacterBody2D

@export var speed: float = 200.0
@export var sprint_speed: float = 350.0
@export var jump_force: float = -400.0
@export var gravity: float = 980.0

@onready var movement = $movement
@onready var jump = $jump
@onready var glide = $glide

func _physics_process(delta: float) -> void:
	velocity = movement.handle_movement(velocity, delta)
	velocity = jump.handle_jump(velocity, delta, is_on_floor())
	velocity = glide.handle_glide(velocity, delta, is_on_floor())
	
	move_and_slide()
