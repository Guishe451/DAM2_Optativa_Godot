extends Node2D

func _on_play_button_pressed():
	# Cuando se pulsa el botón de JUGAR, va a la escena del nivel principal
	get_tree().change_scene_to_file("res://Scenes/MainLevel.tscn")
