# ChallengeBase.gd
extends Control

# Sinais que todos os desafios vão emitir
signal desafio_concluido(sucesso: bool, pontuacao: int, dados: Dictionary)
# Novo sinal para pedir a RewardScreen externamente
signal requisitar_reward_screen(sucesso: bool, pontuacao: int, dados: Dictionary)
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
	# Conectar sinal de recompensa ao SceneManager automaticamente
	if not requisitar_reward_screen.is_connected(_on_requisitar_reward_screen):
		requisitar_reward_screen.connect(_on_requisitar_reward_screen)
	var dados = SceneManager.obter_dados_desafio_atual()
	if not dados.is_empty():
		print("ChallengeBase: Dados disponíveis no SceneManager, iniciando...")
		iniciar_desafio(dados)
	else:
		printerr("ChallengeBase: Nenhum dado de desafio recebido do SceneManager!")

# Handler para quando o desafio pedir RewardScreen (apenas quando fase completa)
func _on_requisitar_reward_screen(sucesso: bool, pontuacao: int, dados: Dictionary):
	print("ChallengeBase: Recebido pedido de RewardScreen (fase completa)")
	SceneManager.exibir_reward_screen(sucesso, pontuacao, dados)

# Configura a interface base do desafio
func configurar_ui_base():
	print("Configurando UI base...")
	if menu_button:
		if not menu_button.pressed.is_connected(_on_menu_pressionado):
			menu_button.pressed.connect(_on_menu_pressionado)
		print("Botão menu conectado")

# Inicia o desafio com os dados fornecidos
func iniciar_desafio(dados: Dictionary):
	print("ChallengeBase.iniciar_desafio()")
	dados_desafio = dados
	pontuacao = 0
	tempo_inicio = Time.get_ticks_msec()
	# Preenche títulos e instruções
	if mission_title_label and dados.has("title"):
		mission_title_label.text = dados["title"]
		print("   - Título definido: ", dados["title"])
	if instructions_label and dados.has("instructions"):
		instructions_label.text = dados["instructions"]
		print("   - Instruções definidas")
	
	_setup_desafio_especifico(dados)

# Cada script de desafio (Quiz, DragDrop) sobrescreve esta função.
func _setup_desafio_especifico(dados: Dictionary):
	print("ChallengeBase: _setup_desafio_especifico (Implementação base vazia)")
	# Deixe vazio. Os filhos vão implementar.
	pass

# Finaliza o desafio, emitindo sinais para controladores externos (UI, reward...)
func finalizar_desafio(sucesso: bool, dados_extras: Dictionary = {}):
	var tempo_gasto = (Time.get_ticks_msec() - tempo_inicio) / 1000.0
	print("DESAFIO CONCLUÍDO:")
	print("   - Sucesso: ", sucesso)
	print("   - Pontuação: ", pontuacao)
	print("   - Tempo: ", tempo_gasto, "s")
	print("   - Dados: ", dados_extras)
	dados_extras["sucesso"] = sucesso
	dados_extras["id"] = dados_desafio.get("id", "")
	
	# Atualizar pontuação do jogador ANTES de verificar se deve mostrar reward
	if pontuacao > 0:
		GameManager.atualizar_pontuacao_jogador(pontuacao, dados_extras)
	
	# Sinal padrão de conclusão (para persistência/progresso)
	desafio_concluido.emit(sucesso, pontuacao, dados_extras)
	
	# Verificar se é o último desafio da fase - só então mostrar RewardScreen
	# SceneManager vai decidir se deve mostrar reward ou avançar para próximo desafio
	verificar_e_mostrar_reward_se_fase_completa(sucesso, pontuacao, dados_extras)

# Verifica se deve mostrar RewardScreen (apenas quando fase completa)
func verificar_e_mostrar_reward_se_fase_completa(sucesso: bool, pontuacao: int, dados: Dictionary):
	# Verificar se após completar este desafio ainda há mais
	# A lógica: se estamos no índice N e há N+1 desafios, ainda tem mais
	# SceneManager tem acesso ao índice e array de desafios
	var desafio_atual_idx = SceneManager.desafio_atual_index
	var total_desafios = SceneManager.desafios_da_fase.size()
	var ainda_tem_mais = (desafio_atual_idx + 1) < total_desafios
	
	print("Verificando se deve mostrar reward:")
	print("   - Desafio atual: ", desafio_atual_idx + 1, " de ", total_desafios)
	print("   - Ainda tem mais: ", ainda_tem_mais)
	
	if ainda_tem_mais:
		print("Ainda há mais desafios na fase - avançando sem mostrar reward")
		# Avançar o índice para o próximo desafio
		SceneManager.avancar_para_proximo_desafio()
		await get_tree().create_timer(0.3).timeout
		get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
	else:
		# Fase completa, agora mostra RewardScreen
		print("Fase completa! Mostrando RewardScreen...")
		requisitar_reward_screen.emit(sucesso, pontuacao, dados)

# Deixe apenas atualizações visuais/menus aqui para o desafio
func atualizar_progresso(atual: int, total: int):
	if progress_bar:
		var percentual = float(atual) / total * 100
		progress_bar.value = percentual

func _on_menu_pressionado():
	print("Botão Menu pressionado - Abrindo pause")
	abrir_menu_pause()

# Exemplo de menu de pausa (pode ser externalizado também)
func abrir_menu_pause():
	var cena_pause = load("res://scenes/UI/PauseMenu.tscn")
	if cena_pause:
		var menu_pause = cena_pause.instantiate()
		get_tree().root.add_child(menu_pause)
		if menu_pause.has_signal("retomado"):
			menu_pause.retomado.connect(_on_pause_retomado)
		if menu_pause.has_signal("reiniciar_desafio"):
			menu_pause.reiniciar_desafio.connect(_on_pause_reiniciar)
		if menu_pause.has_signal("sair_para_mapa"):
			menu_pause.sair_para_mapa.connect(_on_pause_sair)
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
