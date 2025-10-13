# GameManager.gd
extends Node

# Pré-carrega a classe de jogador
const PlayerData = preload("res://scripts/player/Player.gd")

# Variáveis para armazenar o estado do jogo e do aluno atual
var current_player: PlayerData
var game_progression_data: Dictionary = {} # Progresso do jogo

# Variáveis para o menu de pause
const PauseMenuScene = preload("res://scenes/UI/PauseMenu.tscn")
var selected_phase_id: String = ""
var current_challenge_container: Node
var ChallengeDataManager: Node
var current_challenge_node: Control # Para manter referência ao desafio atual

# Caminho onde os arquivos do save dos alunos serãp armazenados
const SAVE_PATH = "user://saves/"
const STUDENT_DATA_FILE_PREFIX = "aluno_"
const FILE_EXTENSION = ".json"

# Signal
# São emitidos quando os dados do aluno ativo são carregados/atualizados
signal student_data_loaded(player_data)
signal student_data_updated(player_data)
# Emitido quando uma fase é completada
signal phase_completed(phase_id, score, is_success)

func _ready():
	# Conferir se a pasta de saves existe
	var dir = DirAccess.open(SAVE_PATH)
	if not dir:
		DirAccess.make_dir_absolute(SAVE_PATH)
	print("GameManager initialized. Save path: ", ProjectSettings.globalize_path(SAVE_PATH))
	ChallengeDataManager = get_node("/root/ChallengeDataManager")
	if not ChallengeDataManager:
		printerr("GameManager: ChallengeDataManager não encontrado! O jogo não poderá carregar as fases.")

# Métodos de Gerenciamento do Aluno

# Carrega os dados de um aluno específico pelo nome
func load_student_profile(student_name: String) -> bool:
	current_player = PlayerData.load(student_name)
	if current_player:
		student_data_loaded.emit(current_player)
		return true
	return false

# Salva os dados do aluno ativo
func save_current_student_profile() -> bool:
	if current_player.is_empty():
		printerr("No student data to save.")
		return false
	
	# Atualiza os dados de progresso dentro dos dados do aluno
	current_player["progress"] = game_progression_data
	
	var student_name = current_player.get("name").to_lower().strip_edges()
	var file_path = SAVE_PATH + STUDENT_DATA_FILE_PREFIX + student_name + FILE_EXTENSION
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		var json_string = JSON.stringify(current_player, "\t")
		file.store_string(json_string)
		file.close()
		print("Student profile saved: ", student_name)
		student_data_updated.emit(current_player)
		return true
	else:
		printerr("Failed to save student profile: ", student_name)
		return false

# Cria um novo perfil de aluno
func create_new_student_profile(student_name: String) -> bool:
	if PlayerData.profile_exists(student_name):
		printerr("Student profile already exists: ", student_name)
		return false
	
	current_player = PlayerData.new(student_name)
	var success = current_player.save()
	if success:
		student_data_loaded.emit(current_player)
	return success

# Métodos de Gerenciamento de Progresso

# Atualiza o progresso de uma fase específica
func update_phase_progress(phase_id: String, score: int, is_success: bool, attempts: int, time_spent: float, additional_data: Dictionary = {}) -> void:
	if not current_player:
		printerr("No student logged in.")
		return

	var phase_entry = current_player.progress.get(phase_id, {})
	phase_entry["score"] = score
	phase_entry["is_success"] = is_success
	# ... (outras atribuições) ...
	
	current_player.progress[phase_id] = phase_entry
	current_player.total_score += score
	
	current_player.save() # Salva todas as alterações no arquivo
	student_data_updated.emit(current_player)

# Verifica se uma fase foi completada por um aluno
func is_phase_completed(phase_id: String) -> bool:
	if not current_player: return false
	return current_player.progress.has(phase_id) and current_player.progress[phase_id].get("is_success", false)

# Retorna o progresso de uma fase específica
func get_phase_progress(phase_id: String) -> Dictionary:
	return game_progression_data.get(phase_id, {})

# Retorna todos os dados de progresso do aluno logado
func get_all_student_progress() -> Dictionary:
	return game_progression_data

# Métodos de Utilidade

# Função placeholder para gerar um ID único (melhorar para algo mais robusto)
func generate_unique_id() -> String:
	return str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)

# Função para obter dados de todos os alunos para o Dashboard do Professor
func get_all_students_for_dashboard() -> Array:
	var students_data_list: Array = []
	var dir = DirAccess.open(SAVE_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(FILE_EXTENSION) and file_name.begins_with(STUDENT_DATA_FILE_PREFIX):
				var _student_name_from_file = file_name.replace(STUDENT_DATA_FILE_PREFIX, "").replace(FILE_EXTENSION, "")
				var file_path = SAVE_PATH + file_name
				var file = FileAccess.open(file_path, FileAccess.READ)
				if file:
					var content = file.get_as_text()
					file.close()
					var json_data = JSON.parse_string(content)
					if json_data is Dictionary:
						students_data_list.append(json_data)
			file_name = dir.get_next()
		dir.list_dir_end()
	return students_data_list

# Funções para gerenciar as fases

var current_phase_id: String
var current_phase_challenges: Array
var challenge_index: int = 0

# Função para iniciar uma fase
func start_phase(phase_id: String, container_node: Node):
	# container_node é o nó da cena onde os desafios serão adicionados
	# Pega a lista de desafios para a fase
	current_challenge_container = container_node
	current_phase_id = phase_id
	current_phase_challenges = ChallengeDataManager.get_challenges_for_phase(phase_id)
	# Randomiza a ordem
	current_phase_challenges.shuffle()
	
	challenge_index = 0
	_play_next_challenge()

func _play_next_challenge():
	# Garante que o desafio anterior seja completamente removido.
	if is_instance_valid(current_challenge_node):
		current_challenge_node.queue_free()
		current_challenge_node = null # Limpa a referência
	
	# Verifica se a fase terminou.
	if challenge_index >= current_phase_challenges.size():
		print("Fase Concluída! Voltando para o mapa...")
		_on_exit_to_map_requested() # Retorna ao mapa
		return
	
	# Pega os dados do próximo desafio.
	var challenge_data = current_phase_challenges[challenge_index]
	var challenge_type = challenge_data.get("type", "")
	
	var scene_path = ""
	match challenge_type:
		"quiz": scene_path = "res://scenes/challenges/QuizChallenge.tscn"
		"relate": scene_path = "res://scenes/challenges/RelateChallenge.tscn"
		"dragdrop": scene_path = "res://scenes/challenges/DragDropChallenge.tscn"
	
	if scene_path.is_empty():
		challenge_index += 1
		_play_next_challenge() # Pula para o próximo
		return
	
	# Cria a cena
	var challenge_scene = load(scene_path).instantiate()
	current_challenge_node = challenge_scene
	current_challenge_container.add_child(current_challenge_node)
	
	# Conecta os sinais na nova instância.
	challenge_scene.challenge_finished.connect(_on_challenge_finished)
	challenge_scene.pause_requested.connect(_on_pause_requested)
	
	challenge_scene.setup_challenge(challenge_data)
	challenge_index += 1

func _on_challenge_finished(id, score, is_success, additional_data, container_node: Node):
	print(str("Desafio ", id, " finalizado!"))
	
	# Atualiza o progresso do aluno
	# O 'id' aqui pode ser o id da FASE, não do mini-desafio.
	# Precisará ajustar como o progresso é salvo (por fase ou por mini-desafio).
	# update_phase_progress(...)
	var challenge_node = current_challenge_node as ChallengeBase
	if challenge_node:
		update_phase_progress(
			current_phase_id,
			score,
			is_success,
			challenge_node._attempts,
			challenge_node._time_spent,
			additional_data
		)
	
	# Chama o próximo desafio
	_play_next_challenge()

# Funções do menu de pause
func set_current_phase_id(phase_id: String):
	selected_phase_id = phase_id

func _on_pause_requested():
	if get_tree().paused: return
	get_tree().paused = true
	var pause_menu = PauseMenuScene.instantiate()
	get_tree().root.add_child(pause_menu)
	pause_menu.restart_phase.connect(_on_pause_menu_restart_phase)
	pause_menu.quit_to_map.connect(_on_pause_menu_quit_to_map)

func _on_pause_menu_restart_phase():
	if is_instance_valid(current_challenge_node):
		current_challenge_node.queue_free()
	start_phase(selected_phase_id, current_challenge_container)

func _on_pause_menu_quit_to_map():
	_on_exit_to_map_requested()

func _on_exit_to_map_requested():
	print("Saindo do desafio e voltando para o mapa...")

	# Garante que o jogo está despausado antes de mudar de cena
	get_tree().paused = false

	# Limpa o desafio atual para não ficar rodando em segundo plano
	if is_instance_valid(current_challenge_node):
		current_challenge_node.queue_free()
		current_challenge_node = null

	# Zera a progressão da fase atual para não causar problemas depois
	if current_phase_challenges:
		current_phase_challenges.clear()
	challenge_index = 0

	# Volta para a cena do mapa
	get_tree().change_scene_to_file("res://scenes/menus/WorldMap.tscn")
