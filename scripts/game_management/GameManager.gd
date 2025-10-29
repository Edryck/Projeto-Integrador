# GameManager.gd
extends Node

# Singleton do GameManager
static var instance: GameManager

# Dados do jogador atual
var jogador_atual: Dictionary = {
	"nome": "",
	"pontuacao": 0,
	"fases_completadas": [],
	"desafios_completados": []
}

# Lista de todos os jogadores
var todos_jogadores: Dictionary = {}

# Dados da sessão atual
var fase_atual: String = ""

func _ready():
	# Configurar singleton
	if instance == null:
		instance = self
		process_mode = Node.PROCESS_MODE_ALWAYS
<<<<<<< HEAD
		# Garantir que o diretório de saves existe
		var dir = DirAccess.open("res://data/")
		if not dir.dir_exists("player_saves"):
			dir.make_dir("player_saves")
=======
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
		carregar_todos_jogadores()
	else:
		queue_free()
	
	print("GAME MANAGER - Inicializado")

# Gerenciamento de jogadores
func criar_jogador(nome: String) -> bool:
	if todos_jogadores.has(nome):
		print("Jogador já existe: ", nome)
		return false
	
	var novo_jogador = {
		"nome": nome,
		"pontuacao": 0,
		"fases_completadas": [],
		"desafios_completados": [],
		"data_criacao": Time.get_datetime_string_from_system()
	}
	
	todos_jogadores[nome] = novo_jogador
	salvar_todos_jogadores()
	print("Novo jogador criado: ", nome)
	return true

func carregar_jogador(nome: String) -> bool:
	if todos_jogadores.has(nome):
		jogador_atual = todos_jogadores[nome].duplicate(true)
		print("Jogador carregado: ", nome)
<<<<<<< HEAD
		print("   - Pontuação: ", jogador_atual["pontuacao"])
		print("   - Fases completadas: ", jogador_atual["fases_completadas"].size())
=======
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
		return true
	else:
		print("Jogador não encontrado: ", nome)
		return false

func obter_todos_jogadores() -> Array:
	var lista_jogadores = []
	for nome_jogador in todos_jogadores:
		lista_jogadores.append(todos_jogadores[nome_jogador])
	return lista_jogadores

func obter_pontuacao_jogador() -> int:
	return jogador_atual.get("pontuacao", 0)

func atualizar_pontuacao_jogador(pontos: int, dados_desafio: Dictionary = {}):
<<<<<<< HEAD
	# Atualizar pontuação no jogador atual
	jogador_atual["pontuacao"] += pontos
	
	# IMPORTANTE: Sincronizar com o dicionário de todos os jogadores
	if jogador_atual.has("nome") and todos_jogadores.has(jogador_atual["nome"]):
		todos_jogadores[jogador_atual["nome"]] = jogador_atual.duplicate(true)
	
=======
	jogador_atual["pontuacao"] += pontos
	
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	# Registrar desafio completado se for bem-sucedido
	if dados_desafio.get("sucesso", false):
		var desafio_id = dados_desafio.get("id", "")
		if desafio_id and not jogador_atual["desafios_completados"].has(desafio_id):
			jogador_atual["desafios_completados"].append(desafio_id)
<<<<<<< HEAD
			# Sincronizar novamente
			if jogador_atual.has("nome") and todos_jogadores.has(jogador_atual["nome"]):
				todos_jogadores[jogador_atual["nome"]] = jogador_atual.duplicate(true)
=======
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	
	salvar_todos_jogadores()
	print("Pontuação atualizada: +", pontos, " pontos (Total: ", jogador_atual["pontuacao"], ")")

# Sistema de save/load
func salvar_todos_jogadores():
<<<<<<< HEAD
	# Usar JSON para melhor compatibilidade e debugging
	var save_data = {
		"todos_jogadores": todos_jogadores,
		"ultimo_jogador": jogador_atual.get("nome", ""),
		"versao": "1.0"
	}
	
	var arquivo = FileAccess.open("res://data/player_saves/jogadores.json", FileAccess.WRITE)
	if arquivo:
		arquivo.store_string(JSON.stringify(save_data, "\t"))
		arquivo.close()
		print("Jogadores salvos com sucesso! (", todos_jogadores.size(), " jogadores)")
	else:
		printerr("Erro ao salvar jogadores! Código: ", FileAccess.get_open_error())

func carregar_todos_jogadores():
	var arquivo = FileAccess.open("res://data/player_saves/jogadores.json", FileAccess.READ)
	if arquivo:
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		
		var json = JSON.new()
		var erro = json.parse(conteudo)
		
		if erro == OK:
			var save_data = json.get_data()
			todos_jogadores = save_data.get("todos_jogadores", {})
			
			# Tentar carregar último jogador usado
			var ultimo_jogador = save_data.get("ultimo_jogador", "")
			if ultimo_jogador and todos_jogadores.has(ultimo_jogador):
				carregar_jogador(ultimo_jogador)
			
			print("Jogadores carregados: ", todos_jogadores.size())
		else:
			printerr("Erro ao parsear JSON de save: ", json.get_error_message())
			todos_jogadores = {}
=======
	var save_data = {
		"todos_jogadores": todos_jogadores,
		"ultimo_jogador": jogador_atual.get("nome", "")
	}
	
	var arquivo = FileAccess.open("user://jogadores.dat", FileAccess.WRITE)
	if arquivo:
		arquivo.store_var(save_data)
		print("Jogadores salvos com sucesso!")
	else:
		printerr("Erro ao salvar jogadores!")

func carregar_todos_jogadores():
	var arquivo = FileAccess.open("user://jogadores.dat", FileAccess.READ)
	if arquivo:
		var save_data = arquivo.get_var()
		todos_jogadores = save_data.get("todos_jogadores", {})
		
		# Tentar carregar último jogador usado
		var ultimo_jogador = save_data.get("ultimo_jogador", "")
		if ultimo_jogador and todos_jogadores.has(ultimo_jogador):
			carregar_jogador(ultimo_jogador)
		
		print("Jogadores carregados: ", todos_jogadores.size())
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	else:
		print("Nenhum save encontrado, iniciando com dados vazios")
		todos_jogadores = {}

# Gerenciamento de fases
func completar_fase(fase_id: String):
	if not jogador_atual["fases_completadas"].has(fase_id):
		jogador_atual["fases_completadas"].append(fase_id)
		jogador_atual["pontuacao"] += 100  # Bônus por completar fase
<<<<<<< HEAD
		
		# Sincronizar com todos os jogadores
		if jogador_atual.has("nome") and todos_jogadores.has(jogador_atual["nome"]):
			todos_jogadores[jogador_atual["nome"]] = jogador_atual.duplicate(true)
		
=======
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
		salvar_todos_jogadores()
		print("Fase completada: ", fase_id, " +100 pontos")

func is_fase_completada(fase_id: String) -> bool:
	return jogador_atual["fases_completadas"].has(fase_id)

# Utilitários
func resetar_jogo():
	jogador_atual = {
		"nome": "",
		"pontuacao": 0,
		"fases_completadas": [],
		"desafios_completados": []
	}
	todos_jogadores = {}
	
	# Deletar arquivo de save
<<<<<<< HEAD
	var arquivo_path = "res://data/player_saves/jogadores.json"
	if FileAccess.file_exists(arquivo_path):
		DirAccess.remove_absolute(arquivo_path)
=======
	var dir = DirAccess.open("user://")
	if dir.file_exists("user://jogadores.dat"):
		dir.remove("user://jogadores.dat")
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	
	print("Progresso do jogo resetado")

func get_jogador_atual_nome() -> String:
	return jogador_atual.get("nome", "Nenhum jogador")
