extends Area2D

var target_in_sight = false
var target = null

func _on_body_entered(body):
	if body.name == "Player":
		target_in_sight = true
		target = body

func _on_body_exited(body):
	if body == target:
		target_in_sight = false
		target = null
