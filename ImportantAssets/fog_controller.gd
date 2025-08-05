extends Node2D

@onready var inner_area = $InnerFogArea
@onready var outer_area = $OuterFogArea
@onready var fog_node = $"../Fog"

var fog_materials: Array[ShaderMaterial] = []

func _ready():
	fog_materials = find_fog_materials() as Array[ShaderMaterial]

func find_fog_materials() -> Array[ShaderMaterial]:
	var results: Array[ShaderMaterial] = []

	if not is_instance_valid(fog_node):
		push_warning("⚠️ Fog node not found near FogController!")
		return results

	var search_paths = ["fog_bg", "fog_midbg", "fog_forebg"]
	for fog_name in search_paths:
		if fog_node.has_node(fog_name):
			var fog_layer = fog_node.get_node(fog_name)
			if fog_layer.get_child_count() > 0:
				var layer = fog_layer.get_child(0)
				if layer and layer.get_child_count() > 0:
					var color_rect = layer.get_child(0)
					if color_rect is ColorRect and color_rect.material is ShaderMaterial:
						# 👇 Duplicate the material to isolate it
						var unique_material = color_rect.material.duplicate()
						color_rect.material = unique_material
						results.append(unique_material)
	return results


func _process(_delta):
	var player = Global.player
	if not is_instance_valid(player):
		return

	var pos = player.global_position

	var outer_shape := outer_area.get_node("CollisionShape2D").shape as RectangleShape2D
	var inner_shape := inner_area.get_node("CollisionShape2D").shape as RectangleShape2D

	var outer_center = outer_area.global_position
	var inner_center = inner_area.global_position

	var dx = abs(pos.x - inner_center.x)
	var dy = abs(pos.y - inner_center.y)

	var dist_x = max(dx - inner_shape.extents.x, 0)
	var dist_y = max(dy - inner_shape.extents.y, 0)

	var dist_to_inner = sqrt(dist_x * dist_x + dist_y * dist_y)
	var outer_radius = outer_shape.extents.length()
	var inner_radius = inner_shape.extents.length()

	var opacity = clamp(1.0 - dist_to_inner / (outer_radius - inner_radius), 0.0, 1.0)

	for mat in fog_materials:
		if is_instance_valid(mat):
			mat.set_shader_parameter("opacity", opacity)
