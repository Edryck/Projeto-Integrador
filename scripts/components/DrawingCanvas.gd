# DrawingCanvas.gd
extends Control

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
