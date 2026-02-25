extends Node

@export var mob_scene: PackedScene
var score

# Se llama cuando el nodo ingresa al árbol de escena por primera vez.
func _ready():
	pass

# Se llama cada cuadro. 'delta' es el tiempo transcurrido desde el cuadro anterior.
func _process(delta: float) -> void:
	pass

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	$Music.play()

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	# Crea una nueva instancia de la escena Mob.
	var mob = mob_scene.instantiate()

	# Elige una ubicación aleatoria en Path2D
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Establece la posición del monstruo en la ubicación aleatoria.
	mob.position = mob_spawn_location.position

	# Establece la dirección del monstruo perpendicular a la dirección del camino.
	var direction = mob_spawn_location.rotation + PI / 2

	# Añade aleatoriedad a la dirección.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Elige la velocidad del monstruo.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Genera el monstruo añadiéndolo a la escena principal.
	add_child(mob)
