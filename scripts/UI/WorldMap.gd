# WorldMap.gd
extends Control

var temas = []
var tema_atual = 0

func _ready():
	print("=== MAPA MUNDIAL ===")
	configurar_interface()
	carregar_temas()
	
<<<<<<< HEAD
	# Adicionar botão de voltar programaticamente
	criar_botao_voltar()
	
	# Verificar se há uma fase em andamento
	if SceneManager.tem_mais_desafios():
		print("Retomando fase em andamento...")
		# Aguardar um frame para garantir que tudo está carregado
		await get_tree().process_frame
		iniciar_proximo_desafio()

func criar_botao_voltar():
	# Criar botão no canto superior esquerdo
	var botao_voltar = Button.new()
	botao_voltar.text = " < Voltar"
	botao_voltar.custom_minimum_size = Vector2(75, 40)
	botao_voltar.position = Vector2(10, 80)  # Abaixo do HUD do jogador
	botao_voltar.pressed.connect(_on_botao_voltar_pressionado)
	add_child(botao_voltar)
	print("Botão voltar adicionado ao WorldMap")

func _on_botao_voltar_pressionado():
	print("Voltando para seleção de jogador...")
	SceneManager.limpar_dados()
	get_tree().change_scene_to_file("res://scenes/UI/StudentSelection.tscn")

=======
	# Verificar se há uma fase em andamento
	if SceneManager.tem_mais_desafios():
		print("Retomando fase em andamento...")
		iniciar_proximo_desafio()

>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
func configurar_interface():
	# Atualizar info do jogador
	var label_nome = find_child("StudentNameLabel", true, false)
	var label_pontuacao = find_child("ScoreLabel", true, false)
	
	if GameManager.jogador_atual:
		label_nome.text = "Jogador: " + GameManager.jogador_atual.nome
		label_pontuacao.text = "Pontuação: " + str(GameManager.obter_pontuacao_jogador())
		print("Pontuação no mapa: ", GameManager.obter_pontuacao_jogador())

func carregar_temas():
	var container_temas = find_child("ThemeViewer", true, false)
	
	if not container_temas:
		printerr("Container de temas não encontrado!")
		return
	
<<<<<<< HEAD
	# Coletar todos os temas (Theme1, Theme2, Theme3)
	temas.clear()
	for filho in container_temas.get_children():
		if filho.name.begins_with("Theme"):
			temas.append(filho)
=======
	# Coletar todos os temas
	temas.clear()
	for tema in container_temas.get_children():
		temas.append(tema)
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	
	print("Temas carregados: ", temas.size())
	mostrar_tema_atual()

func mostrar_tema_atual():
	# Esconder todos os temas
	for i in range(temas.size()):
		temas[i].visible = (i == tema_atual)
	
	# Atualizar título
	var label_titulo = find_child("ThemeTitleLabel", true, false)
	if label_titulo and tema_atual < temas.size():
<<<<<<< HEAD
		label_titulo.text = temas[tema_atual].name.replace("Theme", "Tema ").replace("_", " ")

func _on_previous_theme_pressed():
=======
		label_titulo.text = temas[tema_atual].name.replace("Theme_", "").replace("_", " ")

func _on_botao_proximo_tema():
	tema_atual = (tema_atual + 1) % temas.size()
	mostrar_tema_atual()
	print("Próximo tema: ", tema_atual)

func _on_botao_tema_anterior():
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	tema_atual = tema_atual - 1
	if tema_atual < 0:
		tema_atual = temas.size() - 1
	mostrar_tema_atual()
	print("Tema anterior: ", tema_atual)

<<<<<<< HEAD
func _on_next_theme_pressed():
	tema_atual = (tema_atual + 1) % temas.size()
	mostrar_tema_atual()
	print("Próximo tema: ", tema_atual)

=======
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
func _on_botao_fase_pressionado():
	var botao = get_viewport().gui_get_focus_owner()
	
	if botao and botao is Button:
		var fase_id = botao.name
		print("Iniciando fase: ", fase_id)
		
		GameManager.fase_atual = fase_id
		iniciar_fase(fase_id)

func iniciar_fase(fase_id: String):
	print("Iniciando fase: ", fase_id)
	
	var dados_fase = carregar_dados_fase()
	
	if not dados_fase.has(fase_id):
		printerr("Fase não encontrada: ", fase_id)
		return
	
	var fase_data = dados_fase[fase_id]
	
	if fase_data["challenges"].is_empty():
		printerr("Nenhum desafio na fase: ", fase_id)
		return
	
	print("Fase carregada: ", fase_data["title"])
	print("   - Total desafios: ", fase_data["challenges"].size())
	
<<<<<<< HEAD
	# Preparar a fase no SceneManager
=======
	# WorldMap prepara os dados e passa para SceneManager
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	var dados_preparados = {
		"fase_data": fase_data,
		"challenges": fase_data["challenges"],
		"title": fase_data["title"]
	}
	
	SceneManager.preparar_fase(dados_preparados, fase_id)
	
	# Iniciar o primeiro desafio
	iniciar_proximo_desafio()

func iniciar_proximo_desafio():
	print("Iniciando próximo desafio...")
	
	var proximo_desafio = SceneManager.obter_proximo_desafio()
	if proximo_desafio.is_empty():
		print("FASE COMPLETA - Todos os desafios concluídos!")
		SceneManager.limpar_dados()
		return
	
	var tipo_desafio = proximo_desafio["type"]
<<<<<<< HEAD
	var id_desafio = proximo_desafio["id"]
	
	print("Tipo do próximo desafio: ", tipo_desafio)
	print("ID do próximo desafio: ", id_desafio)
	
	# Carregar os dados COMPLETOS do desafio baseado no tipo
	var dados_completos = {}
	var caminho_cena = ""
	
	match tipo_desafio:
		"quiz":
			dados_completos = carregar_dados_quiz(id_desafio)
			caminho_cena = "res://scenes/challenges/QuizChallenge.tscn"
			
		"relate":
			dados_completos = carregar_dados_relate(id_desafio)
			caminho_cena = "res://scenes/challenges/RelateChallenge.tscn"
			
		"dragdrop":
			dados_completos = carregar_dados_dragdrop(id_desafio)
			caminho_cena = "res://scenes/challenges/DragDropChallenge.tscn"
=======
	var caminho_cena = ""
	var dados_completos = {}
	
	print("Tipo do próximo desafio: ", tipo_desafio)
	print("ID do próximo desafio: ", proximo_desafio["id"])
	
	match tipo_desafio:
		"quiz":
			caminho_cena = "res://scenes/challenges/QuizChallenge.tscn"
			
			# Carregar dados do quiz
			var questao_atual = {
				"question_text": carregar_pergunta_quiz(proximo_desafio["id"]),
				"options": carregar_opcoes_quiz(proximo_desafio["id"]),
				"correct_answer": carregar_resposta_quiz(proximo_desafio["id"])
			}
			
			dados_completos = {
				"id": proximo_desafio["id"],
				"type": "quiz",
				"title": "Quiz",
				"instructions": "Leia a pergunta e selecione a alternativa correta.",
				"questions": [questao_atual]
			}
			print("Questão carregada: ", proximo_desafio["id"])
			
		"relate":
			caminho_cena = "res://scenes/challenges/RelateChallenge.tscn"
			dados_completos = carregar_dados_relate(proximo_desafio["id"])
			if dados_completos.is_empty():
				printerr("Não foi possível carregar dados do relate")
				return
				
			dados_completos["title"] = "Relacione"
			dados_completos["instructions"] = "Conecte os itens correspondentes"
			dados_completos["type"] = "relate"
			print("Dados do relate carregados: ", proximo_desafio["id"])
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
			
		_:
			printerr("Tipo de desafio desconhecido: ", tipo_desafio)
			return
	
<<<<<<< HEAD
	if dados_completos.is_empty():
		printerr("Não foi possível carregar dados do desafio: ", id_desafio)
		return
	
	# Adicionar metadados
	dados_completos["id"] = id_desafio
	dados_completos["type"] = tipo_desafio
	
	print("Dados completos preparados para: ", id_desafio)
	print("Carregando cena: ", caminho_cena)
	
	# Preparar desafio no SceneManager
	SceneManager.preparar_desafio_especifico(dados_completos)
	
	# Mudar para a cena do desafio
=======
	if caminho_cena.is_empty():
		printerr("Caminho de cena vazio!")
		return
	
	print("Carregando: ", caminho_cena)
	
	# WorldMap prepara os dados e SceneManager só armazena
	SceneManager.preparar_desafio_especifico(dados_completos)
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	get_tree().change_scene_to_file(caminho_cena)

func carregar_dados_fase() -> Dictionary:
	var arquivo = FileAccess.open("res://data/levels/fases.json", FileAccess.READ)
	if arquivo:
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		var dados = JSON.parse_string(conteudo)
		if dados is Dictionary:
			print("Dados das fases carregados com sucesso")
			return dados
<<<<<<< HEAD
	
	printerr("Erro ao carregar fases.json")
	return {}

func carregar_dados_quiz(quiz_id: String) -> Dictionary:
	var arquivo = FileAccess.open("res://data/levels/quiz.json", FileAccess.READ)
	if arquivo:
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		var todos_dados = JSON.parse_string(conteudo)
		
		if todos_dados is Dictionary and todos_dados.has(quiz_id):
			var dados_quiz = todos_dados[quiz_id]
			
			# Converter para o formato esperado pelo QuizChallenge
			# Se tiver apenas uma questão, criar array com ela
			var questoes = []
			if dados_quiz.has("question"):
				questoes.append({
					"question_text": dados_quiz.get("question", ""),
					"options": dados_quiz.get("options", []),
					"correct_answer": dados_quiz.get("correct_answer", "")
				})
			
			return {
				"title": dados_quiz.get("title", "Quiz"),
				"instructions": dados_quiz.get("instructions", "Responda as questões"),
				"questions": questoes
			}
	
	printerr("Erro ao carregar quiz: ", quiz_id)
=======
		else:
			printerr("Erro ao parsear JSON das fases")
	
	printerr("Arquivo de fases não encontrado ou vazio")
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	return {}

func carregar_dados_relate(relate_id: String) -> Dictionary:
	var arquivo = FileAccess.open("res://data/levels/relate.json", FileAccess.READ)
	if arquivo:
<<<<<<< HEAD
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		var todos_dados = JSON.parse_string(conteudo)
		
		if todos_dados is Dictionary and todos_dados.has(relate_id):
			var dados_relate = todos_dados[relate_id]
			
			# Adicionar título e instruções padrão se não existirem
			if not dados_relate.has("title"):
				dados_relate["title"] = "Relacione os Itens"
			if not dados_relate.has("instructions"):
				dados_relate["instructions"] = "Conecte os itens correspondentes"
			
			print("Dados do relate carregados: ", relate_id)
			return dados_relate
	
	printerr("Erro ao carregar relate: ", relate_id)
	return {}

func carregar_dados_dragdrop(dragdrop_id: String) -> Dictionary:
	var arquivo = FileAccess.open("res://data/levels/dragdrop.json", FileAccess.READ)
	if arquivo:
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		var todos_dados = JSON.parse_string(conteudo)
		
		if todos_dados is Dictionary and todos_dados.has(dragdrop_id):
			var dados_dragdrop = todos_dados[dragdrop_id]
			
			# Adicionar título e instruções padrão se não existirem
			if not dados_dragdrop.has("title"):
				dados_dragdrop["title"] = "Arraste e Solte"
			if not dados_dragdrop.has("instructions"):
				dados_dragdrop["instructions"] = "Arraste os itens para as posições corretas"
			
			print("Dados do dragdrop carregados: ", dragdrop_id)
			return dados_dragdrop
	
	printerr("Erro ao carregar dragdrop: ", dragdrop_id)
	return {}
=======
		var dados = JSON.parse_string(arquivo.get_as_text())
		arquivo.close()
		if dados is Dictionary and dados.has(relate_id):
			print("Dados do relate carregados: ", relate_id)
			return dados[relate_id]
		else:
			printerr("Relate não encontrado: ", relate_id)
	
	printerr("Arquivo relate.json não encontrado")
	return {}

func carregar_pergunta_quiz(quiz_id: String) -> String:
	# Carregar do arquivo quiz.json
	var arquivo = FileAccess.open("res://data/levels/quiz.json", FileAccess.READ)
	if arquivo:
		var dados = JSON.parse_string(arquivo.get_as_text())
		arquivo.close()
		var pergunta = dados.get(quiz_id, {}).get("question", "Pergunta não encontrada")
		print("Pergunta carregada para ", quiz_id, ": ", pergunta)
		return pergunta
	return "Pergunta não carregada"

func carregar_opcoes_quiz(quiz_id: String) -> Array:
	var arquivo = FileAccess.open("res://data/levels/quiz.json", FileAccess.READ)
	if arquivo:
		var dados = JSON.parse_string(arquivo.get_as_text())
		arquivo.close()
		var opcoes = dados.get(quiz_id, {}).get("options", ["Opção A", "Opção B"])
		print("Opções carregadas para ", quiz_id, ": ", opcoes)
		return opcoes
	return ["Opção A", "Opção B"]

func carregar_resposta_quiz(quiz_id: String) -> String:
	var arquivo = FileAccess.open("res://data/levels/quiz.json", FileAccess.READ)
	if arquivo:
		var dados = JSON.parse_string(arquivo.get_as_text())
		arquivo.close()
		var resposta = dados.get(quiz_id, {}).get("correct_answer", "Opção A")
		print("Resposta correta para ", quiz_id, ": ", resposta)
		return resposta
	return "Opção A"

func _on_botao_voltar_pressionado():
	print("Voltando para seleção de jogador...")
	SceneManager.limpar_dados()
	get_tree().change_scene_to_file("res://scenes/UI/StudentSelection.tscn")

func _on_botao_tema_anterior_pressionado() -> void:
	_on_botao_tema_anterior()
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
