# ChallengeBase.gd
extends Control

# Sinais que todos os desafios vão emitir
signal desafio_concluido(sucesso: bool, pontuacao: int, dados: Dictionary)
signal desafio_iniciado()

# Variáveis comuns a todos os desafios
var dados_desafio: Dictionary = {}
var pontuacao: int = 0
var tempo_inicio: float = 0.0

# Referências aos nós da UI
@onready var mission_title_label: Label = find_child("MissionTitleLabel", true, false)
@onready var instructions_label: Label = find_child("InstructionsLabel", true, false)
@onready var progress_bar: ProgressBar = find_child("ProgressBar", true, false)
@onready var challenge_content_container: Control = find_child("ChallengeContentContainer", true, false)
@onready var menu_button: Button = find_child("MenuButton", true, false)

func _ready():
	print("CHALLENGE BASE - Carregado")
	configurar_ui_base()

func configurar_ui_base():
	print("Configurando UI base...")
	
	if menu_button:
		if not menu_button.pressed.is_connected(_on_menu_pressionado):
			menu_button.pressed.connect(_on_menu_pressionado)
		print("Botão menu conectado")

func iniciar_desafio(dados: Dictionary):
	print("ChallengeBase.iniciar_desafio()")
	
	dados_desafio = dados
	pontuacao = 0
	tempo_inicio = Time.get_ticks_msec()
	
	# Configurar UI com os dados do desafio
	if mission_title_label and dados.has("title"):
		mission_title_label.text = dados["title"]
		print("   - Título definido: ", dados["title"])
	
	if instructions_label and dados.has("instructions"):
		instructions_label.text = dados["instructions"]
		print("   - Instruções definidas")
	
	desafio_iniciado.emit()
	print("Desafio base configurado")

func finalizar_desafio(sucesso: bool, dados_extras: Dictionary = {}):
	var tempo_gasto = (Time.get_ticks_msec() - tempo_inicio) / 1000.0
	
	print("DESAFIO CONCLUÍDO:")
	print("   - Sucesso: ", sucesso)
	print("   - Pontuação: ", pontuacao)
	print("   - Tempo: ", tempo_gasto, "s")
	print("   - Dados: ", dados_extras)
	
	# Adicionar sucesso aos dados extras
	dados_extras["sucesso"] = sucesso
	dados_extras["id"] = dados_desafio.get("id", "")
	
	# Emitir sinal
	desafio_concluido.emit(sucesso, pontuacao, dados_extras)
	
	# Mostrar recompensa
	mostrar_tela_recompensa(sucesso, pontuacao, dados_extras)

func mostrar_tela_recompensa(sucesso: bool, pontuacao_desafio: int, dados: Dictionary):
	print("Mostrando tela de recompensa...")
	
	# Atualizar pontuação do jogador ANTES de mostrar a tela
	if pontuacao_desafio > 0:
		GameManager.atualizar_pontuacao_jogador(pontuacao_desafio, dados)
	
	# Carregar e mostrar tela de recompensa
	var cena_recompensa = load("res://scenes/UI/RewardScreen.tscn")
	if cena_recompensa:
		var tela_recompensa = cena_recompensa.instantiate()
		get_tree().root.add_child(tela_recompensa)
		
		# Chamar função de mostrar resultado
		if tela_recompensa.has_method("mostrar_resultado"):
			tela_recompensa.mostrar_resultado(sucesso, pontuacao_desafio, dados)
		
		# Aguardar o fechamento da tela (simplificado e mais robusto)
		# Usar um timer para garantir que o usuário veja a tela
		await get_tree().create_timer(0.5).timeout
		
		# Aguardar até que a tela seja removida
		# O RewardScreen se remove quando o botão continuar é pressionado
		while is_instance_valid(tela_recompensa) and tela_recompensa.is_inside_tree():
			await get_tree().process_frame
		
		print("Tela de recompensa fechada")
		
		# Agora sim, continuar o fluxo
		_continuar_apos_recompensa()
	else:
		printerr("RewardScreen não encontrada!")
		_continuar_apos_recompensa()

func _continuar_apos_recompensa():
	print("Continuando após recompensa...")
	
	# Verificar se tem mais desafios
	if SceneManager.tem_mais_desafios():
		print("Avançando para próximo desafio...")
		SceneManager.avancar_para_proximo_desafio()
		
		# Pequeno delay antes de mudar de cena
		await get_tree().create_timer(0.3).timeout
		
		# Voltar para WorldMap que irá carregar o próximo desafio
		get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
	else:
		print("Fase completa! Registrando conclusão...")
		
		# Marcar fase como completada
		var fase_id = SceneManager.get_id_fase_temp()
		if fase_id:
			GameManager.completar_fase(fase_id)
		
		# Limpar dados do SceneManager
		SceneManager.limpar_dados()
		
		# Voltar para o mapa
		await get_tree().create_timer(0.3).timeout
		get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")

func atualizar_progresso(atual: int, total: int):
	if progress_bar:
		var percentual = float(atual) / total * 100
		progress_bar.value = percentual

func _on_menu_pressionado():
	print("Botão Menu pressionado - Abrindo pause")
	abrir_menu_pause()

func abrir_menu_pause():
	# Carregar menu de pause
	var cena_pause = load("res://scenes/UI/PauseMenu.tscn")
	if cena_pause:
		var menu_pause = cena_pause.instantiate()
		get_tree().root.add_child(menu_pause)
		
		# Conectar sinais do menu de pause usando Callable
		if menu_pause.has_signal("retomado"):
			menu_pause.retomado.connect(_on_pause_retomado)
		if menu_pause.has_signal("reiniciar_desafio"):
			menu_pause.reiniciar_desafio.connect(_on_pause_reiniciar)
		if menu_pause.has_signal("sair_para_mapa"):
			menu_pause.sair_para_mapa.connect(_on_pause_sair)
		
		# Pausar o jogo
		get_tree().paused = true
		print("Jogo pausado")
	else:
		printerr("Menu de pause não encontrado!")

func _on_pause_retomado():
	print("Retomando do pause...")
	get_tree().paused = false

func _on_pause_reiniciar():
	print("Reiniciando desafio do pause...")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_pause_sair():
	print("Saindo para mapa do pause...")
	get_tree().paused = false
	SceneManager.limpar_dados()
	get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
