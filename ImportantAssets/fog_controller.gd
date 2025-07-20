extends Node2D

@export var player_path: NodePath
@export var fog_rect_paths: Array[String]
@onready var player = get_node(player_path)
@onready var inner_area = $InnerFogArea
@onready var outer_area = $OuterFogArea

var fog_materials: Array[ShaderMaterial] = []

func _ready():
	for path in fog_rect_paths:
		var node = get_node_or_null(path)
		if node and node is ColorRect and node.material is ShaderMaterial:
			fog_materials.append(node.material)
			print_debug("Fog material found for path: %s" % path)
		else:
			push_warning("Invalid fog path or missing ShaderMaterial: %s" % path)

func _process(delta):
	if not player:
		return

	var outer_shape := outer_area.get_node("CollisionShape2D").shape as RectangleShape2D
	var inner_shape := inner_area.get_node("CollisionShape2D").shape as RectangleShape2D

	var outer_center = outer_area.global_position
	var inner_center = inner_area.global_position
	var player_pos = player.global_position

	# For rectangle shape, extents is half size of box in x and y
	# We'll calculate distance from player to inner box edge using axis distances

	# Calculate distance from player to inner box center on each axis
	var dx = abs(player_pos.x - inner_center.x)
	var dy = abs(player_pos.y - inner_center.y)

	# Calculate how far player is outside inner box on each axis (0 if inside)
	var dist_x = max(dx - inner_shape.extents.x, 0)
	var dist_y = max(dy - inner_shape.extents.y, 0)

	# Euclidean distance outside inner box (0 if inside)
	var dist_to_inner = sqrt(dist_x * dist_x + dist_y * dist_y)

	# Calculate outer box radius approximation (using diagonal)
	var outer_radius = outer_shape.extents.length()
	var inner_radius = inner_shape.extents.length()

	# Calculate opacity as linear fade from inner_radius to outer_radius
	var opacity = clamp(1.0 - (dist_to_inner) / (outer_radius - inner_radius), 0.0, 1.0)
	print_debug(dist_to_inner)
	
	# Apply opacity to all fog materials
	for mat in fog_materials:
		mat.set_shader_parameter("opacity", opacity)
