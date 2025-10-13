# Player.gd
class_name Player
extends Resource

const SAVE_PATH = "res://data/player_saves/"
const FILE_PREFIX = "aluno_"
const FILE_EXTENSION = ".json"

# Propriedades do jogador 
@export var id: String = ""
@export var student_name: String = ""
@export var total_score: int = 0
@export var progress: Dictionary = {}

# Construtor
func _init(s_name: String = ""):
	if not s_name.is_empty():
		student_name = s_name
		id = str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)

# Método para salvar os dados deste jogador em um arquivo .json
func save() -> bool:
	var file_path = SAVE_PATH + FILE_PREFIX + student_name.to_lower().strip_edges() + FILE_EXTENSION
	
	var data_dict = {
		"id": id,
		"name": student_name,
		"total_score": total_score,
		"progress": progress
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data_dict, "\t")
		file.store_string(json_string)
		print("Player profile saved: ", student_name)
		return true
	else:
		printerr("Failed to save player profile: ", student_name)
		return false

# Função estática para carregar um jogador de um arquivo .json
static func load(student_name: String) -> Player:
	var file_path = SAVE_PATH + FILE_PREFIX + student_name.to_lower().strip_edges() + FILE_EXTENSION
	if not FileAccess.file_exists(file_path):
		return null
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json_data = JSON.parse_string(content)
	
	if json_data is Dictionary:
		var loaded_player = Player.new()
		loaded_player.id = json_data.get("id", "")
		loaded_player.student_name = json_data.get("name", "")
		loaded_player.total_score = json_data.get("total_score", 0)
		loaded_player.progress = json_data.get("progress", {})
		print("Player profile loaded: ", student_name)
		return loaded_player
	
	return null

# Função estática que verifica se um perfil existe
static func profile_exists(student_name: String) -> bool:
	var file_path = SAVE_PATH + FILE_PREFIX + student_name.to_lower().strip_edges() + FILE_EXTENSION
	return FileAccess.file_exists(file_path)
