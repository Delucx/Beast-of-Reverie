extends Node2D

@onready var skeleton: Skeleton2D = $Skeleton2D
@onready var foot_target: Node2D = $FootTarget_L1

var time := 0.0
var swing_amplitude_deg := 20
var swing_speed := 3.0
var phase_offset := PI / 2

var leg_length_hip_to_knee := 50.0
var leg_length_knee_to_foot := 50.0

var legs = []  # Declare empty list first

func _ready():
	# Now safe to access foot_target
	legs = [
		{
			"hip": "L1_Hip",
			"knee": "L1_Hip/L1_Knee",
			"foot": "L1_Hip/L1_Knee/L1_Foot",
			"target": foot_target,
			"phase": 0
		}
	]

func _process(delta):
	time += delta

	for leg in legs:
		var foot_target_node = leg.target
		if foot_target_node == null:
			push_error("Missing foot target node in leg definition.")
			continue

		var hip_bone = skeleton.get_node(leg.hip)
		var knee_bone = skeleton.get_node(leg.knee)
		var foot_bone = skeleton.get_node(leg.foot)

		if hip_bone == null or knee_bone == null or foot_bone == null:
			push_error("Missing one or more bones in leg: %s" % leg)
			continue

		var target_pos = foot_target_node.global_position
		var hip_pos = hip_bone.global_position

		var hip_to_target = target_pos - hip_pos
		var distance = hip_to_target.length()
		distance = clamp(distance, 0.1, leg_length_hip_to_knee + leg_length_knee_to_foot - 1)

		var a = leg_length_hip_to_knee
		var b = leg_length_knee_to_foot
		var c = distance

		var angle_knee = acos((a * a + b * b - c * c) / (2 * a * b))
		var angle_hip = hip_to_target.angle() - acos((a * a + c * c - b * b) / (2 * a * c))

		hip_bone.rotation_degrees = rad_to_deg(angle_hip)
		knee_bone.rotation_degrees = rad_to_deg(PI - angle_knee)
		foot_bone.rotation_degrees = 0  # optional
