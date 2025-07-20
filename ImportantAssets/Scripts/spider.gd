extends CharacterBody2D

@onready var skeleton: Skeleton2D = $Skeleton2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var time := 0.0
var swing_amplitude := 20.0
var swing_speed := 2.5
var phase_offset := PI / 2

# Gravity constants
var gravity := 500.0  # Adjust based on your game scale
var gravity_factor := 0.1

# Leg definitions (ensure paths are relative to the spider node)
var legs := [
	{
		"hip": "L1_Hip",
		"knee": "L1_Hip/L1_Knee",
		"foot": "L1_Hip/L1_Knee/L1_Foot",
		"ray": "L1_Hip/L1_Knee/L1_Foot/RayCast2D",
		"phase": 0.0
	},
	{
		"hip": "L2_Hip",
		"knee": "L2_Hip/L2_Knee",
		"foot": "L2_Hip/L2_Knee/L2_Foot",
		"ray": "L2_Hip/L2_Knee/L2_Foot/RayCast2D",
		"phase": PI
	},
	{
		"hip": "R1_Hip",
		"knee": "R1_Hip/R1_Knee",
		"foot": "R1_Hip/R1_Knee/R1_Foot",
		"ray": "R1_Hip/R1_Knee/R1_Foot/RayCast2D",
		"phase": phase_offset
	},
	{
		"hip": "R2_Hip",
		"knee": "R2_Hip/R2_Knee",
		"foot": "R2_Hip/R2_Knee/R2_Foot",
		"ray": "R2_Hip/R2_Knee/R2_Foot/RayCast2D",
		"phase": PI + phase_offset
	}
]

func _ready():
	# Initialize spider's velocity and gravity settings.
	velocity = Vector2.ZERO
	# Optionally adjust collision shape or other properties.
	# Ensure the RayCasts are active
	for leg in legs:
		var ray: RayCast2D = get_node(leg["ray"])
		if ray:
			ray.enabled = true
		else:
			print("RayCast2D not found for leg:", leg)

func _process(delta):
	time += delta

	# Handle gravity for the spider
	velocity.y += gravity * delta
	move_and_slide(velocity)  # Corrected the move_and_slide call

	# Call the function to animate the legs with terrain adaptation
	animate_legs(delta)

func animate_legs(delta):
	# Loop through each leg and update bone rotations based on sine wave motion
	for leg in legs:
		var t = time * swing_speed + leg["phase"]

		var hip_angle = deg_to_rad(swing_amplitude) * sin(t)
		var knee_angle = deg_to_rad(15) * sin(t * 1.2)
		var foot_angle = deg_to_rad(10) * sin(t * 1.5)

		var hip: Bone2D = get_node(leg["hip"])
		var knee: Bone2D = get_node(leg["knee"])
		var foot: Bone2D = get_node(leg["foot"])
		var ray: RayCast2D = get_node(leg["ray"])

		# Check if nodes exist before proceeding
		if hip == null:
			print("Hip not found for leg:", leg)
		if knee == null:
			print("Knee not found for leg:", leg)
		if foot == null:
			print("Foot not found for leg:", leg)
		if ray == null:
			print("RayCast2D not found for leg:", leg)

		# Animate the bones with the sinusoidal motion
		if hip:
			hip.rotation = hip_angle
		if knee:
			knee.rotation = knee_angle
		if foot:
			foot.rotation = foot_angle

		# IK Terrain adaptation (keep the feet planted on terrain)
		if ray and ray.is_colliding():
			var hit_pos = ray.get_collision_point()
			var local_pos = foot.to_local(hit_pos)

			# Move foot position independently of its previous position
			if foot:
				foot.position = foot.position.lerp(Vector2(foot.position.x, local_pos.y), 0.2)

			# Adjust the knee angle for terrain detection
			var knee_target_angle = atan2(hit_pos.y - foot.position.y, foot.position.x - knee.position.x)
			if knee:
				knee.rotation = knee_target_angle
		else:
			# Smooth transition when foot leaves the terrain
			if foot:
				foot.position.y = lerp(foot.position.y, foot.position.y + 10, 0.1) # adjust the smoothness factor
