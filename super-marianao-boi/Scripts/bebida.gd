extends Area2D

# Tipus de beguda: una suma temps, l'altra dona doble salt
@export_enum("Beguda", "PowerUp Doble Salt") var tipus: String = "Beguda"

# Imatges de cada tipus
const TIPUS_IMAGES = {
	"Beguda":             preload("res://assets/Drinks/bebida.png"),
	"PowerUp Doble Salt": preload("res://assets/Drinks/PowerUP Doble Salt.png")
}

# Segons que afegeix la beguda normal al comptador
const SEGONS_EXTRA = 5.0

# Segons que dura el poder de doble salt
const DURADA_DOBLE_SALT = 10.0

func _ready():
	# Assigna la imatge correcta segons el tipus escollit
	$Sprite2D.texture = TIPUS_IMAGES[tipus]
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Jugador:
		# Obtenim el MainLevel per cridar les seves funcions
		var main = get_tree().root.get_node("MainLevel")
		
		if tipus == "Beguda":
			# Sumem temps al comptador del MainLevel
			main.temps_restant += SEGONS_EXTRA
			# Demanem al MainLevel que mostri el +5 (així l'await no es cancel·la)
			main.mostrar_temps_extra()
		
		elif tipus == "PowerUp Doble Salt":
			# Activem el doble salt al jugador
			body.activar_doble_salt(DURADA_DOBLE_SALT)
			# Demanem al MainLevel que mostri el compte enrere
			main.mostrar_powerup_label(DURADA_DOBLE_SALT)
		
		# Eliminem la beguda de l'escena
		queue_free()
