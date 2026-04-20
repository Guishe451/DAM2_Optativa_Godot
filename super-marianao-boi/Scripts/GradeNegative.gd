extends Area2D

# Desplegable a l'Inspector per escollir la nota negativa
@export_enum("D", "D-", "F") var grade: String = "D"

# Punts que es restaran segons la nota
const GRADE_POINTS = {
	"D":  -10,
	"D-": -15,
	"F":  -20
}

# Imatges de cada nota negativa
const GRADE_IMAGES = {
	"D":  preload("res://assets/Grades/D+.png"),
	"D-": preload("res://assets/Grades/D-.png"),
	"F":  preload("res://assets/Grades/F.png")
}

func _ready():
	# Assigna la imatge correcta segons la nota escollida
	$NotesNegatives.texture = GRADE_IMAGES[grade]
	
	# Evitem connectar el senyal dues vegades
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Jugador:
		# Comprovem que el jugador pot recollir notes
		if body.can_collect:
			var points = GRADE_POINTS.get(grade, 0)
			# Usem modificar_punts() — SENSE penalització
			# La penalització només la causa la pilota
			body.modificar_punts(points)
			queue_free()
