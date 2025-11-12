# GameManager.gd
extends Node

# Singleton do GameManager
static var instance = null

# Dados atuais do jogador, mantidos sempre em memória enquanto a sessão durar
var jogador_atual: Dictionary = {
	"nome": "",
	"pontuacao": 0,
	"fases_completadas": [],
	"desafios_completados": []
}

# Registro de todos os jogadores criados (persistido em arquivo)
var todos_jogadores: Dictionary = {}

# Fase atual em andamento
var fase_atual: String = ""

func _ready():
	# inicializa singleton e garante pasta de saves
	if instance == null:
		instance = self
		process_mode = Node.PROCESS_MODE_ALWAYS

		# Cria diretório se não existir
		var dir = DirAccess.open("res://data/")
		if not dir.dir_exists("player_saves"):
			dir.make_dir("player_saves")
		carregar_todos_jogadores()
	else:
		queue_free()  # Evita múltiplos GameManagers
	print("GAME MANAGER - Inicializado")

# Cria um novo jogador
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

# Carrega um jogador já cadastrado
func carregar_jogador(nome: String) -> bool:
	if todos_jogadores.has(nome):
		jogador_atual = todos_jogadores[nome].duplicate(true)
		print("Jogador carregado: ", nome)
		print("   - Pontuação: ", jogador_atual["pontuacao"])
		print("   - Fases completadas: ", jogador_atual["fases_completadas"].size())
		return true
	else:
		print("Jogador não encontrado: ", nome)
		return false

# Atualiza a pontuação do jogador e salva imediatamente
func atualizar_pontuacao_jogador(pontos: int, dados_desafio: Dictionary = {}):
	jogador_atual["pontuacao"] += pontos
	# Atualiza a pontuação também no dicionário de todos os jogadores
	if jogador_atual.has("nome") and todos_jogadores.has(jogador_atual["nome"]):
		todos_jogadores[jogador_atual["nome"]] = jogador_atual.duplicate(true)
	# Se o desafio foi concluído com sucesso, salva o progresso
	if dados_desafio.get("sucesso", false):
		var desafio_id = dados_desafio.get("id", "")
		if desafio_id and not jogador_atual["desafios_completados"].has(desafio_id):
			jogador_atual["desafios_completados"].append(desafio_id)
			# Sincroniza novamente
			if jogador_atual.has("nome") and todos_jogadores.has(jogador_atual["nome"]):
				todos_jogadores[jogador_atual["nome"]] = jogador_atual.duplicate(true)
	salvar_todos_jogadores()
	print("Pontuação atualizada: +", pontos, " pontos (Total: ", jogador_atual["pontuacao"], ")")

# Persiste todos os jogadores em arquivo json
# Se falhar, sugere via comentário: mostrar popup visual ao usuário explicando o erro
func salvar_todos_jogadores():
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
		# Sugestão: usar Popup para exibir mensagem ao usuário
		# Exemplo/comment: FeedbackLabel.text = 'Erro ao salvar dados. Tente novamente.'

# Carrega todos os jogadores do arquivo json
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
	else:
		print("Nenhum save encontrado, iniciando com dados vazios")
		todos_jogadores = {}

# Gerenciamento de fases
func completar_fase(fase_id: String):
	if not jogador_atual["fases_completadas"].has(fase_id):
		jogador_atual["fases_completadas"].append(fase_id)
		jogador_atual["pontuacao"] += 100  # Bônus por completar fase
		
		# Sincronizar com todos os jogadores
		if jogador_atual.has("nome") and todos_jogadores.has(jogador_atual["nome"]):
			todos_jogadores[jogador_atual["nome"]] = jogador_atual.duplicate(true)
		
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
	var arquivo_path = "res://data/player_saves/jogadores.json"
	if FileAccess.file_exists(arquivo_path):
		DirAccess.remove_absolute(arquivo_path)
	
	print("Progresso do jogo resetado")

func get_jogador_atual_nome() -> String:
	return jogador_atual.get("nome", "Nenhum jogador")

# Retorna um array com todos os jogadores cadastrados, ou array vazio caso nenhum.
func obter_todos_jogadores() -> Array:
	var lista_jogadores = []
	for nome_jogador in todos_jogadores.keys():
		lista_jogadores.append(todos_jogadores[nome_jogador])
	return lista_jogadores

# Retorna a pontuação do jogador logado, ou 0 se não houver ninguém logado
func obter_pontuacao_jogador() -> int:
	if jogador_atual.has("pontuacao"):
		return int(jogador_atual["pontuacao"])
	return 0
