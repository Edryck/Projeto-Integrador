# PauseMenu.gd
extends CanvasLayer

signal retomado
signal reiniciar_desafio
signal sair_para_mapa

func _ready():
	print("Menu de Pause carregado")
	
	# Conectar botões
	var botao_retomar = find_child("ResumeButton", true, false)
	var botao_reiniciar = find_child("RestartButton", true, false)
	var botao_sair = find_child("QuitToMapButton", true, false)
	
	if botao_retomar:
		botao_retomar.pressed.connect(_on_retomar_pressionado)
	if botao_reiniciar:
		botao_reiniciar.pressed.connect(_on_reiniciar_pressionado)
	if botao_sair:
		botao_sair.pressed.connect(_on_sair_pressionado)

func _on_retomar_pressionado():
	print("Retomando jogo...")
	retomado.emit()
<<<<<<< HEAD
	get_tree().paused = false
=======
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	queue_free()

func _on_reiniciar_pressionado():
	print("Reiniciando desafio...")
<<<<<<< HEAD
	get_tree().paused = false
	
	# Limpar dados do desafio atual mas manter a fase
	var _fase_id = SceneManager.get_id_fase_temp()
	var _fase_dados = SceneManager.dados_fase_temp.duplicate(true)
	var _desafio_index = SceneManager.desafio_atual_index
	
	# Recarregar a cena atual
	var cena_atual = get_tree().current_scene.scene_file_path
	
	queue_free()
	
	# Aguardar um frame
	await get_tree().process_frame
	
	# Recarregar a cena
	get_tree().change_scene_to_file(cena_atual)

func _on_sair_pressionado():
	print("Saindo para o mapa...")
	get_tree().paused = false
	sair_para_mapa.emit()
	queue_free()
	
	# Aguardar um frame antes de mudar de cena
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
=======
	reiniciar_desafio.emit()
	queue_free()

func _on_sair_pressionado():
	print("Saindo para o mapa...")
	sair_para_mapa.emit()
	queue_free()
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13

func _input(event):
	# Fechar com ESC
	if event.is_action_pressed("ui_cancel"):
		_on_retomar_pressionado()
