# DragDropChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

<<<<<<< HEAD
@onready var container_itens_arrastaveis: VBoxContainer = find_child("DraggableItemsContainer", true, false)
@onready var container_areas_soltura: VBoxContainer = find_child("DropAreasContainer", true, false)

var itens_arrastaveis: Array = []
var zonas_soltura: Array = []
var itens_colocados_corretamente: int = 0
var total_itens: int = 0
var item_sendo_arrastado: Control = null
var offset_arrasto: Vector2 = Vector2.ZERO

# Armazenar referências aos grids para fácil acesso
var grid_itens: GridContainer = null
var grid_zonas: GridContainer = null

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
		printerr("Nenhum dado recebido! Usando fallback")
		var dados_teste = {
			"id": "dd_teste",
			"type": "dragdrop",
			"title": "Arraste e Solte - Teste",
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
	
	print("Carregados:")
	print("   - Itens arrastáveis: ", total_itens)
	print("   - Zonas de soltura: ", zonas_soltura.size())

func configurar_interface():
	print("Configurando interface Drag & Drop...")
	
	# Limpar completamente os containers
	for filho in container_itens_arrastaveis.get_children():
		filho.queue_free()
	for filho in container_areas_soltura.get_children():
		filho.queue_free()
	
	# Aguardar frame para limpeza
	await get_tree().process_frame
	
	# Cria o grid dos itens arrastaveis
	grid_itens = GridContainer.new()
	grid_itens.columns = 1  # Quantidade de colunas para os itens
	grid_itens.add_theme_constant_override("h_separation", 10)
	grid_itens.add_theme_constant_override("v_separation", 10)
	container_itens_arrastaveis.add_child(grid_itens)
	
	# Criar itens arrastáveis
	print("Criando ", itens_arrastaveis.size(), " itens arrastáveis")
	for i in range(itens_arrastaveis.size()):
		var item_data = itens_arrastaveis[i]
		var item = criar_item_arrastavel(item_data)
		grid_itens.add_child(item)
		print("   Item ", i + 1, ": ", item_data.get("id", "sem_id"))
	
	# Cria o grid de soltura
	grid_zonas = GridContainer.new()
	grid_zonas.columns = 1  # Quantidade colunas para as zonas
	grid_zonas.add_theme_constant_override("h_separation", 10)
	grid_zonas.add_theme_constant_override("v_separation", 10)
	container_areas_soltura.add_child(grid_zonas)
	
	# Criar zonas de soltura
	print("Criando ", zonas_soltura.size(), " zonas de soltura")
	for i in range(zonas_soltura.size()):
		var zona_data = zonas_soltura[i]
		var zona = criar_zona_soltura(zona_data)
		grid_zonas.add_child(zona)
		print("   Zona ", i + 1, ": ", zona_data.get("id", "sem_id"), " aceita ", zona_data.get("accepts", "?"))
	
	atualizar_progresso(0, total_itens)
	print("Interface configurada com sucesso!")

func criar_item_arrastavel(dados: Dictionary) -> Control:
	var item = PanelContainer.new()
	item.custom_minimum_size = Vector2(100, 100)
	item.set_meta("id", dados["id"])
	item.set_meta("tipo", "arrastavel")
	item.set_meta("posicao_original", Vector2.ZERO)
	item.set_meta("pai_original", null)
	item.set_meta("travado", false)
	
	# Estilo do item
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.2, 0.3, 0.5, 0.1)
	estilo.border_color = Color.TRANSPARENT
	item.add_theme_stylebox_override("panel", estilo)
	
	var conteudo = VBoxContainer.new()
	conteudo.alignment = BoxContainer.ALIGNMENT_CENTER
	item.add_child(conteudo)
	
	# Adicionar imagem SE existir
	if dados.has("image_path"):
		var texture_rect = TextureRect.new()
		var texture = load(dados["image_path"])
		if texture:
			texture_rect.texture = texture
			texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.custom_minimum_size = Vector2(100, 100)
			conteudo.add_child(texture_rect)
	
	# Adicionar texto SE existir
	if dados.has("text"):
		var label = Label.new()
		label.text = dados["text"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		conteudo.add_child(label)
	
	# Configurar para ser arrastável
	item.gui_input.connect(_on_item_gui_input.bind(item))
	item.mouse_filter = Control.MOUSE_FILTER_PASS
	
	return item

func criar_zona_soltura(dados: Dictionary) -> Control:
	var zona = PanelContainer.new()
	zona.custom_minimum_size = Vector2(100, 100)
	zona.set_meta("id", dados["id"])
	zona.set_meta("accepts", dados["accepts"])
	zona.set_meta("tipo", "zona_soltura")
	zona.set_meta("ocupada", false)
	
	# Estilo visual da zona
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.3, 0.3, 0.3, 0.4)
	estilo.border_color = Color(0.8, 0.8, 0.8, 1.0)
	estilo.border_width_left = 3
	estilo.border_width_right = 3
	estilo.border_width_top = 3
	estilo.border_width_bottom = 3
	estilo.draw_center = true
	zona.add_theme_stylebox_override("panel", estilo)
	
	# Label da zona
	var label = Label.new()
	label.text = dados["id"]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	zona.add_child(label)
	
	return zona

func _on_item_gui_input(event: InputEvent, item: Control):
	# Se o item está travado, não permite arrastar
	if item.get_meta("travado", false):
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Começar arrasto
			_iniciar_arrasto(item)
		elif item_sendo_arrastado == item:
			# Terminar arrasto
			_finalizar_arrasto(item)
	
	elif event is InputEventMouseMotion and item_sendo_arrastado == item:
		# Atualizar posição durante o arrasto
		item.global_position = get_global_mouse_position() - offset_arrasto

func _iniciar_arrasto(item: Control):
	var item_id = item.get_meta("id")
	print(">>> Iniciando arrasto: ", item_id)
	
	item_sendo_arrastado = item
	offset_arrasto = get_global_mouse_position() - item.global_position
	
	# Salvar posição original na primeira vez
	if item.get_meta("pai_original") == null:
		item.set_meta("pai_original", item.get_parent())
		item.set_meta("posicao_original", item.position)
		print("   Salvou posição original: ", item.position)
	
	# Feedback visual
	item.modulate = Color(1.2, 1.2, 0.8)
	item.z_index = 1000
	print("   Item movido para root")

func _finalizar_arrasto(item: Control):
	var item_id = item.get_meta("id")
	print(">>> Finalizando arrasto: ", item_id)
	
	var posicao_centro_item = item.global_position + item.size / 2
	var zona_encontrada = _encontrar_zona_sob_posicao(posicao_centro_item)
	
	if zona_encontrada:
		print("   Zona encontrada: ", zona_encontrada.get_meta("id"))
		_tentar_soltar_em_zona(item, zona_encontrada)
	else:
		print("   Nenhuma zona encontrada - retornando")
		_retornar_item_origem(item)
	
	# Resetar estado
	item_sendo_arrastado = null
	item.z_index = 0

func _encontrar_zona_sob_posicao(pos_global: Vector2) -> Control:
	# Buscar DENTRO do grid de zonas
	if not grid_zonas:
		print("   ERRO: grid_zonas é null!")
		return null
	
	print("   Procurando zona na posição: ", pos_global)
	print("   Grid tem ", grid_zonas.get_child_count(), " zonas")
	
	for zona in grid_zonas.get_children():
		if zona.get_meta("tipo", "") == "zona_soltura":
			var rect = Rect2(zona.global_position, zona.size)
			print("     Testando zona: ", zona.get_meta("id"), " rect: ", rect)
			
			if rect.has_point(pos_global):
				print("     ✓ ZONA ENCONTRADA!")
				return zona
	
	print("   Nenhuma zona sob o cursor")
	return null

func _tentar_soltar_em_zona(item: Control, zona: Control):
	var item_id = item.get_meta("id")
	var zona_id = zona.get_meta("id")
	var zona_aceita = zona.get_meta("accepts")
	
	print(">>> Tentando soltar:")
	print("   Item: ", item_id)
	print("   Zona: ", zona_id)
	print("   Aceita: ", zona_aceita)
	
	# Verificar se zona está ocupada
	if zona.get_meta("ocupada", false):
		print("   ✗ Zona já ocupada!")
		_retornar_item_origem(item)
		return
	
	# Verificar se é o item correto
	if item_id == zona_aceita:
		print("   ✓ CORRETO! Colocando item na zona")
		_colocar_item_na_zona(item, zona)
		
		itens_colocados_corretamente += 1
		pontuacao += 20
		
		# Feedback visual de sucesso
		zona.modulate = Color(0.2, 0.8, 0.2)  # Verde
		item.modulate = Color(0.2, 0.8, 0.2)
		item.set_meta("travado", true)
		
		print("   Progresso: ", itens_colocados_corretamente, "/", total_itens)
		atualizar_progresso(itens_colocados_corretamente, total_itens)
		
		# Verificar se completou
		if itens_colocados_corretamente >= total_itens:
			print("   🎉 TODOS OS ITENS COLOCADOS!")
			await get_tree().create_timer(1.0).timeout
			finalizar_drag_drop()
	else:
		print("   ✗ INCORRETO! Item não pertence aqui")
		pontuacao = max(0, pontuacao - 5)
		
		# Feedback visual de erro
		zona.modulate = Color(0.8, 0.2, 0.2)  # Vermelho
		item.modulate = Color(0.8, 0.2, 0.2)
		
		await get_tree().create_timer(0.5).timeout
		
		zona.modulate = Color.WHITE
		item.modulate = Color.WHITE
		
		_retornar_item_origem(item)

func _colocar_item_na_zona(item: Control, zona: Control):
	print("   Colocando item na zona...")
	
	# Remover do root
	if item.get_parent() == get_tree().root:
		get_tree().root.remove_child(item)
	
	# Adicionar à zona
	zona.add_child(item)
	
	# Centralizar
	item.position = (zona.size - item.size) / 2
	
	# Marcar zona como ocupada
	zona.set_meta("ocupada", true)
	
	print("   ✓ Item colocado com sucesso!")

func _retornar_item_origem(item: Control):
	print("   Retornando item para origem...")
	
	# Remover do root se estiver lá
	if item.get_parent() == get_tree().root:
		get_tree().root.remove_child(item)
	
	# Retornar ao pai original
	var pai_original = item.get_meta("pai_original")
	if pai_original and is_instance_valid(pai_original):
		pai_original.add_child(item)
		item.position = item.get_meta("posicao_original")
		item.modulate = Color.WHITE
		print("   ✓ Item retornou à origem")
	else:
		printerr("   ✗ ERRO: Pai original inválido!")

func finalizar_drag_drop():
	print("\n🎯 DRAG & DROP FINALIZADO!")
	print("   Itens corretos: ", itens_colocados_corretamente, "/", total_itens)
	print("   Pontuação: ", pontuacao)
	
	var sucesso = itens_colocados_corretamente == total_itens
	var dados_resultado = {
		"tipo": "dragdrop",
		"itens_corretos": itens_colocados_corretamente,
		"total_itens": total_itens,
		"precisao": int(float(itens_colocados_corretamente) / total_itens * 100) if total_itens > 0 else 0
	}
	
	# Atualizar pontuação do jogador
	if pontuacao > 0:
		GameManager.atualizar_pontuacao_jogador(pontuacao, {
			"sucesso": sucesso,
			"id": dados_desafio.get("id", "")
		})
	
	# Verificar se tem mais desafios
	if SceneManager.tem_mais_desafios():
		print("   → Avançando para próximo desafio")
		SceneManager.avancar_para_proximo_desafio()
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
	else:
		print("   → Último desafio - mostrando RewardScreen")
		finalizar_desafio(sucesso, dados_resultado)
=======
var textura_fundo: TextureRect
var container_itens_arrastaveis: HBoxContainer
var container_areas_soltura: Control

var _itens_para_arrastar: Array = []
var _dados_areas_soltura: Array = []
var _contador_colocacoes_corretas: int = 0
var _total_itens_para_colocar: int = 0

func _ready():
	super._ready()
	textura_fundo = find_child("BackgroundTextureRect", true, false)
	container_itens_arrastaveis = find_child("DragItemsContainer", true, false)
	container_areas_soltura = find_child("DropAreasContainer", true, false)
	set_process_input(true)

func _carregar_dados_desafio() -> Dictionary:
	return _dados_desafio

func _configurar_interface_desafio(dados: Dictionary) -> void:
	_itens_para_arrastar = dados.get("items_to_drag", [])
	_dados_areas_soltura = dados.get("drop_areas", [])
	_total_itens_para_colocar = _itens_para_arrastar.size()
	_contador_colocacoes_corretas = 0
	
	# Carregar background
	if dados.has("background_image_path"):
		var textura_fundo_carregada = load(dados["background_image_path"])
		if textura_fundo_carregada:
			textura_fundo.texture = textura_fundo_carregada
	
	# Limpar contêineres
	for filho in container_itens_arrastaveis.get_children(): 
		filho.queue_free()
	for filho in container_areas_soltura.get_children(): 
		filho.queue_free()
	
	# Criar itens arrastáveis
	for dados_item in _itens_para_arrastar:
		var item_arrastavel = DraggableItem.new()
		item_arrastavel.id = dados_item.id
		item_arrastavel.id_area_soltura_correta = dados_item.correct_drop_area_id
		
		# Configurar visual do item
		item_arrastavel.custom_minimum_size = Vector2(80, 80)
		item_arrastavel.size = Vector2(80, 80)
		
		# Adicionar TextureRect como filho para a imagem
		var textura_item = TextureRect.new()
		textura_item.texture = load(dados_item.image_path)
		textura_item.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		textura_item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		textura_item.size = Vector2(70, 70)
		textura_item.position = Vector2(5, 5)
		item_arrastavel.add_child(textura_item)
		
		item_arrastavel.item_soltado.connect(_on_item_soltado)
		container_itens_arrastaveis.add_child(item_arrastavel)
	
	# Criar áreas de soltura
	for dados_area in _dados_areas_soltura:
		var zona_soltura = preload("res://scenes/components/DropZone.tscn").instantiate()
		zona_soltura.id = dados_area.id
		zona_soltura.position = Vector2(dados_area.position_x, dados_area.position_y)
		zona_soltura.tamanho_padrao = Vector2(dados_area.size_x, dados_area.size_y)
		
		# Opcional: adicionar label para identificar
		var label = Label.new()
		label.text = dados_area.id
		label.position = Vector2(5, 5)
		zona_soltura.add_child(label)
		
		container_areas_soltura.add_child(zona_soltura)
	
	atualizar_barra_progresso(_contador_colocacoes_corretas, _total_itens_para_colocar)

func _iniciar_logica_desafio() -> void:
	pass

func _processar_entrada_jogador(_dados_entrada) -> void:
	pass

func _on_item_soltado(id_item_arrastavel: String, id_area_soltada: String, correto: bool, no_item_arrastavel: Node) -> void:
	if correto:
		_contador_colocacoes_corretas += 1
		_pontuacao += 20
		print("DragDrop: Item ", id_item_arrastavel, " colocado corretamente em ", id_area_soltada)
		
		var no_area_soltura: Control = null
		for area in container_areas_soltura.get_children():
			if area.id == id_area_soltada:
				no_area_soltura = area
				break

		if no_area_soltura:
			no_item_arrastavel.get_parent().remove_child(no_item_arrastavel)
			no_area_soltura.add_child(no_item_arrastavel)
			no_item_arrastavel.position = (no_area_soltura.size / 2) - (no_item_arrastavel.size / 2)
		no_item_arrastavel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		_tentativas += 1
		_pontuacao = max(0, _pontuacao - 5)
		print("DragDrop: Item ", id_item_arrastavel, " colocado INCORRETAMENTE em ", id_area_soltada)
		no_item_arrastavel.retornar_para_posicao_original()
	
	atualizar_barra_progresso(_contador_colocacoes_corretas, _total_itens_para_colocar)
	
	if _contador_colocacoes_corretas == _total_itens_para_colocar:
		var sucesso = _contador_colocacoes_corretas == _total_itens_para_colocar
		_on_desafio_concluido(sucesso, _pontuacao, {
			"colocacoes_corretas": _contador_colocacoes_corretas, 
			"total_colocacoes": _total_itens_para_colocar
		})
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
