extends Node2D

# Referencia al nodo AnimatedSprite2D llamado "PlayerGreeting" en la escena
@onready var player_sprite = $PlayerGreeting  

func _ready():
	# Cuando se carga la escena, reproduce automáticamente la animación "Greeting"
	player_sprite.play("Greeting")

func _on_play_button_pressed():
	# Cuando se pulsa el botón de jugar, cambia a la escena del nivel principal
	get_tree().change_scene_to_file("res://Scenes/MainLevel.tscn")

func _on_tutorial_button_pressed():
	# Cuando se pulsa el botón de tutorial, cambia a la escena del tutorial
	get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")
