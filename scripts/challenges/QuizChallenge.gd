# QuizChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

# Referências aos nós da UI
@onready var label_pergunta: RichTextLabel = find_child("QuestionTextLabel", true, false)
<<<<<<< HEAD
@onready var container_opcoes: GridContainer = find_child("OptionButtonsContainer", true, false)
=======
@onready var container_opcoes: VBoxContainer = find_child("OptionButtonsContainer", true, false)
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
@onready var label_feedback: Label = find_child("FeedbackLabel", true, false)
@onready var botao_proximo: Button = find_child("NextButton", true, false)

# Variáveis do quiz
var perguntas: Array = []
var pergunta_atual: int = 0
var acertos: int = 0
<<<<<<< HEAD
var resposta_ja_selecionada: bool = false
=======
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13

func _ready():
	super._ready()
	print("QUIZ CHALLENGE - Carregado")
	
	# Configurar botão próximo
	if botao_proximo:
<<<<<<< HEAD
		if botao_proximo.pressed.is_connected(_avancar_pergunta):
			botao_proximo.pressed.disconnect(_avancar_pergunta)
=======
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
		botao_proximo.pressed.connect(_avancar_pergunta)
		botao_proximo.visible = false
		print("Botão próximo configurado")
	
	iniciar_com_dados()

func iniciar_com_dados():
	var dados = SceneManager.obter_dados_desafio_atual()
	
	if not dados.is_empty():
		print("Dados disponíveis no SceneManager")
<<<<<<< HEAD
		iniciar_desafio(dados)
	else:
		printerr("Nenhum dado de desafio recebido!")
		# Dados de fallback
		var dados_teste = {
			"id": "quiz_teste",
			"type": "quiz",
			"title": "Quiz de Teste",
			"instructions": "Responda a questão",
=======
		print("   - ID: ", dados.get("id", "sem_id"))
		print("   - Tipo: ", dados.get("type", "desconhecido"))
		iniciar_desafio(dados)
	else:
		printerr("Nenhum dado de desafio recebido!")
		# Dados de teste com MÚLTIPLAS perguntas
		var dados_teste = {
			"id": "quiz_multiplo_teste",
			"type": "quiz",
			"title": "Quiz com Múltiplas Perguntas",
			"instructions": "Responda todas as perguntas",
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
			"questions": [
				{
					"question_text": "Qual é a capital do Brasil?",
					"options": ["São Paulo", "Rio de Janeiro", "Brasília", "Salvador"],
					"correct_answer": "Brasília"
<<<<<<< HEAD
				}
			]
		}
		print("Usando dados de teste")
=======
				},
				{
					"question_text": "Quantos estados tem o Brasil?",
					"options": ["26", "27", "25", "28"],
					"correct_answer": "26"
				},
				{
					"question_text": "Qual o maior planeta do sistema solar?",
					"options": ["Terra", "Júpiter", "Saturno", "Marte"],
					"correct_answer": "Júpiter"
				}
			]
		}
		print("Usando dados de teste com múltiplas perguntas")
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
		iniciar_desafio(dados_teste)

func iniciar_desafio(dados: Dictionary):
	print("QuizChallenge.iniciar_desafio()")
<<<<<<< HEAD
	super.iniciar_desafio(dados)
=======
	print("   - Dados recebidos: ", dados.get("id", "sem_id"))
	
	super.iniciar_desafio(dados)
	
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	carregar_perguntas(dados)
	mostrar_pergunta_atual()

func carregar_perguntas(dados: Dictionary):
	print("Carregando perguntas...")
	perguntas.clear()
	acertos = 0
	pergunta_atual = 0
	
	if dados.has("questions"):
<<<<<<< HEAD
		perguntas = dados["questions"].duplicate(true)
		print("Questões carregadas: ", perguntas.size())
	elif dados.has("question"):
=======
		# MÚLTIPLAS QUESTÕES - JUNTA TODAS EM UM VETOR
		perguntas = dados["questions"]
		print("Questões carregadas: ", perguntas.size())
		
		# Mostrar detalhes de cada pergunta carregada
		for i in range(perguntas.size()):
			var pergunta = perguntas[i]
			print("   ", i + 1, ": ", pergunta.get("question_text", "Sem texto"))
			print("      Opções: ", pergunta.get("options", []))
			print("      Resposta: ", pergunta.get("correct_answer", ""))
			
	elif dados.has("question"):
		# QUESTÃO ÚNICA (formato antigo) - CONVERTE PARA VETOR
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
		perguntas = [{
			"question_text": dados.get("question", "Pergunta não encontrada"),
			"options": dados.get("options", ["Opção A", "Opção B"]),
			"correct_answer": dados.get("correct_answer", "Opção A")
		}]
<<<<<<< HEAD
	else:
		printerr("Nenhuma questão encontrada nos dados!")
	
	print("Total de perguntas: ", perguntas.size())
=======
		print("Questão única convertida para vetor")
	else:
		# FALLBACK - VETOR COM PERGUNTAS PADRÃO
		printerr("Nenhuma questão encontrada nos dados!")
		perguntas = [
			{
				"question_text": "Pergunta de fallback 1",
				"options": ["Opção A", "Opção B", "Opção C", "Opção D"],
				"correct_answer": "Opção A"
			},
			{
				"question_text": "Pergunta de fallback 2", 
				"options": ["Verdadeiro", "Falso"],
				"correct_answer": "Verdadeiro"
			}
		]
		print("Usando fallback com múltiplas perguntas")
	
	print("Total de perguntas no vetor: ", perguntas.size())
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	atualizar_progresso(0, perguntas.size())

func mostrar_pergunta_atual():
	print("Mostrando pergunta ", pergunta_atual + 1, " de ", perguntas.size())
<<<<<<< HEAD
	resposta_ja_selecionada = false
	
	# Verificar se ainda tem perguntas
=======
	
	# VERIFICA SE AINDA TEM PERGUNTAS - MANDA UMA POR UMA
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	if pergunta_atual < 0 or pergunta_atual >= perguntas.size():
		print("Não há mais perguntas - Finalizando quiz")
		finalizar_quiz()
		return
	
<<<<<<< HEAD
	# Pegar a pergunta atual
	var pergunta = perguntas[pergunta_atual]
	var texto_pergunta = pergunta.get("question_text", pergunta.get("question", "Pergunta sem texto"))
	var opcoes = pergunta.get("options", ["Opção A", "Opção B"])
	
	# Mostrar pergunta
	if label_pergunta:
		label_pergunta.text = "%s" % [
			texto_pergunta
		]
=======
	# PEGA A PRÓXIMA PERGUNTA DO VETOR
	var pergunta = perguntas[pergunta_atual]
	
	# Suporte para ambos os formatos (question_text e question)
	var texto_pergunta = pergunta.get("question_text", pergunta.get("question", "Pergunta sem texto"))
	var opcoes = pergunta.get("options", ["Opção A", "Opção B"])
	var resposta_correta = pergunta.get("correct_answer", "Opção A")
	
	print("   - Texto: ", texto_pergunta)
	print("   - Opções: ", opcoes)
	print("   - Resposta correta: ", resposta_correta)
	
	# Mostrar pergunta
	if label_pergunta:
		label_pergunta.text = "Pergunta %d/%d:\n%s" % [
			pergunta_atual + 1, 
			perguntas.size(), 
			texto_pergunta
		]
	else:
		printerr("label_pergunta é nulo!")
		return
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	
	# Limpar opções anteriores
	for filho in container_opcoes.get_children():
		filho.queue_free()
	
<<<<<<< HEAD
	# Aguardar frame para garantir que os botões antigos foram removidos
	await get_tree().process_frame
	
	container_opcoes.columns = 2  # Definir 2 colunas para formar 2x2
	
	# Criar novos botões de opção
	for i in range(opcoes.size()):
		var botao = Button.new()
		botao.text = opcoes[i]
		botao.custom_minimum_size = Vector2(200, 60)
		botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Expandir horizontalment
		# Conectar sinal - importante: bind para passar o índice
		botao.pressed.connect(_on_opcao_selecionada.bind(i))
		container_opcoes.add_child(botao)
	
	# Limpar feedback
=======
	# Criar botões de opção
	print("   - Criando ", opcoes.size(), " opções")
	
	for i in range(opcoes.size()):
		var botao = Button.new()
		botao.text = opcoes[i]
		botao.custom_minimum_size = Vector2(400, 60)
		
		# Conectar sinal
		botao.pressed.connect(_on_opcao_selecionada.bind(i))
		
		container_opcoes.add_child(botao)
	
	# Limpar feedback e esconder botão próximo
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	if label_feedback:
		label_feedback.text = ""
		label_feedback.modulate = Color.WHITE
	
<<<<<<< HEAD
	# Esconder botão próximo
	if botao_proximo:
		botao_proximo.visible = false
	
	# Atualizar progresso
	atualizar_progresso(pergunta_atual, perguntas.size())

func _on_opcao_selecionada(indice_opcao: int):
	# Evitar múltiplas seleções
	if resposta_ja_selecionada:
		return
	
	resposta_ja_selecionada = true
	print("Opção selecionada: ", indice_opcao)
	
	if pergunta_atual >= perguntas.size():
=======
	if botao_proximo:
		botao_proximo.visible = false
	
	# Atualizar progresso (quantas já foram respondidas)
	atualizar_progresso(pergunta_atual, perguntas.size())

func _on_opcao_selecionada(indice_opcao: int):
	print("Opção selecionada: ", indice_opcao)
	
	if pergunta_atual >= perguntas.size():
		printerr("Índice de pergunta inválido!")
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
		return
	
	var pergunta = perguntas[pergunta_atual]
	var resposta_correta = pergunta["correct_answer"]
	var resposta_selecionada = pergunta["options"][indice_opcao]
	
	print("   - Resposta selecionada: '", resposta_selecionada, "'")
	print("   - Resposta correta: '", resposta_correta, "'")
	
	# Desabilitar todos os botões
	for botao in container_opcoes.get_children():
<<<<<<< HEAD
		if botao is Button:
			botao.disabled = true
=======
		botao.disabled = true
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	
	# Verificar resposta
	var acertou = (resposta_selecionada == resposta_correta)
	
	if acertou:
		acertos += 1
		pontuacao += 10
		print("Resposta CORRETA! +10 pontos")
		
		if label_feedback:
<<<<<<< HEAD
			label_feedback.text = "✓ Correto! +10 pontos"
=======
			label_feedback.text = "Correto! +10 pontos"
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
			label_feedback.modulate = Color.GREEN
	else:
		print("Resposta INCORRETA")
		if label_feedback:
<<<<<<< HEAD
			label_feedback.text = "✗ Incorreto!\nResposta correta: " + resposta_correta
			label_feedback.modulate = Color.RED
	
	# Mostrar botão próximo
	if botao_proximo:
		# Trocar texto se for a última pergunta
		if pergunta_atual >= perguntas.size() - 1:
			botao_proximo.text = "Finalizar Quiz"
		else:
			botao_proximo.text = "Próxima Pergunta"
		
=======
			label_feedback.text = "Incorreto!\nResposta: " + resposta_correta
			label_feedback.modulate = Color.RED
	
	# Mostrar botão próximo para ir para a PRÓXIMA PERGUNTA
	if botao_proximo:
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
		botao_proximo.visible = true
	
	atualizar_progresso(pergunta_atual + 1, perguntas.size())

func _avancar_pergunta():
	print("Avançando para próxima pergunta...")
<<<<<<< HEAD
	
	# Verificar se era a última pergunta
	if pergunta_atual >= perguntas.size() - 1:
		finalizar_quiz()
	else:
		pergunta_atual += 1
		mostrar_pergunta_atual()
=======
	pergunta_atual += 1
	mostrar_pergunta_atual()
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13

func finalizar_quiz():
	print("QUIZ FINALIZADO!")
	print("   - Acertos: ", acertos, "/", perguntas.size())
<<<<<<< HEAD
	print("   - Pontuação: ", pontuacao)
	
	var precisao = float(acertos) / perguntas.size() if perguntas.size() > 0 else 0
	var sucesso = acertos > 0
	
=======
	print("   - Perguntas respondidas: ", pergunta_atual, "/", perguntas.size())
	
	var precisao = float(acertos) / perguntas.size()
	var sucesso = acertos > 0
	
	# Cálculo de pontuação baseado no desempenho
	pontuacao = acertos * 10 + int(precisao * 50)
	
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
	var dados_resultado = {
		"tipo": "quiz",
		"acertos": acertos,
		"total_perguntas": perguntas.size(),
		"precisao": int(precisao * 100),
<<<<<<< HEAD
		"tempo_gasto": (Time.get_ticks_msec() - tempo_inicio) / 1000.0
	}
	
	# Atualiza a pontuação do jogador
	if pontuacao > 0:
		GameManager.atualizar_pontuacao_jogador(pontuacao, {
			"sucesso": sucesso,
			"id": dados_desafio.get("id", "")
		})
	print("Dados para recompensa: ", dados_resultado)
	
	# Verifica se tem mais desafios
	if SceneManager.tem_mais_desafios():
		print("Avançando para próximo desafio (sem RewardScreen)...")
		SceneManager.avancar_para_proximo_desafio()
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
	else:
		# Última atividade da fase, agora mostrar RewardScreen
		print("Último desafio da fase - mostrando RewardScreen")
		finalizar_desafio(sucesso, dados_resultado)
=======
		"tempo_gasto": (Time.get_ticks_msec() - tempo_inicio) / 1000.0,
		"perguntas_respondidas": pergunta_atual
	}
	
	print("Dados para recompensa: ", dados_resultado)
	
	# Finalizar desafio (ChallengeBase cuida da progressão)
	super.finalizar_desafio(sucesso, dados_resultado)
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
