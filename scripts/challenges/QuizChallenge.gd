# QuizChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"
<<<<<<< HEAD

# SINAL para controlar a pausa
signal continue_requested()

var question_text_label: RichTextLabel
var option_buttons_container: VBoxContainer
var feedback_label: Label
var next_button: Button

var _current_question_index: int = 0
var _questions_data: Array = []
var _correct_answers_count: int = 0
var _waiting_for_continue: bool = false
=======

signal continuar_solicitado

var label_texto_pergunta: RichTextLabel
var container_botoes_opcoes: VBoxContainer
var label_feedback: Label
var botao_proximo: Button

var _indice_pergunta_atual: int = 0
var _dados_perguntas: Array = []
var _contador_respostas_corretas: int = 0
>>>>>>> 9bd3b91e70dc7065013bfc314b91e94c4e59cf4d

func _ready():
	super._ready()
	print("QUIZCHALLENGE CARREGADO!")
<<<<<<< HEAD
	_find_quiz_ui_nodes()

func _find_quiz_ui_nodes():
	question_text_label = find_child("QuestionTextLabel", true, false)
	option_buttons_container = find_child("OptionButtonsContainer", true, false)
	feedback_label = find_child("FeedbackLabel", true, false)
	next_button = find_child("NextButton", true, false)
	
	if next_button and next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.disconnect(_on_next_button_pressed)
	
	if next_button:
		next_button.pressed.connect(_on_next_button_pressed)
		next_button.visible = false

func _setup_ui_for_challenge(data: Dictionary) -> void:
	print("_setup_ui_for_challenge()")
	
	if not option_buttons_container:
		printerr("OptionButtonsContainer não encontrado!")
		return
	
	# Validar dados obrigatórios
	if not data.has("question") or not data.has("options") or not data.has("correct_answer"):
		printerr("Dados da questão incompletos!")
		return
	
	if data["options"].is_empty():
		printerr("Nenhuma opção fornecida!")
		return
	
	if data["correct_answer"].is_empty():
		printerr("Resposta correta não fornecida!")
		return
	
	# Limpa botões antigos
	for child in option_buttons_container.get_children():
		child.queue_free()
	
	# Configura dados da questão
	if data.has("questions"):
		_questions_data = data["questions"]
	else:
		# Formato de questão única
		_questions_data = [{
			"question_text": data.get("question", ""),
			"options": data.get("options", []),
			"correct_answer": data.get("correct_answer", "")
		}]
	
	_current_question_index = 0
	_correct_answers_count = 0

func _load_challenge_data() -> Dictionary:
	return _challenge_data

func _start_challenge_logic() -> void:
	print("_start_challenge_logic()")
	_display_current_question()

func _process_player_input(_input_data) -> void:
	pass

# Função principal que controla o fluxo
func _display_current_question():
	print("Exibindo pergunta: ", _current_question_index)
	
	if _current_question_index >= _questions_data.size():
		_finish_quiz()
		return
	
	var current_question = _questions_data[_current_question_index]
	# Atualiza UI
	if question_text_label:
		question_text_label.text = "Pergunta %d/%d:\n%s" % [
			_current_question_index + 1, 
			_questions_data.size(), 
			current_question["question_text"]
		]
	
	# Habilita botões de opção
	for button in option_buttons_container.get_children():
		button.disabled = false
	
	# Limpa feedback
	if feedback_label:
		feedback_label.text = ""
		feedback_label.modulate = Color.WHITE
	
	# Esconde botão "Continuar"
	if next_button:
		next_button.visible = false
=======
	_buscar_nos_quiz()

func _buscar_nos_quiz():
	label_texto_pergunta = find_child("QuestionTextLabel", true, false)
	container_botoes_opcoes = find_child("OptionButtonsContainer", true, false)
	label_feedback = find_child("FeedbackLabel", true, false)
	botao_proximo = find_child("NextButton", true, false)
	
	if botao_proximo and botao_proximo.pressed.is_connected(_on_botao_proximo_pressionado):
		botao_proximo.pressed.disconnect(_on_botao_proximo_pressionado)
	
	if botao_proximo:
		botao_proximo.pressed.connect(_on_botao_proximo_pressionado)
		botao_proximo.visible = false

func _carregar_dados_desafio() -> Dictionary:
	return _dados_desafio

func _configurar_interface_desafio(dados: Dictionary) -> void:
	print("_configurar_interface_desafio()")
	
	if not container_botoes_opcoes:
		printerr("OptionButtonsContainer não encontrado!")
		return
	
	if not dados.has("question") or not dados.has("options") or not dados.has("correct_answer"):
		printerr("Dados da questão incompletos!")
		return
	
	if dados["options"].is_empty():
		printerr("Nenhuma opção fornecida!")
		return
	
	if dados["correct_answer"].is_empty():
		printerr("Resposta correta não fornecida!")
		return
	
	for filho in container_botoes_opcoes.get_children():
		filho.queue_free()
	
	if dados.has("questions"):
		_dados_perguntas = dados["questions"]
	else:
		_dados_perguntas = [{
			"question_text": dados.get("question", ""),
			"options": dados.get("options", []),
			"correct_answer": dados.get("correct_answer", "")
		}]
	
	_indice_pergunta_atual = 0
	_contador_respostas_corretas = 0
	_exibir_pergunta_atual()

func _iniciar_logica_desafio() -> void:
	print("_iniciar_logica_desafio() - QUIZ INICIADO!")
	
	if _dados_perguntas.is_empty():
		printerr("❌ Nenhuma pergunta carregada!")
		return
	
	if not label_texto_pergunta or not container_botoes_opcoes:
		printerr("❌ UI não está pronta!")
		return
	
	print("✅ Tudo pronto, quiz funcionando!")
	_verificar_e_iniciar_quiz()

func _verificar_e_iniciar_quiz():
	print("🎯 Verificando estado do quiz...")
	print("   - Perguntas carregadas: ", _dados_perguntas.size())
	print("   - Índice atual: ", _indice_pergunta_atual)
	print("   - Label de pergunta: ", label_texto_pergunta != null)
	print("   - Container de opções: ", container_botoes_opcoes != null)
	
	# Se por algum motivo a primeira pergunta não foi exibida, exibir agora
	if _indice_pergunta_atual == 0 and _dados_perguntas.size() > 0:
		print("🚀 Exibindo primeira pergunta...")
		_exibir_pergunta_atual()
	else:
		print("📝 Quiz já está em andamento na pergunta ", _indice_pergunta_atual + 1)

func _processar_entrada_jogador(_dados_entrada) -> void:
	pass

func _exibir_pergunta_atual():
	print("Exibindo pergunta: ", _indice_pergunta_atual)
	
	if _indice_pergunta_atual >= _dados_perguntas.size():
		_finalizar_quiz()
		return
	
	var pergunta_atual = _dados_perguntas[_indice_pergunta_atual]
	
	if label_texto_pergunta:
		label_texto_pergunta.text = "Pergunta %d/%d:\n%s" % [
			_indice_pergunta_atual + 1, 
			_dados_perguntas.size(), 
			pergunta_atual["question_text"]
		]
	else:
		printerr("❌ label_texto_pergunta é nulo!")
		return
>>>>>>> 9bd3b91e70dc7065013bfc314b91e94c4e59cf4d
	
	if container_botoes_opcoes:
		for filho in container_botoes_opcoes.get_children():
			filho.queue_free()
		
		var opcoes = pergunta_atual["options"]
		for i in range(opcoes.size()):
			var botao = Button.new()
			botao.text = opcoes[i]
			botao.custom_minimum_size = Vector2(400, 60)
			botao.pressed.connect(_on_opcao_selecionada.bind(i))
			container_botoes_opcoes.add_child(botao)
	
	if label_feedback:
		label_feedback.text = ""
		label_feedback.modulate = Color.WHITE
	
	if botao_proximo:
		botao_proximo.visible = false
	
	atualizar_barra_progresso(_indice_pergunta_atual + 1, _dados_perguntas.size())

<<<<<<< HEAD
func _on_option_selected(option_index: int):
	print("Opção selecionada: ", option_index)
	
	var current_question = _questions_data[_current_question_index]
	var correct_answer = current_question["correct_answer"]
	var selected_answer = current_question["options"][option_index]
	
	# Desabilita botões de opção
	for button in option_buttons_container.get_children():
		button.disabled = true
	
	# Mostra feedback
	if selected_answer == correct_answer:
		_correct_answers_count += 1
		_score += 10
		if feedback_label:
			feedback_label.text = "Correto! ✅"
			feedback_label.modulate = Color.GREEN
	else:
		if feedback_label:
			feedback_label.text = "Incorreto! ❌\nResposta: " + correct_answer
			feedback_label.modulate = Color.RED
	
	# Mostra botão "Continuar"
	if next_button:
		next_button.visible = true
	
	# Espera até o sinal continue_requested ser emitido
	print("CENA PARADA - Esperando continuar...")
	await continue_requested
	print("CENA CONTINUANDO...")
	
	# Continua o fluxo
	_go_to_next_question()

func _on_next_button_pressed():
	print("🎯 Continuar pressionado")
	
	continue_requested.emit()

# Função que faz a cena esperar
func _go_to_next_question():
	print("🎯 Preparando próxima questão...")
	_current_question_index += 1
	
	# A cena continua normalmente daqui
	_display_current_question()

func _finish_quiz():
	print("🎯 Quiz finalizado! Acertos: ", _correct_answers_count, "/", _questions_data.size())
	var is_success = _correct_answers_count > 0
	_on_challenge_completed(is_success, _score, {
		"correct_count": _correct_answers_count,
		"total_questions": _questions_data.size()
	})

func _exit_tree():
	# Limpar conexões
	if next_button and next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.disconnect(_on_next_button_pressed)
=======
func _on_opcao_selecionada(indice_opcao: int):
	print("Opção selecionada: ", indice_opcao)
	
	var pergunta_atual = _dados_perguntas[_indice_pergunta_atual]
	var resposta_correta = pergunta_atual["correct_answer"]
	var resposta_selecionada = pergunta_atual["options"][indice_opcao]
	
	for botao in container_botoes_opcoes.get_children():
		botao.disabled = true
	
	var acertou = (resposta_selecionada == resposta_correta)
	if acertou:
		_contador_respostas_corretas += 1
		_pontuacao += 10
		if label_feedback:
			label_feedback.text = "Correto! ✅ +10 pontos"
			label_feedback.modulate = Color.GREEN
	else:
		if label_feedback:
			label_feedback.text = "Incorreto! ❌\nResposta: " + resposta_correta
			label_feedback.modulate = Color.RED
	
	if botao_proximo:
		botao_proximo.visible = true
	
	print("CENA PARADA - Esperando continuar...")
	await continuar_solicitado
	print("CENA CONTINUANDO...")
	
	_ir_para_proxima_pergunta()

func _on_botao_proximo_pressionado():
	print("🎯 Continuar pressionado")
	continuar_solicitado.emit()

func _ir_para_proxima_pergunta():
	print("🎯 Preparando próxima questão...")
	_indice_pergunta_atual += 1
	
	if container_botoes_opcoes:
		for filho in container_botoes_opcoes.get_children():
			filho.queue_free()
	
	_exibir_pergunta_atual()

func _finalizar_quiz():
	print("🎯 Quiz finalizado! Acertos: ", _contador_respostas_corretas, "/", _dados_perguntas.size())
	
	var precisao = float(_contador_respostas_corretas) / _dados_perguntas.size()
	var sucesso = _contador_respostas_corretas > 0
	
	var pontuacao_base = _contador_respostas_corretas * 10
	var bonus_precisao = int(pontuacao_base * precisao)
	_pontuacao = pontuacao_base + bonus_precisao
	
	_on_desafio_concluido(sucesso, _pontuacao, {
		"acertos": _contador_respostas_corretas,
		"total_perguntas": _dados_perguntas.size(),
		"precisao_porcentagem": int(precisao * 100)
	})

func _exit_tree():
	if botao_proximo and botao_proximo.pressed.is_connected(_on_botao_proximo_pressionado):
		botao_proximo.pressed.disconnect(_on_botao_proximo_pressionado)
>>>>>>> 9bd3b91e70dc7065013bfc314b91e94c4e59cf4d
