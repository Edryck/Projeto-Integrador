# QuizChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

# Referências aos nós da UI
@onready var label_pergunta: RichTextLabel = find_child("QuestionTextLabel", true, false)
@onready var container_opcoes: GridContainer = find_child("OptionButtonsContainer", true, false)
@onready var label_feedback: Label = find_child("FeedbackLabel", true, false)
@onready var botao_proximo: Button = find_child("NextButton", true, false)

# Temas e fonte
var fonte = preload("res://assets/fonts/Pixel Digivolve.otf")
var tema_opcao_correta = preload("res://assets/UI/tema_opcao_correta.tres")
var tema_opcao_incorreta = preload("res://assets/UI/tema_opcao_incorreta.tres")
var tema = preload("res://assets/UI/MenuInicialTema.tres")

# Variáveis do quiz
var perguntas: Array = []
var pergunta_atual: int = 0
var acertos: int = 0
var resposta_ja_selecionada: bool = false

func _ready():
	super._ready()
	print("QUIZ CHALLENGE - Carregado")
	
	# Configurar botão próximo
	if botao_proximo:
		if botao_proximo.pressed.is_connected(_avancar_pergunta):
			botao_proximo.pressed.disconnect(_avancar_pergunta)
		botao_proximo.pressed.connect(_avancar_pergunta)
		botao_proximo.visible = false
		print("Botão próximo configurado")

func _setup_desafio_especifico():
	print("QuizChallenge._setup_desafio_especifico()")
	carregar_perguntas(dados_desafio)
	mostrar_pergunta_atual()

func carregar_perguntas(dados: Dictionary):
	print("Carregando perguntas...")
	
	print("Dicionário de dados recebido: ", dados)
	
	perguntas.clear()
	acertos = 0
	pergunta_atual = 0
	
	if dados.has("questions"):
		perguntas = dados["questions"].duplicate(true)
		print("Questões carregadas: ", perguntas.size())
	elif dados.has("question"):
		perguntas = [{
			"question": dados.get("question", "Pergunta não encontrada"), 
			"instructions": dados.get("instructions", "Leia e selecione."), 
			"options": dados.get("options", ["Opção A", "Opção B"]),
			"correct_answer": dados.get("correct_answer", "Opção A")
		}]
	else:
		printerr("Nenhuma questão encontrada nos dados!")
	
	print("Total de perguntas: ", perguntas.size())
	atualizar_progresso(0, perguntas.size())

func mostrar_pergunta_atual():
	print("Mostrando pergunta ", pergunta_atual + 1, " de ", perguntas.size())
	resposta_ja_selecionada = false
	
	# Verificar se ainda tem perguntas
	if pergunta_atual < 0 or pergunta_atual >= perguntas.size():
		print("Não há mais perguntas - Finalizando quiz")
		finalizar_quiz()
		return
	
	# Pegar a pergunta atual
	var pergunta = perguntas[pergunta_atual]
	var texto_pergunta = pergunta.get("question_text", pergunta.get("question", "Pergunta sem texto"))
	var opcoes = pergunta.get("options", ["Opção A", "Opção B"])
	
	# Mostrar pergunta
	if label_pergunta:
		# Altera a cor do texto da pergunta
		label_pergunta.text = "%s" % [
			texto_pergunta
		]
	
	# Limpar opções anteriores
	for filho in container_opcoes.get_children():
		filho.queue_free()
	
	# Aguardar frame para garantir que os botões antigos foram removidos
	await get_tree().process_frame
	
	container_opcoes.columns = 2  # Definir 2 colunas para formar 2x2
	
	# Criar novos botões de opção
	for i in range(opcoes.size()):
		var conteudo_opcao = opcoes[i]
		var botao = Button.new()
		botao.text = opcoes[i]
		botao.custom_minimum_size = Vector2(200, 90)
		botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Expandir horizontalmente
		botao.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		botao.add_theme_font_override("font", fonte)
		botao.theme = tema
		# Solução para o problema do texto do botão ultrapassar o tamanho
		botao.text = ""
		var is_imagem = str(conteudo_opcao).begins_with("res://") or str(conteudo_opcao).ends_with(".png") or str(conteudo_opcao).ends_with(".jpg")
		
		if is_imagem:
			# LÓGICA DE IMAGEM
			var texture_rect = TextureRect.new()
			var texture = load(conteudo_opcao)
			if texture:
				texture_rect.texture = texture
				texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				
				# Adiciona margem para a imagem não colar na borda do botão
				texture_rect.offset_left = 10
				texture_rect.offset_top = 10
				texture_rect.offset_right = -10
				texture_rect.offset_bottom = -10
				
				# Importante: Ignorar mouse na imagem para o clique ir para o botão
				texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE 
				botao.add_child(texture_rect)
			else:
				# Fallback se a imagem não carregar
				botao.text = "Erro img"
		else:
			var label_do_botao = Label.new()
			label_do_botao.text = str(conteudo_opcao)
			label_do_botao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label_do_botao.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			label_do_botao.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label_do_botao.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label_do_botao.mouse_filter = Control.MOUSE_FILTER_IGNORE # Clique passa para o botão
			
			# Margem para texto não colar na borda
			label_do_botao.offset_left = 10
			label_do_botao.offset_right = -10
			
			botao.add_child(label_do_botao)
		
		# Conectar sinal - importante: bind para passar o índice
		botao.pressed.connect(_on_opcao_selecionada.bind(i))
		container_opcoes.add_child(botao)
	
	# Limpar feedback
	if label_feedback:
		label_feedback.text = ""
		label_feedback.modulate = Color.WHITE
	
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
		return
	
	var pergunta = perguntas[pergunta_atual]
	var resposta_correta = pergunta["correct_answer"]
	var resposta_selecionada = pergunta["options"][indice_opcao]
	
	print("   - Resposta selecionada: '", resposta_selecionada, "'")
	print("   - Resposta correta: '", resposta_correta, "'")
	
	var botoes = container_opcoes.get_children()
	var botao_selecionado = botoes[indice_opcao]
	
	# Desabilitar todos os botões
	for botao in container_opcoes.get_children():
		if botao is Button:
			botao.disabled = true
	
	# Verificar resposta
	var acertou = (resposta_selecionada == resposta_correta)
	
	if acertou:
		acertos += 1
		pontuacao += 10
		print("Resposta CORRETA! +10 pontos")
		
		botao_selecionado.theme = tema_opcao_correta
		
		if label_feedback:
			label_feedback.text = "✓ Correto! +10 pontos"
			label_feedback.modulate = Color.GREEN
	else:
		print("Resposta INCORRETA")
		
		botao_selecionado.theme = tema_opcao_incorreta
		
		var indice_correto = pergunta["options"].find(pergunta["correct_answer"])
		if indice_correto != indice_opcao:
			var botao_correto = botoes[indice_correto]
			botao_correto.theme = tema_opcao_correta
		
		if label_feedback:
			label_feedback.text = "✗ Incorreto!\nResposta correta: " + resposta_correta
			label_feedback.modulate = Color.RED
	
	# Mostrar botão próximo
	if botao_proximo:
		# Trocar texto se for a última pergunta
		if pergunta_atual == perguntas.size() - 1:
			botao_proximo.text = "Finalizar Quiz"
		else:
			botao_proximo.text = "Próxima Pergunta"
		
		botao_proximo.visible = true
	
	atualizar_progresso(pergunta_atual + 1, perguntas.size())

func _avancar_pergunta():
	print("Avançando para próxima pergunta...")
	
	# Verificar se era a última pergunta
	if pergunta_atual >= perguntas.size() - 1:
		finalizar_quiz()
	else:
		pergunta_atual += 1
		mostrar_pergunta_atual()

# Ao finalizar quiz, apenas emite eventos — RewardScreen virá via gerenciador externo
func finalizar_quiz():
	print("QUIZ FINALIZADO!")
	print("   - Acertos: ", acertos, "/", perguntas.size())
	print("   - Pontuação: ", pontuacao)
	
	var precisao = float(acertos) / perguntas.size() if perguntas.size() > 0 else 0
	var sucesso = acertos > 0
	
	var dados_resultado = {
		"tipo": "quiz",
		"acertos": acertos,
		"total_perguntas": perguntas.size(),
		"precisao": int(precisao * 100),
		"tempo_gasto": (Time.get_ticks_msec() - tempo_inicio) / 1000.0
	}
	print("Dados para recompensa: ", dados_resultado)
	# Apenas manda finalizar desafio
	finalizar_desafio(sucesso, dados_resultado)
