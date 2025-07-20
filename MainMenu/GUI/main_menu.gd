extends Control

func _on_start_button_pressed():
	print("Start game!")


func _on_option_button_pressed():
	print("Open options menu")


func _on_exit_button_pressed():
	get_tree().quit()
