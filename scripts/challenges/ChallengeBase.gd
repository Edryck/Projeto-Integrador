# ChallengeBase.gd
extends Control

@export var challenge_id: String = "" # ID único desta instância de desafio (para carregar o JSON)
var mission_title_label: Label
var instructions_label: Label
var progress_bar: ProgressBar
var challenge_content_container: Control # Onde o conteúdo específico do dasafio vai
@onready var menu_button: Button = $ExternalMarginContainer/MenuButton

signal challenge_started(id)
signal challenge_finished(id, score, is_success, additional_data) # Para o GameManager
signal pause_requested() # Para o FlowManager

var _challenge_data: Dictionary = {} #Dados carregados do JSON
var _score: int = 0
var _attempts: int = 0
var _time_spent: float = 0.0
var _start_time: float = 0.0

func _ready():
	# Encontra os nós usando caminhos mais específicos
	mission_title_label = find_child("MissionTitleLabel", true, false)
	instructions_label = find_child("InstructionsLabel", true, false)
	progress_bar = find_child("ProgressBar", true, false)
	challenge_content_container = find_child("ChallengeContentContainer", true, false)
	
	# Tenta encontrar o MenuButton de forma mais robusta
	menu_button = find_child("MenuButton", true, false)
	if not menu_button:
		# Procura em caminhos alternativos
		menu_button = $VBoxContainer/MenuButton if has_node("VBoxContainer/MenuButton") else null
	
	if menu_button:
		print("SUCESSO: Nó 'MenuButton' encontrado em ", name)
		menu_button.pressed.connect(_on_menu_button_pressed)
	else:
		printerr("FALHA: MenuButton não encontrado")
		print_tree_pretty()

# Métodos Virtuais (Implementados pelas classes filhas)
# Carrega os dados específicos do desafio (do JSON)
func _load_challenge_data() -> Dictionary:
	printerr("ChallengeBase: _load_challenge_data() must be implemented by derived classes.")
	return {}

# Prepara a UI com base nos dados carregados
func _setup_ui_for_challenge(_data: Dictionary) -> void:
	printerr("ChallengeBase: _setup_ui_for_challenge() must be implemented by derived classes.")

# Inicia a lógica do desafio
func _start_challenge_logic() -> void:
	printerr("ChallengeBase: _start_challenge_logic() must be implemented by derived classes.")

# Processa uma resposta/interação do jogador
func _process_player_input(_input_data) -> void:
	printerr("ChallengeBase: _process_player_input() must be implemented by derived classes.")

#Métodos Comuns (Usados por todas as classes filhas)
#Chamado pra iniciar o desafio (do WorldMap)
func setup_challenge(data: Dictionary) -> void:
	_challenge_data = data
	_score = 0
	_attempts = 0
	_time_spent = 0.0
	
	if _challenge_data.is_empty():
		printerr("ChallengeBase: Recebeu dados vazios!")
		pause_requested.emit()
		return
	
	# Atualiza o challenge_id da classe com o ID vindo dos dados.
	challenge_id = _challenge_data.get("id", "unknown_id")
	
	mission_title_label.text = _challenge_data.get("title", "Desafio")
	instructions_label.text = _challenge_data.get("instructions", "Complete a missão.")
	
	# Chama o _load_challenge_data() que estava faltando
	_load_challenge_data()
	
	# A lógica principal não muda
	_setup_ui_for_challenge(_challenge_data) # Chama o setup específico da classe filha
	_start_time = Time.get_ticks_msec()
	challenge_started.emit(_challenge_data.get("id", "unknown_id")) # Pode pegar o id dos dados
	_start_challenge_logic() # Inicia a lógica específica da classe filha

# Chamado quando o desafio é concluído
func _on_challenge_completed(is_success: bool, final_score: int, additional_info: Dictionary = {}) -> void:
	_time_spent = (Time.get_ticks_msec() - _start_time) / 1000.0 # Tempo em segundos
	
	# Emitir signal para o GameManager para atualizar o progresso do aluno
	challenge_finished.emit(challenge_id, final_score, is_success, additional_info)
	
	# Após a emissão, o FlowManager muda para a tela de recompensa
	# Exemplo: FlowManager.goto_reward_screen(challenge_id, final_score, is_success)
	pause_requested.emit() # Temporário, até ter a tela de recompensa

# Atualiza a barra de progresso (a ser chamada pelas classes filhas)
func update_progress_bar(current: int, total: int) -> void:
	if progress_bar:
		progress_bar.value = float(current) / total * 100
		# Pode também atualizar um Label com "current/total"
		pass

func _on_menu_button_pressed() -> void:
	print("Menu button pressed from challenge.")
	pause_requested.emit() # pedir ao FlowManager para voltar ao mapa
	# Caso seja necessário adicionar a confirmação de saída, adicione
