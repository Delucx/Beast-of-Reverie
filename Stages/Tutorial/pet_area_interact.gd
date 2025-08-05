extends Area2D

func _on_body_entered(body):
	if body.is_in_group("pet") and body.has_method("set_rope"):
		#print("Pet entered:", name)
		body.set_rope(true)

func _on_body_exited(body):
	if body.is_in_group("pet") and body.has_method("set_rope"):
		#print("Pet exited:", name)
		body.set_rope(false)
