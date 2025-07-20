extends Node

enum GrappleMode { SINGLE, DUAL }

@export var grapple_mode: GrappleMode = GrappleMode.SINGLE
@export var left_grapple_path: NodePath
@export var right_grapple_path: NodePath
@export var player_path: NodePath

@onready var left_grapple := get_node(left_grapple_path)
@onready var right_grapple := get_node(right_grapple_path)
@onready var player := get_node(player_path)

func _unhandled_input(event):
	if event.is_action_pressed("grapple_shoot"):
		match grapple_mode:
			GrappleMode.SINGLE:
				if not left_grapple.launched and not left_grapple.traveling:
					left_grapple.begin_grapple()
				elif not right_grapple.launched and not right_grapple.traveling:
					right_grapple.begin_grapple()
			GrappleMode.DUAL:
				if not left_grapple.launched and not right_grapple.launched:
					left_grapple.begin_grapple()
					right_grapple.begin_grapple()

# ✅ Add this method for Player.gd to check if grappling is active
func is_any_grappling() -> bool:
	return left_grapple.launched or right_grapple.launched
