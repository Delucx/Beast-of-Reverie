extends Node2D

@export var foot_target: Vector2 # The target position for the foot (ankle)
@export var move_speed: float = 5.0 # Speed at which the foot moves

@onready var skeleton = $Skeleton2D

# Bone indices
var ankle_bone_index: int
var knee_bone_index: int
var hip_bone_index: int

# Initial setup to find bone indices
func _ready():
	ankle_bone_index = get_bone_index("Ankle")
	knee_bone_index = get_bone_index("Knee")
	hip_bone_index = get_bone_index("Hip")

# Function to get the bone index by name
func get_bone_index(bone_name: String) -> int:
	for i in range(skeleton.get_bone_count()):
		if skeleton.get_bone(i).name == bone_name:
			return i
	return -1

# Function to move the foot (ankle) towards the target
func _process(delta):
	if ankle_bone_index == -1 or knee_bone_index == -1 or hip_bone_index == -1:
		print("Bone not found!")
		return

	# Move foot towards the target
	var foot_pos = skeleton.get_bone_local_pose_override(ankle_bone_index).origin
	foot_pos = lerp(foot_pos, foot_target, move_speed * delta)

	# Update ankle position
	var ankle_pose = skeleton.get_bone_local_pose_override(ankle_bone_index)
	ankle_pose.origin = foot_pos
	skeleton.set_bone_local_pose_override(ankle_bone_index, ankle_pose, 1.0, true)

	# Update knee and hip positions using basic IK (Inverse Kinematics)
	apply_ik()

# Basic IK to calculate and update knee and hip angles based on the foot's position
func apply_ik():
	var hip_transform = skeleton.get_bone_local_pose_override(hip_bone_index)
	var knee_transform = skeleton.get_bone_local_pose_override(knee_bone_index)

	# Calculate direction vectors
	var to_target = (foot_target - hip_transform.origin).normalized()
	var to_knee = (knee_transform.origin - hip_transform.origin).normalized()

	# Calculate angles for hip and knee to form the correct leg shape
	var hip_angle = to_target.angle()
	var knee_angle = to_target.angle_to(to_knee)

	# Apply the calculated angles to the hip and knee bones
	skeleton.set_bone_local_pose_override(hip_bone_index, Transform2D(hip_angle, hip_transform.origin), 1.0, true)
	skeleton.set_bone_local_pose_override(knee_bone_index, Transform2D(knee_angle, knee_transform.origin), 1.0, true)
