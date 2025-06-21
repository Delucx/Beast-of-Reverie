extends CharacterBody2D

@onready var front_check = $FrontCheck
@onready var low_mid_check = $LowMidCheck
@onready var high_mid_check = $HighMidCheck
@onready var back_check = $BackCheck
@onready var low_mid_check2 = $LowMidCheck2
@onready var high_mid_check2 = $HighMidCheck2

@onready var front_legs = $FrontLegs.get_children()
@onready var back_legs = $BackLegs.get_children()
@onready var spider_visual = $Sprite2D

@export var x_speed = 60
@export var y_speed = 40
@export var idle_distance_threshold = 200

@export var step_rate = 0.5
var time_since_last_step = 0
var cur_f_leg = 0
var cur_b_leg = 0
var use_front = false
 
var target_in_sight = false
var target = null

var vertical_velocity = 0.0

func _ready():
	front_check.force_raycast_update()
	back_check.force_raycast_update()
	for i in range(4):
		step()
 
func _process(delta):
	if !target_in_sight or !target:
		return  # Don't step legs while idle

	# Idle near target
	if global_position.distance_to(target.global_position) <= idle_distance_threshold:
		return

	time_since_last_step += delta
	if time_since_last_step >= step_rate:
		time_since_last_step = 0
		step()

func _physics_process(delta):
	if not target_in_sight or not target:
		return

	var distance = global_position.distance_to(target.global_position)

	# Determine facing direction
	var facing_left = target.global_position.x < global_position.x
	spider_visual.scale.x = -1 if facing_left else 1

	if facing_left:
		back_check.position.x = -250
		front_check.position.x = 100
	else:
		back_check.position.x = -100
		front_check.position.x = 250

	var move_vec = Vector2.ZERO
	
	print_debug(global_position)
	if distance > idle_distance_threshold:
		var dir = (target.global_position - global_position).normalized()
		move_vec.x = dir.x * x_speed

		if (high_mid_check.is_colliding() or high_mid_check2.is_colliding()):
			vertical_velocity = -y_speed

		if !(low_mid_check.is_colliding() and low_mid_check2.is_colliding()):
			vertical_velocity = y_speed

		move_vec.y = vertical_velocity
		
	move_and_collide(move_vec * delta)

func step():
	var leg = null
	var sensor = null
	if use_front:
		leg = front_legs[cur_f_leg]
		cur_f_leg += 1
		cur_f_leg %= front_legs.size()
		sensor = front_check
	else:
		leg = back_legs[cur_b_leg]
		cur_b_leg += 1
		cur_b_leg %= back_legs.size()
		sensor = back_check
	use_front = !use_front
 
	var leg_target = sensor.get_collision_point()
	leg.step(leg_target)

func _on_vision_area_body_entered(body):
	if body.name == "Player":  # Or whatever your target's name/class is
		target_in_sight = true
		target = body

func _on_vision_area_body_exited(body):
	if body == target:
		target_in_sight = false
		target = null
