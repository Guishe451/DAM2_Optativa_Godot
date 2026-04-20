extends Node2D

# Referencia al nodo
@onready var music = $AudioStreamPlayer

# Durada total de la partida en segons (es pot canviar des de l'Inspector)
@export var temps_total : float = 30.0
# Temps restant de la partida
var temps_restant : float = temps_total
# Controla si la partida encara està en curs
var partida_activa : bool = true

func _ready():
	# Inicialitzem la musica
	music.play()  # Reproducir

func pausar_musica():
	music.stream_paused = true

func reanudar_musica():
	music.stream_paused = false

func parar_musica():
	music.stop()

	# Inicialitzem el temps restant
	temps_restant = temps_total
	
	# Amaguem els labels de powerup, temps extra i amor al inici
	$HUD/TempsExtraLabel.visible = false
	$HUD/PowerUpLabel.visible = false
	
	# Connectem la nota positiva al detector de col·lisions
	var nota_positiva = $GradePositives/GradePositive
	if nota_positiva:
		nota_positiva.body_entered.connect(_on_check_collision_in_main)
	
	# Connectem la nota negativa al detector de col·lisions
	var nota_negativa = $GradeNegatives/GradeNegative
	if nota_negativa:
		nota_negativa.body_entered.connect(_on_check_collision_in_main)

func _process(delta):
	var jugador = $Player
	if jugador:
		# Actualitzem el label de punts
		$HUD/PuntsLabel.text = "Punts: " + str(jugador.punts)
		
		# Si hi ha penalització activa mostrem el comptador
		if jugador.penalty_time_left > 0:
			$HUD/PenaltyLabel.visible = true
			# ceil() arrodoneix cap amunt (2.3 → 3) per mostrar nombres enters
			$HUD/PenaltyLabel.text = "Penalització: " + str(ceil(jugador.penalty_time_left))
		else:
			# Amaguem el label quan no hi ha penalització
			$HUD/PenaltyLabel.visible = false
	
	# Només comptem el temps si la partida està activa
	if partida_activa:
		if temps_restant > 0:
			# Restem el temps que ha passat aquest frame
			temps_restant -= delta
			# Mostrem el temps restant arrodonit cap amunt
			$HUD/TimerLabel.text = "Temps: " + str(ceil(temps_restant))
		else:
			# Quan arriba a 0, aturem la partida i cridem la funció de fi
			temps_restant = 0
			partida_activa = false
			$HUD/TimerLabel.text = "Temps: 0"
			_fi_de_partida()

# Funció que s'executa quan el cronòmetre arriba a 0
# Atura el jugador, calcula la nota final i canvia a la pantalla de resultats
func _fi_de_partida():
	# Aturem el jugador perquè no es pugui seguir movent
	$Player.set_physics_process(false)
	
	# Obtenim els punts del jugador
	var punts = $Player.punts
	var missatge = ""
	
	# Triem el missatge segons la puntuació acumulada
	if punts >= 90:
		missatge = "Excel·lent! Marianao Boi és el nou CTO de Sant Boi."
	elif punts >= 70:
		missatge = "Notable! Ets tot un professional"
	elif punts >= 60:
		missatge = "Bé! Es nota que t'has esforçat"
	elif punts >= 50:
		missatge = "Aprovat! Ja tens el títol de DAM sota el braç."
	else:
		missatge = "S'ha intentat... Ens veiem al setembre!"
	
	# Guardem les dades al GameData (Autoload) perquè la nova escena les pugui llegir
	GameData.punts_finals = punts
	GameData.missatge_final = missatge
	
	# Esperem 1 segon abans de canviar de pantalla per no tallar-ho bruscament
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/ResultScreen.tscn")

# Funció que mostra +5 seg durant 2 segons i desapareix
# Viu aquí al MainLevel perquè la Bebida fa queue_free() i
# cancel·laria l'await si estigués al seu propi script
func mostrar_temps_extra():
	$HUD/TempsExtraLabel.text = "+5 seg!"
	$HUD/TempsExtraLabel.visible = true
	await get_tree().create_timer(2.0).timeout
	$HUD/TempsExtraLabel.visible = false

# Funció que mostra el compte enrere del doble salt
# Viu aquí pel mateix motiu que mostrar_temps_extra()
func mostrar_powerup_label(durada):
	$HUD/PowerUpLabel.visible = true
	var temps = durada
	while temps > 0:
		$HUD/PowerUpLabel.text = "Doble Salt actiu! " + str(int(temps)) + "s"
		await get_tree().create_timer(1.0).timeout
		temps -= 1
	$HUD/PowerUpLabel.visible = false

# Funció que mostra el missatge de penalització de l'Amor de Verano
# Reutilitzem el PowerUpLabel per mostrar el missatge
# La lògica viu aquí perquè l'AmorDeVerano no fa queue_free()
# però és més net tenir tota la UI centralitzada al MainLevel
func mostrar_penalitzacio_amor(missatge):
	$HUD/PowerUpLabel.text = missatge
	$HUD/PowerUpLabel.visible = true
	await get_tree().create_timer(2.0).timeout
	$HUD/PowerUpLabel.visible = false

# Funció que s'activa quan el jugador toca una nota
func _on_check_collision_in_main(body):
	if body is Jugador:
		# Canviem el color del sprite breument per indicar que ha recollit la nota
		var sprite = body.get_node_or_null("Sprite2D")
		if sprite:
			sprite.modulate = Color.GREEN
			await get_tree().create_timer(0.2).timeout
			sprite.modulate = Color.WHITE


func _on_kill_zone_body_entered(body):
	if body.has_method("respawn"):
		body.respawn()
