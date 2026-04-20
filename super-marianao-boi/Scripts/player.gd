extends CharacterBody2D
class_name Jugador

@export var speed : float = 300.0
@export var jump_velocity : float = -400.0

var punts = 0
var can_collect : bool = true

# Obtenim la gravetat del projecte
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variable que guarda el temps de penalització restant
var penalty_time_left : float = 0.0

# Durada total de la penalització en segons
const PENALTY_DURATION : float = 3.0

# Variables per al parpadeig quan la pilota toca el jugador
var invencible = false
const TEMPS_INVENCIBLE = 2.0    # Segons que dura la invencibilitat
const VEGADES_PARPADEIG = 10    # Quantes vegades parpadeja
const VELOCITAT_PARPADEIG = 0.1 # Segons entre cada parpadeig

# Variables per al doble salt
var doble_salt_actiu = false   # Si el powerup està actiu
var pot_fer_doble_salt = false  # Si encara li queda el salt extra

# Variable que guarda la posició inicial del jugador per al respawn
var spawn_position : Vector2


func _ready():
	# Guardem la posició inicial com a punt de reaparició
	spawn_position = global_position
	# Asegura que la cámara está activa
	$Camera2D.make_current()


func _physics_process(delta):
	# Apliquem gravetat quan no estem al terra
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Salt normal i doble salt
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			# Salt normal des del terra
			velocity.y = jump_velocity
			if doble_salt_actiu:
				# Recarreguem el doble salt cada vegada que toquem terra
				pot_fer_doble_salt = true
		elif doble_salt_actiu and pot_fer_doble_salt:
			# Doble salt quan estem a l'aire
			velocity.y = jump_velocity
			pot_fer_doble_salt = false  # Ja hem usat el doble salt

	# Moviment horitzontal i animacions
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction > 0:
		velocity.x = direction * speed
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walk_right")
	elif direction < 0:
		velocity.x = direction * speed
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walk_left")
	else:
		# Si no hi ha direcció, frenem suaument
		velocity.x = move_toward(velocity.x, 0, speed)
		$AnimatedSprite2D.play("idle")
	
	move_and_slide()


func _process(delta):
	# Anem restant el temps de penalització si n'hi ha
	if penalty_time_left > 0:
		penalty_time_left -= delta
		if penalty_time_left <= 0:
			penalty_time_left = 0
			can_collect = true
			print("Penalització acabada. Ja pots recollir notes!")


# Funció per modificar punts SENSE penalització
# S'usa quan el jugador recull notes negatives
func modificar_punts(quantitat):
	punts += quantitat
	if quantitat >= 0:
		print("Has guanyat ", quantitat, " punts! Total: ", punts)
	else:
		print("Has perdut ", abs(quantitat), " punts! Total: ", punts)


# Funció per modificar punts AMB penalització
# S'usa quan el jugador recull notes positives
func guanyar_punts(quantitat):
	punts += quantitat
	if quantitat >= 0:
		print("Has guanyat ", quantitat, " punts! Total: ", punts)
	else:
		print("Has perdut ", abs(quantitat), " punts! Total: ", punts)
		# Quan perdem punts per aquesta via, iniciem la penalització
		iniciar_penalitzacio()


# Funció per iniciar la penalització
func iniciar_penalitzacio():
	can_collect = false
	penalty_time_left = PENALTY_DURATION


# Funció que s'activa quan la pilota toca el jugador
func rebre_cop():
	# Si ja som invencibles, ignorem el cop
	if invencible:
		return
	invencible = true
	# Iniciem la penalització de punts
	iniciar_penalitzacio()
	# Iniciem el parpadeig visual
	parpadear()


# Funció que fa parpadear el sprite del jugador
func parpadear():
	for i in VEGADES_PARPADEIG:
		$AnimatedSprite2D.modulate.a = 0.2  # Quasi transparent
		await get_tree().create_timer(VELOCITAT_PARPADEIG).timeout
		$AnimatedSprite2D.modulate.a = 1.0  # Visible
		await get_tree().create_timer(VELOCITAT_PARPADEIG).timeout
	
	# Al acabar el parpadeig, el jugador deixa de ser invencible
	invencible = false
	# Ens assegurem que queda completament visible
	$AnimatedSprite2D.modulate.a = 1.0


# Funció que activa el doble salt durant un temps limitat
func activar_doble_salt(durada):
	doble_salt_actiu = true
	pot_fer_doble_salt = false
	print("Doble salt activat durant ", durada, " segons!")
	await get_tree().create_timer(durada).timeout
	doble_salt_actiu = false
	pot_fer_doble_salt = false
	print("Doble salt desactivat!")

func _on_penalty_timer_timeout():
	can_collect = true
	print("Penalització acabada. Ja pots recollir notes!")

# Funció que teleporta el jugador al punt d'inici quan cau al buit
# S'ha de cridar des del script de la KillZone
func respawn():
	# Resetegem la velocitat perquè no arrossegui la velocitat de la caiguda
	velocity = Vector2.ZERO
	# Amaguem el jugador un instant per fer l'efecte de reaparició
	visible = false
	await get_tree().create_timer(0.4).timeout
	# El tornem a la posició inicial
	global_position = spawn_position
	visible = true

func aturar_jugador():
	set_physics_process(false)
