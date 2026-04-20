extends Node2D

func _ready():
	# Cuando se carga la escena de resultados, leemos los datos guardados
	# en el Singleton "GameData" para mostrarlos en pantalla

	# Muestra la puntuación final en el label correspondiente
	# Convierte el número a texto con str() para poder concatenarlo
	$Control/ColorRect/ScoreLabel.text = "Puntuació: " + str(GameData.punts_finals)

	# Muestra el mensaje final (por ejemplo "Has guanyat!" o "Has perdut!")
	$Control/ColorRect/MissageLabel.text = GameData.missatge_final

func _on_back_button_pressed():
	# Cuando se pulsa el botón de volver, regresa a la escena del nivel principal
	get_tree().change_scene_to_file("res://Scenes/MainLevel.tscn")
