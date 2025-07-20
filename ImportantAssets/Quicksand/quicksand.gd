extends Area2D

@export var sink_rate: float = 5.0              # Pixels per second
@export var disable_movement_depth := 20.0      # Depth where movement is locked
@export var player_path: NodePath               # Assign the Player node in the editor

var player: Node = null
var player_inside := false
var sink_depth := 0.0

func _ready():
	if player_path:
		player = get_node(player_path)

func _process(delta):
	if not player_inside or player == null:
		sink_depth = 0.0
		return

	# Increase sink depth over time
	sink_depth += sink_rate * delta
	player.set_quicksand_state(true, sink_depth)

func _on_body_entered(body: Node) -> void:
	if body == player:
		print("Player entered quicksand")
		player_inside = true
		sink_depth = 0.0

func _on_body_exited(body: Node) -> void:
	if body == player:
		print("Player exited quicksand")
		player_inside = false
		player.set_quicksand_state(false, 0.0)

# This is triggered by a separate Area2D (e.g., QuicksandDeath node inside the sand)
func _on_quicksand_death_body_entered(body: Node) -> void:
	if body == player:
		print("Player fully submerged and died")
		player.die_by_quicksand()
