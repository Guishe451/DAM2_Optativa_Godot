extends Area2D

signal hit

@export var speed = 400 # Qué tan rápido se moverá el jugador (píxeles/seg).
var screen_size # Tamaño de la ventana del juego.

# Se llama cuando el nodo ingresa al árbol de escena por primera vez.
func _ready():
	screen_size = get_viewport_rect().size

	hide()

# Se llama cada cuadro. 'delta' es el tiempo transcurrido desde el cuadro anterior.
func _process(delta):
	var velocity = Vector2.ZERO # El vector de movimiento del jugador.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "caminar"
		$AnimatedSprite2D.flip_v = false
		# Vea la nota a continuación sobre la siguiente asignación booleana.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "arriba"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func _on_body_entered(_body):
	hide() # El jugador desaparece después de ser golpeado.
	hit.emit()
	# Debe posponerse ya que no podemos cambiar las propiedades físicas en una devolución de llamada física.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
