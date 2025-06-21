extends Node2D

@export var speed: float = 100.0  # Speed at which the spider moves
@export var leg_amplitude: float = 10.0  # How high the legs lift during walking
@export var leg_speed: float = 1.0  # Speed of leg movement

@onready var spider_body = $SpiderBody
@onready var legs = $Skeleton2D/Legs  # Assuming all the legs are children of SpiderBody
var time_passed: float = 0.0

func _ready():
	# Initialize leg positions or any other setup
	pass

func _process(delta):
	time_passed += delta * leg_speed

	# Move spider body forward
	spider_body.position.x += speed * delta

	# Simulate leg movement (moving up and down as spider walks)
	simulate_leg_movement()

# Simulate the spider leg movement
func simulate_leg_movement():
	for i in range(legs.get_child_count()):
		var leg = legs.get_child(i)
		
		# Get the base position of each leg
		var leg_base = leg.position
		
		# Calculate how much the leg moves up and down (based on the time passed)
		var movement = sin(time_passed + i) * leg_amplitude
		
		# Apply the movement to the leg's position (this creates the walking effect)
		leg.position.y = leg_base.y + movement
		
		# You can add some rotation or animation here if needed, but this basic
		# up-and-down movement will give you a walking effect.
