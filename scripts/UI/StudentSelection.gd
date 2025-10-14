# StudentSelection.gd
extends Control

## Remove as referências @onready e busca os nós manualmente
var student_list_container: VBoxContainer
var new_student_input: LineEdit
var create_button: Button
var feedback_label: Label


func _ready():
	# Busca os nós manualmente
	student_list_container = find_child("StudentListContainer", true, false)
	new_student_input = find_child("NewStudentInput", true, false)
	create_button = find_child("CreateStudentButton", true, false)
	feedback_label = find_child("FeedbackLabel", true, false)
	
	# Verifica se todos os nós foram encontrados
	if not student_list_container:
		printerr("ERRO CRÍTICO: StudentListContainer não encontrado!")
		print("Árvore da cena:")
		print_tree_pretty()
		return
	# Assim que a cena carregar, preenche a lista com os alunos existentes
	_populate_student_list()
	
	# Foca no campo de texto para o jogador já poder digitar
	new_student_input.grab_focus()


# Função para limpar e preencher a lista de alunos
func _populate_student_list():
	# 1. Limpa qualquer botão que já exista para não duplicar
	for child in student_list_container.get_children():
		child.queue_free()
		
	# 2. Pega a lista de todos os dados dos alunos do GameManager
	var students = GameManager.get_all_students_for_dashboard()
	
	# 3. Cria um botão para cada aluno
	if students.is_empty():
		feedback_label.text = "Nenhum aluno cadastrado. Crie um novo perfil!"
	else:
		feedback_label.text = "Selecione seu perfil ou crie um novo."
		for student_data in students:
			var student_name = student_data.get("name", "Nome Desconhecido")
			var button = Button.new()
			button.text = student_name
			# Define um tamanho mínimo para os botões ficarem uniformes
			button.custom_minimum_size = Vector2(250, 50) 
			# Conecta o sinal 'pressed' deste botão à função de seleção
			button.pressed.connect(_on_student_button_pressed.bind(student_name))
			student_list_container.add_child(button)


# Chamado quando o botão "Criar e Entrar" é pressionado
func _on_create_student_button_pressed():
	print("=== DEBUG ===")
	print("feedback_label é válido:", is_instance_valid(feedback_label))
	print("new_student_input é válido:", is_instance_valid(new_student_input))
	print("create_button é válido:", is_instance_valid(create_button))
	# Busca os nós novamente para garantir que estão válidos
	var current_feedback_label = find_child("FeedbackLabel", true, false)
	var current_new_student_input = find_child("NewStudentInput", true, false)
	
	var student_name = current_new_student_input.text.strip_edges() if current_new_student_input else ""
	
	if student_name.is_empty():
		if current_feedback_label:
			current_feedback_label.text = "O nome não pode estar em branco."
		return
	
	if GameManager.create_new_student_profile(student_name):
		if current_feedback_label:
			current_feedback_label.text = str("Bem-vindo(a), ", student_name, "!")
		if current_new_student_input:
			current_new_student_input.clear()
		_populate_student_list()
		# _on_student_button_pressed(student_name)
	else:
		if current_feedback_label:
			current_feedback_label.text = "Este nome já existe. Tente outro."

# Chamado quando um dos botões de aluno (da lista) é pressionado
func _on_student_button_pressed(student_name: String):
	print("Tentando carregar estudante: ", student_name)
	
	if GameManager.load_student_profile(student_name):
		print("Estudante carregado com sucesso, indo para o mapa...")
		get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
	else:
		printerr("FALHA ao carregar estudante: ", student_name)
