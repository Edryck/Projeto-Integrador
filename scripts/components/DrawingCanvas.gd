# DrawingCanvas.gd
extends Control

<<<<<<< HEAD
# Referência para o RelateChallenge pai
var relate_challenge: Node = null

func _ready():
	# Buscar automaticamente o RelateChallenge pai
	var pai = get_parent()
	while pai != null:
		if pai.get_script() and pai.get_script().get_path().contains("RelateChallenge"):
			relate_challenge = pai
			print("DrawingCanvas conectado ao RelateChallenge automaticamente")
			break
		pai = pai.get_parent()
	
	# Configurar para receber eventos de mouse
	mouse_filter = Control.MOUSE_FILTER_PASS

func set_relate_challenge(challenge: Node):
	relate_challenge = challenge
	print("DrawingCanvas conectado ao RelateChallenge manualmente")

func _draw():
	# Chamar o método de desenho do RelateChallenge se existir
	if relate_challenge and relate_challenge.has_method("_desenhar_linhas"):
		relate_challenge._desenhar_linhas()
=======
# Referência para o RelateChallenge
var relate_challenge: Node = null

func set_relate_challenge(challenge: Node):
	relate_challenge = challenge
	print("DrawingCanvas conectado ao RelateChallenge")

func _draw():
	if relate_challenge and relate_challenge.has_method("_on_area_desenho_draw"):
		relate_challenge._on_area_desenho_draw()

func _input(event):
	# Repassar eventos de input para o RelateChallenge
	if relate_challenge and relate_challenge.has_method("_on_area_desenho_input"):
		relate_challenge._on_area_desenho_input(event)
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
