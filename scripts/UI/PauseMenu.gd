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
	get_tree().paused = false
	queue_free()

func _on_reiniciar_pressionado():
	print("Reiniciando desafio...")
	get_tree().paused = false
	
	# Limpar dados do desafio atual mas manter a fase
	var fase_id = SceneManager.get_id_fase_temp()
	var cena_atual = get_tree().current_scene.scene_file_path
	
	# Remover menu de pause
	queue_free()
	
	# Aguardar um frame para garantir que o menu foi removido
	await get_tree().process_frame
	
	# Preparar novamente o desafio atual (resetar dados temporários)
	var proximo_desafio = SceneManager.obter_proximo_desafio()
	if not proximo_desafio.is_empty():
		# Recarregar a cena do desafio
		get_tree().change_scene_to_file(cena_atual)
	else:
		# Se não tem desafio, voltar para o mapa
		printerr("Erro: Não há desafio para reiniciar!")
		get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")

func _on_sair_pressionado():
	print("Saindo para o mapa...")
	get_tree().paused = false
	sair_para_mapa.emit()
	queue_free()
	
	# Aguardar um frame antes de mudar de cena
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")

func _input(event):
	# Fechar com ESC
	if event.is_action_pressed("ui_cancel"):
		_on_retomar_pressionado()
