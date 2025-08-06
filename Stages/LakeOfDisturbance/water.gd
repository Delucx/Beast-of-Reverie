extends Node2D

@onready var shader_material := $WaterSprite.material as ShaderMaterial

func _process(delta):
	shader_material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
