# DragDropChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

# Containers da UI
@onready var container_itens_arrastaveis: VBoxContainer = find_child("DraggableItemsContainer", true, false)
@onready var container_areas_soltura: Control = find_child("DropAreasContainer", true, false)

# Dados do desafio
var itens_arrastaveis: Array = []
var zonas_soltura: Array = []
var itens_colocados_corretamente: int = 0
var total_itens: int = 0

# Item sendo arrastado
var item_sendo_arrastado: Control = null
var offset_arrasto: Vector2 = Vector2.ZERO

func _ready():
	super._ready()
	print("DRAG DROP CHALLENGE - Carregado")
	iniciar_com_dados()

func iniciar_com_dados():
	var dados = SceneManager.obter_dados_desafio_atual()
	if not dados.is_empty():
		print("Dados disponíveis no SceneManager")
		iniciar_desafio(dados)
	else:
		printerr("Nenhum dado de desafio recebido!")
		# Dados de fallback
		var dados_teste = {
			"id": "dragdrop_teste",
			"type": "dragdrop",
			"title": "Arraste e Solte",
			"instructions": "Arraste os itens para as posições corretas",
			"draggable_items": [
				{"id": "item1", "text": "Item 1"},
				{"id": "item2", "text": "Item 2"}
			],
			"drop_zones": [
				{"id": "zona1", "accepts": "item1"},
				{"id": "zona2", "accepts": "item2"}
			]
		}
		iniciar_desafio(dados_teste)

func iniciar_desafio(dados: Dictionary):
	print("DragDropChallenge.iniciar_desafio()")
	super.iniciar_desafio(dados)
	
	carregar_dados_desafio(dados)
	configurar_interface()

func carregar_dados_desafio(dados: Dictionary):
	itens_arrastaveis = dados.get("draggable_items", [])
	zonas_soltura = dados.get("drop_zones", [])
	total_itens = itens_arrastaveis.size()
	itens_colocados_corretamente = 0
	
	print("Itens arrastavéis: ", total_itens)
	print("Zonas de soltura: ", zonas_soltura.size())

func configurar_interface():
	print("Configurando interface Drag & Drop...")
	
	# Limpar containers
	for filho in container_itens_arrastaveis.get_children():
		filho.queue_free()
	for filho in container_areas_soltura.get_children():
		filho.queue_free()
	
	await get_tree().process_frame
	
	# Criar itens arrastáveis
	for item_data in itens_arrastaveis:
		var item = criar_item_arrastavel(item_data)
		container_itens_arrastaveis.add_child(item)
	
	# Criar zonas de soltura
	for zona_data in zonas_soltura:
		var zona = criar_zona_soltura(zona_data)
		container_areas_soltura.add_child(zona)
	
	atualizar_progresso(0, total_itens)

func criar_item_arrastavel(dados: Dictionary) -> Control:
	var item = PanelContainer.new()
	item.custom_minimum_size = Vector2(100, 100)
	item.set_meta("id", dados["id"])
	item.set_meta("tipo", "arrastavel")
	item.set_meta("posicao_original", Vector2.ZERO)
	item.set_meta("pai_original", null)
	
	var conteudo = VBoxContainer.new()
	conteudo.alignment = BoxContainer.ALIGNMENT_CENTER
	item.add_child(conteudo)
	
	# Adicionar imagem ou texto
	if dados.has("image_path"):
		var texture_rect = TextureRect.new()
		var texture = load(dados["image_path"])
		if texture:
			texture_rect.texture = texture
			texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.custom_minimum_size = Vector2(80, 80)
		conteudo.add_child(texture_rect)
	
	if dados.has("text"):
		var label = Label.new()
		label.text = dados["text"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		conteudo.add_child(label)
	
	# Configurar para ser arrastável
	item.gui_input.connect(_on_item_gui_input.bind(item))
	item.mouse_filter = Control.MOUSE_FILTER_PASS
	
	return item

func criar_zona_soltura(dados: Dictionary) -> Control:
	var zona = PanelContainer.new()
	zona.custom_minimum_size = Vector2(120, 120)
	zona.set_meta("id", dados["id"])
	zona.set_meta("accepts", dados["accepts"])
	zona.set_meta("tipo", "zona_soltura")
	zona.set_meta("ocupada", false)
	
	# Visual da zona
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.3, 0.3, 0.3, 0.5)
	estilo.border_color = Color.WHITE
	estilo.border_width_left = 2
	estilo.border_width_right = 2
	estilo.border_width_top = 2
	estilo.border_width_bottom = 2
	zona.add_theme_stylebox_override("panel", estilo)
	
	# Label indicando a zona
	var label = Label.new()
	label.text = "Zona " + dados["id"]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	zona.add_child(label)
	
	return zona

func _on_item_gui_input(event: InputEvent, item: Control):
	# Verificar se o item está travado
	if item.get_meta("travado", false):
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Iniciar arrasto
				_iniciar_arrasto(item)
			elif item_sendo_arrastado == item:
				# Finalizar arrasto
				_finalizar_arrasto(item)
	
	elif event is InputEventMouseMotion and item_sendo_arrastado == item:
		# Atualizar posição durante o arrasto
		item.global_position = get_global_mouse_position() - offset_arrasto

func _iniciar_arrasto(item: Control):
	print("Iniciando arrasto de: ", item.get_meta("id"))
	
	item_sendo_arrastado = item
	offset_arrasto = get_global_mouse_position() - item.global_position
	
	# Salvar posição e pai original se ainda não foi salvo
	if item.get_meta("pai_original") == null:
		item.set_meta("pai_original", item.get_parent())
		item.set_meta("posicao_original", item.position)
	
	# Mover para a raiz para ficar acima de tudo
	var pai_atual = item.get_parent()
	pai_atual.remove_child(item)
	get_tree().root.add_child(item)
	
	# Destacar visualmente
	item.modulate = Color(1.2, 1.2, 0.8)
	item.z_index = 1000

func _finalizar_arrasto(item: Control):
	print("Finalizando arrasto de: ", item.get_meta("id"))
	
	var posicao_soltura = item.global_position + item.size / 2
	var zona_encontrada = _encontrar_zona_sob_posicao(posicao_soltura)
	
	if zona_encontrada:
		_tentar_soltar_em_zona(item, zona_encontrada)
	else:
		_retornar_item_origem(item)
	
	item_sendo_arrastado = null
	item.modulate = Color.WHITE
	item.z_index = 0

func _encontrar_zona_sob_posicao(pos_global: Vector2) -> Control:
	for zona in container_areas_soltura.get_children():
		if zona.get_meta("tipo") == "zona_soltura":
			var rect = Rect2(zona.global_position, zona.size)
			if rect.has_point(pos_global):
				return zona
	return null

func _tentar_soltar_em_zona(item: Control, zona: Control):
	var item_id = item.get_meta("id")
	var zona_aceita = zona.get_meta("accepts")
	var zona_id = zona.get_meta("id")
	
	print("Tentando soltar ", item_id, " em zona que aceita ", zona_aceita)
	
	# Verificar se a zona já está ocupada
	if zona.get_meta("ocupada", false):
		print("Zona já ocupada!")
		_retornar_item_origem(item)
		return
	
	# Verificar se é a correspondência correta
	if item_id == zona_aceita:
		print("CORRETO! Item colocado na zona correta")
		_colocar_item_na_zona(item, zona)
		
		itens_colocados_corretamente += 1
		pontuacao += 20
		
		# Feedback visual de sucesso
		zona.modulate = Color.GREEN
		item.modulate = Color.GREEN
		item.set_meta("travado", true)
		
		atualizar_progresso(itens_colocados_corretamente, total_itens)
		
		# Verificar se completou o desafio
		if itens_colocados_corretamente >= total_itens:
			await get_tree().create_timer(0.5).timeout
			finalizar_drag_drop()
	else:
		print("INCORRETO! Item não pertence a esta zona")
		pontuacao = max(0, pontuacao - 5)
		
		# Feedback visual de erro
		zona.modulate = Color.RED
		await get_tree().create_timer(0.3).timeout
		zona.modulate = Color.WHITE
		
		_retornar_item_origem(item)

func _colocar_item_na_zona(item: Control, zona: Control):
	# Remover da raiz
	get_tree().root.remove_child(item)
	
	# Adicionar à zona
	zona.add_child(item)
	
	# Centralizar na zona
	item.position = (zona.size - item.size) / 2
	
	# Marcar zona como ocupada
	zona.set_meta("ocupada", true)

func _retornar_item_origem(item: Control):
	print("Retornando item para origem")
	
	# Remover da raiz
	get_tree().root.remove_child(item)
	
	# Retornar ao pai original
	var pai_original = item.get_meta("pai_original")
	if pai_original:
		pai_original.add_child(item)
		item.position = item.get_meta("posicao_original")

func finalizar_drag_drop():
	print("DRAG & DROP FINALIZADO!")
	print("   - Itens corretos: ", itens_colocados_corretamente, "/", total_itens)
	
	var sucesso = itens_colocados_corretamente == total_itens
	
	var dados_resultado = {
		"tipo": "dragdrop",
		"itens_corretos": itens_colocados_corretamente,
		"total_itens": total_itens,
		"precisao": int(float(itens_colocados_corretamente) / total_itens * 100) if total_itens > 0 else 0
	}
	
	finalizar_desafio(sucesso, dados_resultado)
