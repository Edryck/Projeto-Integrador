# DragDropChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

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

func _setup_desafio_especifico(dados: Dictionary):
	print("DragDropChallenge._setup_desafio_especifico()")
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
		print("   CORRETO! Colocando item na zona")
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
			print("   TODOS OS ITENS COLOCADOS!")
			await get_tree().create_timer(1.0).timeout
			finalizar_drag_drop()
	else:
		print("   INCORRETO! Item não pertence aqui")
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
	
	# Remover do pai atual (root ou grid)
	var pai_atual = item.get_parent()
	if pai_atual:
		pai_atual.remove_child(item)
	
	# Adicionar à zona como filho
	zona.add_child(item)
	
	# Ajustar posição relativa à zona (centralizar)
	item.position = zona.size - item.size
	item.z_index = 0  # Resetar z_index
	
	# Marcar zona como ocupada
	zona.set_meta("ocupada", true)
	
	print("   ✓ Item colocado com sucesso na zona!")

func _retornar_item_origem(item: Control):
	print("   Retornando item para origem...")
	
	# Remover do pai atual (pode ser root ou zona)
	var pai_atual = item.get_parent()
	if pai_atual:
		pai_atual.remove_child(item)
	
	# Retornar ao pai original
	var pai_original = item.get_meta("pai_original")
	if pai_original and is_instance_valid(pai_original):
		pai_original.add_child(item)
		item.position = item.get_meta("posicao_original", Vector2.ZERO)
		item.modulate = Color.WHITE
		item.z_index = 0  # Resetar z_index
		print("   ✓ Item retornou à origem")
	else:
		printerr("   ✗ ERRO: Pai original inválido!")

# Ao finalizar, só notifica ChallengeBase, reward e cenas serão tratadas por um fluxo externo
func finalizar_drag_drop():
	print("DRAGDROP FINALIZADO!")
	var sucesso = itens_colocados_corretamente == total_itens
	var dados_resultado = {
		"tipo": "drag_drop",
		"acertos": itens_colocados_corretamente,
		"total_itens": total_itens,
		"tempo_gasto": (Time.get_ticks_msec() - tempo_inicio) / 1000.0
	}
	finalizar_desafio(sucesso, dados_resultado)
