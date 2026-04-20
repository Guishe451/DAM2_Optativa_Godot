extends Area2D

# Desplegable a l'Inspector per escollir la nota positiva
@export_enum("A+", "A", "A-") var grade: String = "A+"

# Punts que s'afegiran segons la nota
const GRADE_POINTS = {
	"A+": 20,
	"A":  15,
	"A-": 10
}

# Imatges de cada nota positiva
const GRADE_IMAGES = {
	"A+": preload("res://assets/Grades/A+.png"),
	"A":  preload("res://assets/Grades/A.png"),
	"A-": preload("res://assets/Grades/A-.png")
}

func _ready():
	# Assigna la imatge correcta segons la nota escollida
	$NotesPositives.texture = GRADE_IMAGES[grade]
	
	# Evitem connectar el senyal dues vegades
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Jugador:
		# Comprovem que el jugador pot recollir notes
		if body.can_collect:
			var points = GRADE_POINTS.get(grade, 0)
			# Usem guanyar_punts() — amb possible penalització si fos negatiu
			body.guanyar_punts(points)
			queue_free()
