# WorldMap.gd
extends Control

var label_nome_aluno: Label
var label_pontuacao: Label
var label_titulo_tema: Label
var visualizador_temas: Control
var botao_anterior: TextureButton
var botao_proximo: TextureButton

<<<<<<< HEAD
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
=======
var temas: Array = []
var indice_tema_atual: int = 0
var dados_fases: Dictionary = {}

func _ready():
	_buscar_todos_nos()
	_carregar_dados_fases()
	_configurar_botoes_fase_existentes()
	_atualizar_info_aluno()
	_atualizar_exibicao_tema()

func _carregar_dados_fases():
	var arquivo = FileAccess.open("res://data/levels/fases.json", FileAccess.READ)
	if arquivo:
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		
		print("Conteúdo do arquivo fases.json:")
		print(conteudo)
		
		var json = JSON.new()
		var erro = json.parse(conteudo)
		if erro == OK:
			dados_fases = json.data
			print("Dados das fases carregados com sucesso: ", dados_fases)
>>>>>>> 9bd3b91e70dc7065013bfc314b91e94c4e59cf4d
		else:
			printerr("Erro ao parsear JSON das fases: ", json.get_error_message())
	else:
		printerr("Arquivo de fases não encontrado")

<<<<<<< HEAD
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
=======
func _configurar_botoes_fase_existentes():
	temas.clear()
	
	for no_tema in visualizador_temas.get_children():
		temas.append(no_tema)
		
		for botao_fase in no_tema.get_children():
			if botao_fase is Button:
				var id_fase = botao_fase.name
				var dados_fase = dados_fases.get(id_fase, {})
				
				if dados_fase.has("title"):
					botao_fase.text = dados_fase["title"]
				
				if GameManager.fase_foi_concluida(id_fase):
					botao_fase.add_theme_color_override("font_color", Color.GREEN)
					botao_fase.text += " ✓"

func _buscar_todos_nos():
	label_nome_aluno = find_child("StudentNameLabel", true, false)
	label_pontuacao = find_child("ScoreLabel", true, false)
	label_titulo_tema = find_child("ThemeTitleLabel", true, false)
	visualizador_temas = find_child("ThemeViewer", true, false)
	botao_anterior = find_child("PreviousThemeButton", true, false)
	botao_proximo = find_child("NextThemeButton", true, false)
	
	if not visualizador_temas:
		visualizador_temas = $StudentHUD/HBoxContainer/ThemeViewer if has_node("StudentHUD/HBoxContainer/ThemeViewer") else null
	if not botao_anterior:
		botao_anterior = $StudentHUD/HBoxContainer/Background/PreviousThemeButton if has_node("StudentHUD/HBoxContainer/Background/PreviousThemeButton") else null
	if not botao_proximo:
		botao_proximo = $StudentHUD/HBoxContainer/Background/NextThemeButton if has_node("StudentHUD/HBoxContainer/Background/NextThemeButton") else null

func _atualizar_info_aluno():
	if GameManager.jogador_atual:
		label_nome_aluno.text = "Aluno: " + GameManager.jogador_atual.student_name
		label_pontuacao.text = "Pontuação: " + str(GameManager.jogador_atual.pontuacao_total)

func _atualizar_exibicao_tema():
	for i in temas.size():
		var no_tema = temas[i]
		if i == indice_tema_atual:
			no_tema.visible = true
			label_titulo_tema.text = no_tema.name.replace("Theme_", "").replace("_", " ")
		else:
			no_tema.visible = false

func _on_botao_proximo_tema_pressionado():
	indice_tema_atual = (indice_tema_atual + 1) % temas.size()
	_atualizar_exibicao_tema()

func _on_botao_tema_anterior_pressionado():
	indice_tema_atual -= 1
	if indice_tema_atual < 0:
		indice_tema_atual = temas.size() - 1
	_atualizar_exibicao_tema()

func _on_botao_fase_pressionado():
	var botao_fase = get_viewport().gui_get_focus_owner()
	if botao_fase and botao_fase is Button:
		var id_fase = botao_fase.name
		
		if dados_fases.has(id_fase):
			print("=== INICIANDO FASE ===")
			GameManager.id_fase_atual = id_fase
>>>>>>> 9bd3b91e70dc7065013bfc314b91e94c4e59cf4d
			get_tree().change_scene_to_file("res://scenes/challenges/ChallengeBase.tscn")
