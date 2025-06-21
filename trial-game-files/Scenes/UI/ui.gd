extends Control

@onready var grapple_cooldown_bar: ProgressBar = $ProgressBar

func set_grapple_length(current: float, max_val: float) -> void:
	if grapple_cooldown_bar:
		grapple_cooldown_bar.max_value = max_val
		grapple_cooldown_bar.value = clamp(current, 0, max_val)
