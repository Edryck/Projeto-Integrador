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
var phases_data: Dictionary = {}

func _ready():
	# Busca os nós
	_find_all_nodes()
	
	# Carrega os dados das fases do JSON
	_load_phases_data()
	
	# Conecta os botões de fase que já existem no editor
	_setup_existing_phase_buttons()
	
	update_student_info()
	_update_theme_display()

func _load_phases_data():
	var file = FileAccess.open("res://data/levels/fases.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		print("Conteúdo do arquivo fases.json:")
		print(content)  # Isso vai mostrar exatamente o que está sendo lido
		
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			phases_data = json.data
			print("Dados das fases carregados com sucesso: ", phases_data)
		else:
			printerr("Erro ao parsear JSON das fases na linha ", json.get_error_line(), ": ", json.get_error_message())
			printerr("Texto do erro: ", content.substr(max(0, json.get_error_line() - 50), 100))
	else:
		printerr("Arquivo de fases não encontrado: res://data/levels/fases.json")

func _setup_existing_phase_buttons():
	# Limpa o array de temas
	themes.clear()
	
	# Para cada tema no ThemeViewer
	for theme_node in theme_viewer.get_children():
		themes.append(theme_node)
		
		# Para cada botão dentro deste tema
		for phase_button in theme_node.get_children():
			if phase_button is Button:
				var phase_id = phase_button.name
				var phase_data = phases_data.get(phase_id, {})
				
				# Atualiza o texto do botão baseado no JSON
				if phase_data.has("title"):
					phase_button.text = phase_data["title"]
				
				# Feedback visual se a fase foi completada
				if GameManager.is_phase_completed(phase_id):
					phase_button.add_theme_color_override("font_color", Color.GREEN)
					phase_button.text += " ✓"

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

# Função chamada quando qualquer botão de fase é pressionado
# Tem que conectar todos os botões no editor para esta função
func _on_phase_button_pressed():
	var phase_button = get_viewport().gui_get_focus_owner()
	if phase_button and phase_button is Button:
		var phase_id = phase_button.name
		
		if phases_data.has(phase_id):
			print("=== INICIANDO FASE ===")
			
			# Define a fase
			GameManager.current_phase_id = phase_id
			
			# Troca para ChallengeBase (container vazio)
			print("Carregando container de desafios...")
			get_tree().change_scene_to_file("res://scenes/challenges/ChallengeBase.tscn")
