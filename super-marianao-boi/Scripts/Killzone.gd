extends Area2D

func _on_body_entered(body):
	# Comprobamos si el cuerpo que entró tiene la función "respawn"
	# Así nos aseguramos de que solo afecta al jugador y no a otros objetos
	if body.has_method("respawn"):
		# Llamamos la función respawn del jugador para reaparecer en el spawn
		body.respawn()
