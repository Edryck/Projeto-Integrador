# RewardScreen.gd
extends Control

# Sinal para voltar ao mapa
signal sair_para_mapa

# Obtém referência para o título da tela
@onready var label_titulo: Label = $Background/MarginContainer/VBoxContainer/TitleLabel
# Obtém referência para a pontuação exibida
@onready var label_pontuacao: Label = $Background/MarginContainer/VBoxContainer/ScoreLabel
# Obtém referência para mensagem de feedback
@onready var label_mensagem: Label = $Background/MarginContainer/VBoxContainer/MessageLabel
# Referência para o container de estrelas na tela
@onready var container_estrelas: HBoxContainer = $Background/MarginContainer/VBoxContainer/EstrelasContainer/ContainerEstrelas
# Botão para continuar após a recompensa
@onready var botao_continuar: Button = $Background/MarginContainer/VBoxContainer/ContinueButton

# Lista de referências para as estrelas visuais
var estrelas: Array = []

# Executado quando o RewardScreen entra na árvore de nós
func _ready():
	print("RewardScreen carregada!")
	# Garantir que está visível
	visible = true
	# Como o RewardScreen é instanciado dinamicamente, @onready pode não funcionar
	# Vamos buscar os nós manualmente se não foram encontrados
	if not label_titulo:
		label_titulo = find_child("TitleLabel", true, false)
	if not label_pontuacao:
		label_pontuacao = find_child("ScoreLabel", true, false)
	if not label_mensagem:
		label_mensagem = find_child("MessageLabel", true, false)
	if not botao_continuar:
		botao_continuar = find_child("ContinueButton", true, false)
	if not container_estrelas:
		var estrelas_container = find_child("ContainerEstrelas", true, false)
		if estrelas_container:
			container_estrelas = estrelas_container
	
	# Verificar se encontrou os nós essenciais
	if not label_titulo or not label_pontuacao or not label_mensagem:
		printerr("ERRO: Não foi possível encontrar os labels da RewardScreen!")
		printerr("   - label_titulo: ", label_titulo)
		printerr("   - label_pontuacao: ", label_pontuacao)
		printerr("   - label_mensagem: ", label_mensagem)
	
	# Coletar e apagar todas as estrelas (estado inicial)
	if container_estrelas:
		for i in range(container_estrelas.get_child_count()):
			var estrela = container_estrelas.get_child(i)
			if estrela is TextureRect:
				estrelas.append(estrela)
				estrela.modulate = Color(0.3, 0.3, 0.3)  # Cinza/apagada
		print("   - Estrelas encontradas: ", estrelas.size())
	else:
		printerr("   - Container de estrelas não encontrado!")

# Mostra o resultado do desafio para o jogador
# Parâmetros:
#  - sucesso: bool - se o jogador completou/desafio
#  - pontuacao: int - pontos obtidos
#  - dados: informações extras sobre o desafio (ex: acertos)
func mostrar_resultado(sucesso: bool, pontuacao: int, dados: Dictionary):
	print("Configurando RewardScreen:")
	print("   - Sucesso: ", sucesso)
	print("   - Pontuação: ", pontuacao)
	print("   - Dados: ", dados)
	
	# Garantir que está visível e processando
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Garantir que os labels foram encontrados antes de usar
	if not label_titulo:
		label_titulo = find_child("TitleLabel", true, false)
	if not label_pontuacao:
		label_pontuacao = find_child("ScoreLabel", true, false)
	if not label_mensagem:
		label_mensagem = find_child("MessageLabel", true, false)
	
	# Verificar se encontrou os labels antes de usar
	if not label_titulo or not label_pontuacao or not label_mensagem:
		printerr("ERRO CRÍTICO: Labels não encontrados na RewardScreen!")
		return

	if sucesso:
		label_titulo.text = "Parabéns!"
		label_titulo.modulate = Color.GOLD
		label_mensagem.text = "Você completou a fase!"
	else:
		label_titulo.text = "Continue Tentando!"
		label_titulo.modulate = Color.ORANGE_RED
		label_mensagem.text = "Não desista, você consegue!"

	label_pontuacao.text = "Pontuação: " + str(pontuacao)
	# Calcula e exibe a quantidade de estrelas
	calcular_estrelas(pontuacao, dados)
	# Garantir que aparece diretamente na tela (sem animação por enquanto)
	modulate = Color(1, 1, 1, 1)  # Totalmente visível
	scale = Vector2(1, 1)  # Tamanho normal
	# Garantir que o botão está habilitado
	if botao_continuar:
		botao_continuar.disabled = false
	print("RewardScreen exibido na tela")

# Calcula e exibe o número de estrelas conquistadas
# Considera acertos e quantidade total de perguntas/itens
# Parâmetros:
#  - _pontuacao: int (não usado diretamente)
#  - dados: Dictionary deve conter "acertos" e "total_perguntas" ou "total_itens" ou "total_conexoes"
func calcular_estrelas(_pontuacao: int, dados: Dictionary):
	# Suporta diferentes tipos de desafios
	var total_perguntas = dados.get("total_perguntas", dados.get("total_itens", dados.get("total_conexoes", 1)))
	var acertos = dados.get("acertos", 0)
	var precisao = float(acertos) / total_perguntas if total_perguntas > 0 else 0

	print("   - Precisão: ", int(precisao * 100), "%")
	print("   - Acertos: ", acertos, "/", total_perguntas)

	# Define as estrelas baseando-se na precisão
	var estrelas_conquistadas = 0
	if precisao >= 0.9:
		estrelas_conquistadas = 3
	elif precisao >= 0.7:
		estrelas_conquistadas = 2
	elif precisao >= 0.5:
		estrelas_conquistadas = 1

	print("   - Estrelas conquistadas: ", estrelas_conquistadas)
	# Acende as estrelas conquistadas
	for i in range(estrelas.size()):
		if i < estrelas_conquistadas:
			estrelas[i].modulate = Color.GOLD
		else:
			estrelas[i].modulate = Color(0.3, 0.3, 0.3)

# Chamado ao pressionar o botão "Continuar" ou usar ESC/Enter
func _on_botao_continuar_pressionado():
	print("Botão Continuar pressionado")
	# Anima saída (desaparecendo)
	#var tween = create_tween()
	#tween.set_parallel(true)
	#tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.4)
	#tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.4)
	#await tween.finished
	print("Saindo para o mapa...")
	get_tree().paused = false
	sair_para_mapa.emit()
	queue_free()  # Remove RewardScreen da árvore
	print("RewardScreen removida")
	
	# Aguardar um frame antes de mudar de cena
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")

# Permite fechar a RewardScreen usando ESC ou Enter
func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_on_botao_continuar_pressionado()

func _on_continue_button_pressed() -> void:
	$confirm.play()

func _on_continue_button_mouse_entered() -> void:
	$hover.play()
