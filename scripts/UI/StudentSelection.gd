# StudentSelection.gd
extends Control

# Referências aos widgets da UI
var container_jogadores: VBoxContainer
var entrada_novo: LineEdit
var botao_criar: Button
var label_feedback: Label

func _ready():
	print("=== SELEÇÃO DE JOGADOR ===")
	# Inicializa widgets só uma vez
	container_jogadores = find_child("StudentListContainer", true, false)
	entrada_novo = find_child("NewStudentInput", true, false)
	botao_criar = find_child("CreateStudentButton", true, false)
	label_feedback = find_child("FeedbackLabel", true, false)

	# Conecta evento do botão criar estudante de forma segura
	if botao_criar and not botao_criar.pressed.is_connected(_on_botao_criar_pressionado):
		botao_criar.pressed.connect(_on_botao_criar_pressionado)

	criar_botao_voltar()
	carregar_lista_jogadores()

# Cria botão para retornar ao menu principal
func criar_botao_voltar():
	# Cria o botão e ajusta a posição dele
	var botao_voltar = Button.new()
	botao_voltar.text = " < Menu Principal"
	botao_voltar.custom_minimum_size = Vector2(75, 40)
	botao_voltar.position = Vector2(10, 10)
	
	# Aplica a fonte no texto
	var fonte = preload("res://assets/fonts/Pixel Digivolve.otf")
	if fonte:
		botao_voltar.add_theme_font_override("font", fonte)
	
	botao_voltar.pressed.connect(_on_botao_voltar_pressionado)
	add_child(botao_voltar)
	print("Botão voltar adicionado à StudentSelection")

# Volta ao menu principal
func _on_botao_voltar_pressionado():
	print("Voltando para menu principal...")
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")

# Lista todos os jogadores cadastrados
func carregar_lista_jogadores():
	if not container_jogadores:
		printerr("Container de jogadores não encontrado!")
		if label_feedback: label_feedback.text = "Erro interno: container não encontrado."
		return

	# Limpa a lista visual de botões antigos
	for filho in container_jogadores.get_children():
		filho.queue_free()

	# Corrigido: usa método que retorna array/players para listar
	var jogadores = GameManager.obter_todos_jogadores()
	# Garante robustez se algo for nulo ou um tipo errado
	if not jogadores or jogadores.size() == 0:
		if label_feedback:
			label_feedback.text = "Nenhum jogador cadastrado. Crie um novo!"
	else:
		if label_feedback:
			label_feedback.text = "Selecione seu jogador:"
		for jogador in jogadores:
			var nome = jogador.nome if jogador.has("nome") else str(jogador)
			var botao = Button.new()
			botao.text = nome
			botao.custom_minimum_size = Vector2(250, 50)
			
			# Aplica o theme
			var tema = preload("res://assets/UI/MenuInicialTema.tres")
			if tema:
				botao.theme = tema
			
			# Aplica a fonte no texto
			var fonte = preload("res://assets/fonts/Pixel Digivolve.otf")
			if fonte:
				botao.add_theme_font_override("font", fonte)
			
			# Conecta o botão
			botao.pressed.connect(selecionar_jogador.bind(nome))
			container_jogadores.add_child(botao)

# Seleciona o jogador e avança, exibindo erro se falhar
func selecionar_jogador(nome: String):
	print("Selecionando jogador: ", nome)
	if GameManager.carregar_jogador(nome):
		print("Indo para o mapa...")
		get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
	else:
		printerr("Falha ao carregar jogador")
		if label_feedback: label_feedback.text = "Erro ao carregar jogador: " + nome

# Criação de novo jogador com feedback
func _on_botao_criar_pressionado():
	var nome = entrada_novo.text.strip_edges()
	if nome.is_empty():
		if label_feedback: 
			label_feedback.text = "Digite um nome!"
		return
	if GameManager.criar_jogador(nome):
		if label_feedback: label_feedback.text = "Jogador criado: " + nome
		entrada_novo.text = ""
		carregar_lista_jogadores()
	else:
		if label_feedback: 
			label_feedback.text = "Nome já existe!"
