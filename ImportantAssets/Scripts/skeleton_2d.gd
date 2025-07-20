extends Node2D

@onready var skeleton: Skeleton2D = $Spider/Skeleton2D

var time := 0.0
var swing_amplitude := 20.0
var swing_speed := 3.0

var legs = [
	{ "hip": "Spider/Skeleton2D/L1_Hip",
	"knee": "Spider/Skeleton2D/L1_Hip/L1_Knee", 
	"foot": "Spider/Skeleton2D/L1_Hip/L1_Knee/L1_Foot", 
	"target": $FootTarget_L1,
	"phase": 0.0 },
	
	{ "hip": "Spider/Skeleton2D/L1_Hip", 
	"knee": "Spider/Skeleton2D/L1_Hip/L1_Knee", 
	"foot": "Spider/Skeleton2D/L1_Hip/L1_Knee/L1_Foot", 
	"target": $"FootTarget_L2", 
	"phase": 0.0 },
	
	{ "hip": "Spider/Skeleton2D/L1_Hip", 
	"knee": "Spider/Skeleton2D/L1_Hip/L1_Knee", 
	"foot": "Spider/Skeleton2D/L1_Hip/L1_Knee/L1_Foot", 
	"target": $"FootTarget_R1", 
	"phase": 0.0 },
	
	{ "hip": "Spider/Skeleton2D/L1_Hip", 
	"knee": "Spider/Skeleton2D/L1_Hip/L1_Knee", 
	"foot": "Spider/Skeleton2D/L1_Hip/L1_Knee/L1_Foot", 
	"target": $"FootTarget_R2", 
	"phase": 0.0 },
]

func _process(delta):
	time += delta

	for leg in legs:
		var t = time * swing_speed + leg.phase
		var hip_bone = skeleton.get_node_or_null(leg.hip)
		var knee_bone = skeleton.get_node_or_null(leg.knee)
		var foot_bone = skeleton.get_node_or_null(leg.foot)
		var target_node = leg.get("target", null)

		if hip_bone and knee_bone and foot_bone and target_node:
			var hip_pos = hip_bone.global_position
			var target_pos = target_node.global_position
			var vec = target_pos - hip_pos
			var dist = clamp(vec.length(), 1.0, leg.length_upper + leg.length_lower - 1.0)

			var a = leg.length_upper
			var b = leg.length_lower
			var c = dist

			var angle_knee = acos((a*a + b*b - c*c) / (2 * a * b))
			var angle_hip = vec.angle() - acos((a*a + c*c - b*b) / (2 * a * c))

			hip_bone.rotation_degrees = rad_to_deg(angle_hip)
			knee_bone.rotation_degrees = rad_to_deg(PI - angle_knee)
			foot_bone.rotation_degrees = 0
