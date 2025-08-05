# StartMapTrigger.gd
extends Area2D

@export var world_path: NodePath  # Drag the World node here in the editor
@export var player_path: NodePath  # Drag the player node here in the editor

var world: Node
var player: Node

func _ready():
	world = get_node(world_path)
	player = get_node(player_path)
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body != player:
		return

	print("🌍 Triggered loop transition from start map.")
	var start_map = get_parent()
	var map_position = start_map.position

	#start_map.queue_free()
	world.spawn_loop_map(Vector2(1, 0), map_position)
