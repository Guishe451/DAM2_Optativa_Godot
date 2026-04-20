extends CharacterBody2D

@export var speed : float = 200.0

# Obtenim la gravetat del projecte
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# La pilota comença movent-se cap a la dreta
	velocity.x = speed

func _physics_process(delta):
	# Apliquem gravetat quan no estem al terra
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Movem la pilota i detectem col·lisions
	move_and_slide()
	
	# Si toca una paret, invertim la direcció horitzontal
	if is_on_wall():
		velocity.x = -velocity.x
	
	# Si toca el terra o el sostre, invertim la direcció vertical
	if is_on_floor() or is_on_ceiling():
		velocity.y = -velocity.y
	
	# Comprovem totes les col·lisions d'aquest frame
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Si hem tocat el jugador...
		if collider is Jugador:
			collider.iniciar_penalitzacio()  # Iniciem la penalització de punts
			collider.rebre_cop()             # Iniciem el parpadeig visual
