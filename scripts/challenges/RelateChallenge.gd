# RelateChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

# Elementos da UI
@onready var container_esquerda: VBoxContainer = find_child("LeftColumnContainer", true, false)
@onready var container_direita: VBoxContainer = find_child("RightColumnContainer", true, false)
@onready var area_desenho: Control = find_child("DrawingCanvas", true, false)

# Variáveis do jogo
var itens_esquerda: Array = []
var itens_direita: Array = []
var conexoes_corretas: Array = []
var conexoes_feitas: Dictionary = {}
var conexoes_corretas_count: int = 0

# Estado de arrasto
var arrastando: bool = false
var ponto_origem_id: String = ""
var linha_inicio: Vector2

func _ready():
	super._ready()
	print("RELATE CHALLENGE - Carregado")
	
	# Configurar área de desenho
	if area_desenho:
		area_desenho.mouse_filter = Control.MOUSE_FILTER_PASS
		print("Área de desenho configurada")

func _setup_desafio_especifico(dados: Dictionary):
	print("RelateChallenge._setup_desafio_especifico()")
	carregar_itens(dados)
	configurar_interface()

func carregar_itens(dados: Dictionary):
	itens_esquerda = dados.get("items_left_column", [])
	itens_direita = dados.get("items_right_column", [])
	conexoes_corretas = dados.get("correct_connections", [])
	conexoes_feitas.clear()
	conexoes_corretas_count = 0
	
	print("Itens carregados:")
	print("   - Esquerda: ", itens_esquerda.size())
	print("   - Direita: ", itens_direita.size())
	print("   - Conexões corretas: ", conexoes_corretas.size())

func configurar_interface():
	print("Configurando interface...")
	
	# Verificar se os containers existem (importante para evitar erro em cenas diferentes)
	if not container_esquerda or not container_direita:
		printerr("Containers não encontrados! Verifique se os nós LeftColumnContainer e RightColumnContainer existem na cena.")
		return
	
	# Limpar containers
	for filho in container_esquerda.get_children():
		filho.queue_free()
	for filho in container_direita.get_children():
		filho.queue_free()
	
	# Aguardar frame para garantir limpeza
	await get_tree().process_frame
	
	# Criar itens da esquerda
	for item_data in itens_esquerda:
		var botao = Button.new()
		botao.custom_minimum_size = Vector2(100, 100)
		
		# Configurar visual
		if item_data.has("text"):
			botao.text = item_data["text"]
		elif item_data.has("image_path"):
			# Se tiver imagem, usar TextureRect
			var texture = load(item_data["image_path"])
			if texture:
				botao.icon = texture
				botao.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				botao.expand_icon = true
		
		botao.set_meta("id", item_data["id"])
		botao.set_meta("lado", "esquerda")
		botao.pressed.connect(_on_item_esquerda_clicado.bind(item_data["id"]))
		container_esquerda.add_child(botao)
	
	# Criar itens da direita
	for item_data in itens_direita:
		var botao = Button.new()
		botao.custom_minimum_size = Vector2(100, 100)
		
		# Configurar visual
		if item_data.has("text"):
			botao.text = item_data["text"]
		elif item_data.has("image_path"):
			var texture = load(item_data["image_path"])
			if texture:
				botao.icon = texture
				botao.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		botao.set_meta("id", item_data["id"])
		botao.set_meta("lado", "direita")
		botao.pressed.connect(_on_item_direita_clicado.bind(item_data["id"]))
		container_direita.add_child(botao)
	
	atualizar_progresso(0, conexoes_corretas.size())

func _on_item_esquerda_clicado(id_esquerda: String):
	print("Item esquerda clicado: ", id_esquerda)
	
	# Resetar se já estava arrastando outro
	if arrastando:
		_resetar_botao_origem()
	
	if not conexoes_feitas.has(id_esquerda):
		arrastando = true
		ponto_origem_id = id_esquerda
		
		# Destacar botão de origem
		for botao in container_esquerda.get_children():
			if botao.get_meta("id") == id_esquerda:
				botao.modulate = Color.YELLOW
				break
		
		print("Iniciando conexão de: ", id_esquerda)

func _on_item_direita_clicado(id_direita: String):
	print("Item direita clicado: ", id_direita)
	
	if arrastando and ponto_origem_id:
		_tentar_conectar(ponto_origem_id, id_direita)
		_resetar_estado_arrasto()

func _resetar_botao_origem():
	for botao in container_esquerda.get_children():
		if botao.get_meta("id") == ponto_origem_id:
			if conexoes_feitas.has(ponto_origem_id):
				botao.modulate = Color.GREEN
			else:
				botao.modulate = Color.WHITE
			break

func _resetar_estado_arrasto():
	arrastando = false
	_resetar_botao_origem()
	ponto_origem_id = ""
	
	if area_desenho:
		area_desenho.queue_redraw()

func _tentar_conectar(id_origem: String, id_destino: String):
	print("Tentando conectar: ", id_origem, " → ", id_destino)
	
	# Verificar se já existe conexão
	if conexoes_feitas.has(id_origem) or _item_ja_conectado(id_destino):
		print("Um dos itens já está conectado")
		return
	
	# Verificar se a conexão é correta
	var conexao_correta = false
	for conexao in conexoes_corretas:
		if conexao["left_id"] == id_origem and conexao["right_id"] == id_destino:
			conexao_correta = true
			break
	
	if conexao_correta:
		# Conexão correta
		conexoes_feitas[id_origem] = id_destino
		conexoes_corretas_count += 1
		pontuacao += 20
		print("Conexão CORRETA! +20 pontos")
		
		# Destacar itens conectados
		_destacar_item_por_id(id_origem, Color.GREEN)
		_destacar_item_por_id(id_destino, Color.GREEN)
		
		# Desabilitar botões conectados
		_desabilitar_item_por_id(id_origem)
		_desabilitar_item_por_id(id_destino)
	else:
		# Conexão incorreta
		pontuacao = max(0, pontuacao - 5)
		print("Conexão INCORRETA! -5 pontos")
		
		# Feedback visual temporário
		_destacar_item_por_id(id_origem, Color.RED)
		_destacar_item_por_id(id_destino, Color.RED)
		
		await get_tree().create_timer(0.5).timeout
		
		_destacar_item_por_id(id_origem, Color.WHITE)
		_destacar_item_por_id(id_destino, Color.WHITE)
	
	atualizar_progresso(conexoes_corretas_count, conexoes_corretas.size())
	
	if area_desenho:
		area_desenho.queue_redraw()
	
	# Verificar se completou
	if conexoes_corretas_count == conexoes_corretas.size():
		await get_tree().create_timer(0.5).timeout
		finalizar_relate()

func _item_ja_conectado(id_item: String) -> bool:
	for origem in conexoes_feitas:
		if conexoes_feitas[origem] == id_item:
			return true
	return false

func _destacar_item_por_id(id: String, cor: Color):
	# Buscar na esquerda
	for botao in container_esquerda.get_children():
		if botao is Button and botao.get_meta("id") == id:
			botao.modulate = cor
			return
	
	# Buscar na direita
	for botao in container_direita.get_children():
		if botao is Button and botao.get_meta("id") == id:
			botao.modulate = cor
			return

func _desabilitar_item_por_id(id: String):
	# Buscar na esquerda
	for botao in container_esquerda.get_children():
		if botao is Button and botao.get_meta("id") == id:
			botao.disabled = true
			return
	
	# Buscar na direita
	for botao in container_direita.get_children():
		if botao is Button and botao.get_meta("id") == id:
			botao.disabled = true
			return

func _process(_delta):
	if arrastando and area_desenho:
		area_desenho.queue_redraw()

func _draw():
	if not area_desenho:
		return
	
	# Desenhar no canvas através de um método personalizado
	_desenhar_linhas()

func _desenhar_linhas():
	if not area_desenho:
		return
	
	var area_global_pos = area_desenho.global_position
	
	# Desenhar conexões permanentes
	for id_origem in conexoes_feitas:
		var id_destino = conexoes_feitas[id_origem]
		var botao_origem = _obter_botao_por_id(id_origem)
		var botao_destino = _obter_botao_por_id(id_destino)
		
		if botao_origem and botao_destino:
			var inicio_global = botao_origem.global_position + botao_origem.size / 2
			var fim_global = botao_destino.global_position + botao_destino.size / 2
			
			var inicio_local = inicio_global - area_global_pos
			var fim_local = fim_global - area_global_pos
			
			area_desenho.draw_line(inicio_local, fim_local, Color.GREEN, 3)
	
	# Desenhar linha temporária durante arrasto
	if arrastando and ponto_origem_id:
		var botao_origem = _obter_botao_por_id(ponto_origem_id)
		if botao_origem:
			var inicio_global = botao_origem.global_position + botao_origem.size / 2
			var fim_global = get_global_mouse_position()
			
			var inicio_local = inicio_global - area_global_pos
			var fim_local = fim_global - area_global_pos
			
			area_desenho.draw_line(inicio_local, fim_local, Color.YELLOW, 2)

func _obter_botao_por_id(id: String) -> Control:
	# Buscar na esquerda
	for botao in container_esquerda.get_children():
		if botao is Button and botao.get_meta("id") == id:
			return botao
	
	# Buscar na direita
	for botao in container_direita.get_children():
		if botao is Button and botao.get_meta("id") == id:
			return botao
	
	return null

func finalizar_relate():
	print("RELATE FINALIZADO!")
	print("   - Conexões: ", conexoes_corretas_count, "/", conexoes_corretas.size())
	
	var sucesso = conexoes_corretas_count == conexoes_corretas.size()
	
	var dados_resultado = {
		"tipo": "relate",
		"conexoes_corretas": conexoes_corretas_count,
		"total_conexoes": conexoes_corretas.size(),
		"precisao": int(float(conexoes_corretas_count) / conexoes_corretas.size() * 100) if conexoes_corretas.size() > 0 else 0
	}
	
	finalizar_desafio(sucesso, dados_resultado)
