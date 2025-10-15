# QuizChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

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

func _ready():
	super._ready()
	print("QUIZCHALLENGE CARREGADO!")
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
	
	update_progress_bar(_current_question_index + 1, _questions_data.size())

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
