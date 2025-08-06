extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

var transition_duration := 3.0

func _ready():
	fade_rect.modulate.a = 0.0  # Ensure transparent on start
	fade_rect.visible = true

func fade_to_scene(scene_path: String):
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, transition_duration)
	await tween.finished
	get_tree().change_scene_to_file(scene_path)
