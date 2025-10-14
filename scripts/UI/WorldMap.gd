# WorldMap.gd
extends Control

var student_name_label: Label
var score_label: Label
var theme_title_label: Label
var theme_viewer: Control
var previous_button: TextureButton
var next_button: TextureButton

# Vamos guardar nossos temas em um array para facilitar a navegação
var themes: Array = []
var current_theme_index: int = 0

func _ready():
	# Busca os nós
	_find_all_nodes()
	# Pega todos os nós de tema (filhos do ThemeViewer) e os coloca no nosso array
	for theme_node in theme_viewer.get_children():
		themes.append(theme_node)
		# Conecta todos os botões de fase dentro de cada tema
		for phase_button in theme_node.get_children():
			if phase_button is Button:
				# O nome do botão será o ID da fase!
				var phase_id = phase_button.name
				phase_button.pressed.connect(_on_phase_button_pressed.bind(phase_id))

	update_student_info()
	_update_theme_display()

func _find_all_nodes():
	student_name_label = find_child("StudentNameLabel", true, false)
	score_label = find_child("ScoreLabel", true, false)
	theme_title_label = find_child("ThemeTitleLabel", true, false)
	theme_viewer = find_child("ThemeViewer", true, false)
	previous_button = find_child("PreviousThemeButton", true, false)
	next_button = find_child("NextThemeButton", true, false)
	
	# Se ainda não encontrou, tenta caminhos alternativos
	if not theme_viewer:
		theme_viewer = $StudentHUD/HBoxContainer/ThemeViewer if has_node("StudentHUD/HBoxContainer/ThemeViewer") else null
	if not previous_button:
		previous_button = $StudentHUD/HBoxContainer/Background/PreviousThemeButton if has_node("StudentHUD/HBoxContainer/Background/PreviousThemeButton") else null
	if not next_button:
		next_button = $StudentHUD/HBoxContainer/Background/NextThemeButton if has_node("StudentHUD/HBoxContainer/Background/NextThemeButton") else null

# Atualiza a UI com os dados do aluno que fez "login"
func update_student_info():
	if GameManager.current_player:
		student_name_label.text = "Aluno: " + GameManager.current_player.student_name
		score_label.text = "Pontuação: " + str(GameManager.current_player.total_score)

# A função principal que mostra o tema correto e esconde os outros
func _update_theme_display():
	for i in themes.size():
		var theme_node = themes[i]
		if i == current_theme_index:
			theme_node.visible = true
			# Atualiza o título. Ex: "Theme_Sistema_Solar" vira "Sistema Solar"
			theme_title_label.text = theme_node.name.replace("Theme_", "").replace("_", " ")
		else:
			theme_node.visible = false
			
# Chamado quando o botão ">" é pressionado
func _on_next_theme_pressed():
	current_theme_index = (current_theme_index + 1) % themes.size()
	_update_theme_display()

# Chamado quando o botão "<" é pressionado
func _on_previous_theme_pressed():
	current_theme_index -= 1
	if current_theme_index < 0:
		current_theme_index = themes.size() - 1
	_update_theme_display()

# Chamado quando um botão de FASE (dentro de um tema) é pressionado
func _on_phase_button_pressed(phase_id: String):
	print("Iniciando fase: ", phase_id)
	
	GameManager.set_current_phase_id(phase_id)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_next_theme_button_pressed() -> void:
	pass # Replace with function body.


func _on_previous_theme_button_pressed() -> void:
	pass # Replace with function body.


func _on_theme_title_label_gui_input(_event: InputEvent) -> void:
	pass # Replace with function body.


func _on_student_name_label_gui_input(_event: InputEvent) -> void:
	pass # Replace with function body.


func _on_score_label_gui_input(_event: InputEvent) -> void:
	pass # Replace with function body.
