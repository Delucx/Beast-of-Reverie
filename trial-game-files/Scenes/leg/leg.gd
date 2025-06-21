extends Marker2D

@onready var joint1 = $Joint1
@onready var joint2 = joint1.get_node("Joint2")
@onready var hand = joint2.get_node("Hand")

@export var flipped = true

# These are base values, scaled during _ready
const BASE_MIN_DIST = 100
const BASE_STEP_HEIGHT = 40

var MIN_DIST = 0
var step_height = 0

var len_upper = 0
var len_middle = 0
var len_lower = 0

var goal_pos = Vector2()
var int_pos = Vector2()
var start_pos = Vector2()
var step_rate = 1
var step_time = 0.0

func _ready():
	var scale_factor = get_parent().scale.x  # assumes spider body is the parent
	
	# Apply scale to distances
	MIN_DIST = BASE_MIN_DIST * scale_factor
	step_height = BASE_STEP_HEIGHT * scale_factor
	
	# Apply scale to limb lengths
	len_upper = joint1.position.x * scale_factor
	len_middle = joint2.position.x * scale_factor
	len_lower = hand.position.x * scale_factor

func step(g_pos):
	if goal_pos == g_pos:
		return

	goal_pos = g_pos
	var hand_pos = hand.global_position

	var highest = min(goal_pos.y, hand_pos.y)
	var mid = (goal_pos.x + hand_pos.x) / 2.0
	start_pos = hand_pos
	int_pos = Vector2(mid, highest - step_height)
	step_time = 0.0

func _process(delta):
	step_time += delta
	var t = step_time / step_rate
	var target_pos: Vector2
	if t < 0.5:
		target_pos = start_pos.lerp(int_pos, t / 0.5)
	elif t < 1.0:
		target_pos = int_pos.lerp(goal_pos, (t - 0.5) / 0.5)
	else:
		target_pos = goal_pos
	update_ik(target_pos)

func update_ik(target_pos):
	var offset = target_pos - global_position
	var dis_to_tar = offset.length()
	if dis_to_tar < MIN_DIST:
		offset = (offset / dis_to_tar) * MIN_DIST
		dis_to_tar = MIN_DIST

	var base_r = offset.angle()
	var len_total = len_upper + len_middle + len_lower
	var len_dummy_side = (len_upper + len_middle) * clamp(dis_to_tar / len_total, 0.0, 1.0)

	var base_angles = SSS_calc(len_dummy_side, len_lower, dis_to_tar)
	var next_angles = SSS_calc(len_upper, len_middle, len_dummy_side)

	global_rotation = base_angles.B + next_angles.B + base_r
	joint1.rotation = next_angles.C
	joint2.rotation = base_angles.C + next_angles.A

func SSS_calc(side_a, side_b, side_c):
	if side_c >= side_a + side_b:
		return {"A": 0, "B": 0, "C": 0}
	var angle_a = law_of_cos(side_b, side_c, side_a)
	var angle_b = law_of_cos(side_c, side_a, side_b) + PI
	var angle_c = PI - angle_a - angle_b

	if flipped:
		angle_a = -angle_a
		angle_b = -angle_b
		angle_c = -angle_c

	return {"A": angle_a, "B": angle_b, "C": angle_c}

func law_of_cos(a, b, c):
	if 2 * a * b == 0:
		return 0
	return acos((a * a + b * b - c * c) / (2 * a * b))
