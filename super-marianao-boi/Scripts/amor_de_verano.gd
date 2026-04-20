extends Area2D

# Imatge del personatge
const IMATGE = preload("res://assets/AmorDeVerano/Amor de Verano.png")

# Distàncies de les zones
const ZONA_LLUNYANA = 150.0  # píxels
const ZONA_PROPERA  = 80.0   # píxels

# Penalitzacions en segons
const PENALITZACIO_LLUNYANA = 3.0
const PENALITZACIO_PROPERA  = 10.0

# Temps mínim entre penalitzacions per no restar constantment
const TEMPS_ENTRE_PENALITZACIONS = 2.0

# Controla si podem penalitzar o estam en cooldown
var pot_penalitzar = true

func _ready():
	$Sprite2D.texture = IMATGE

func _process(_delta):
	# Obtenim el jugador
	var jugador = get_tree().root.get_node_or_null("MainLevel/Player")
	if not jugador:
		return
	
	# Calculem la distància entre el personatge i el jugador
	var distancia = global_position.distance_to(jugador.global_position)
	
	# Comprovem en quina zona està el jugador
	if distancia <= ZONA_PROPERA and pot_penalitzar:
		# Zona de perill: resta 10 segons
		aplicar_penalitzacio(PENALITZACIO_PROPERA, "Distret per l'amor! -10s")
	elif distancia <= ZONA_LLUNYANA and pot_penalitzar:
		# Zona de distracció: resta 3 segons
		aplicar_penalitzacio(PENALITZACIO_LLUNYANA, "T'has distret! -3s")

func aplicar_penalitzacio(segons, missatge):
	pot_penalitzar = false
	
	# Restem el temps al cronòmetre del MainLevel
	var main = get_tree().root.get_node("MainLevel")
	main.temps_restant -= segons
	main.mostrar_penalitzacio_amor(missatge)
	
	print(missatge)
	
	# Cooldown per no restar constantment
	await get_tree().create_timer(TEMPS_ENTRE_PENALITZACIONS).timeout
	pot_penalitzar = true
