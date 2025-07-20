extends Area2D

@export var fog_rect_paths: Array[String] = [
	"/root/World2D/fog_bg/ParallaxLayer/ColorRect",
	"/root/World2D/fog_midbg/ParallaxLayer2/ColorRect",
	"/root/World2D/fog_forebg/ParallaxLayer3/ColorRect"
]
@export var duration: float = 5

var fog_materials: Array[ShaderMaterial] = []
var tween: Tween

func _ready():
	for path in fog_rect_paths:
		var node = get_node_or_null(path)
		if node and node is ColorRect and node.material is ShaderMaterial:
			var mat = node.material as ShaderMaterial
			mat.set_shader_parameter("opacity", 0.0)  # Start hidden
			fog_materials.append(mat)
		else:
			push_warning("Fog path invalid or missing ShaderMaterial: " + path)

func _on_body_entered(body):
	if body.name == "Player":
		print_debug("Player entered fog area")
		_fade_fog_to(1.0)  # Fade in

func _on_body_exited(body):
	if body.name == "Player":
		print_debug("Player exited fog area")
		_fade_fog_to(0.0)  # Fade out

func _fade_fog_to(target: float):
	if tween:
		tween.kill()
	tween = create_tween()
	for mat in fog_materials:
		tween.tween_property(mat, "shader_parameter/opacity", target, duration)
