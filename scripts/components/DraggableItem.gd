# DraggableItem.gd
<<<<<<< HEAD
extends Area2D

# Sinais
signal drag_started(item)
signal drag_ended(item)
signal dropped_in_zone(item, zone)

# Variáveis
var is_dragging: bool = false
var original_position: Vector2
var drag_offset: Vector2
var can_drag: bool = true

# Referência ao DropZone (será definida pelo DragDropChallenge)
var drop_zone_ref: Node

func _ready():
	# Conectar sinais da área
	area_entered.connect(_on_area_entered)
	
	# Configurar camadas de colisão
	collision_layer = 1
	collision_mask = 2

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and can_drag:
			start_drag(event.position)
		elif not event.pressed and is_dragging:
			end_drag()

func _process(_delta):
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		global_position = mouse_pos - drag_offset

func start_drag(mouse_pos: Vector2):
	if not can_drag:
		return
	
	is_dragging = true
	original_position = global_position
	drag_offset = mouse_pos - global_position
	drag_started.emit(self)
	
	# Trazer para frente
	z_index = 10

func end_drag():
	if not is_dragging:
		return
	
	is_dragging = false
	z_index = 0
	
	# Verificar se está sobre uma DropZone
	var overlapping_areas = get_overlapping_areas()
	var valid_zone = null
	
	for area in overlapping_areas:
		if area.has_method("is_drop_zone"):  # Verifica se é uma DropZone
			valid_zone = area
			break
	
	if valid_zone:
		# Item foi dropado em uma zona válida
		dropped_in_zone.emit(self, valid_zone)
		global_position = valid_zone.global_position
		can_drag = false  # Trava o item na posição
	else:
		# Retorna à posição original
		global_position = original_position
	
	drag_ended.emit(self)

func _on_area_entered(area):
	# Esta função é chamada quando o item entra em uma área
	# A lógica principal está no end_drag()
	pass

func reset():
	global_position = original_position
	can_drag = true
	z_index = 0
=======
extends Control

@export var id: String = ""
@export var id_area_soltura_correta: String = ""
@export var velocidade_arrasto: float = 2000.0

signal item_soltado(id_item_arrastavel, id_area_soltada, correto, no_item_arrastavel)

# Já não precisa mais da Area2D separada
var _arrastando: bool = false
var _offset_arrasto: Vector2
var _pai_original: Node
var _posicao_original_no_pai: Vector2
var _travado: bool = false

func _ready():
	_pai_original = get_parent()
	_posicao_original_no_pai = position
	
	# Configurar para ser arrastável
	mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(evento):
	if _travado: 
		return
	
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed:
			# Iniciar arrasto
			_arrastando = true
			_offset_arrasto = get_global_mouse_position() - global_position
			# Mover para a raiz para ficar acima de tudo
			get_parent().remove_child(self)
			get_tree().root.add_child(self)
			z_index = 1000  # Garantir que fique por cima
		elif not evento.pressed and _arrastando:
			# Finalizar arrasto
			_arrastando = false
			_verificar_local_soltura()
		
	if evento is InputEventMouseMotion and _arrastando:
		# Atualizar posição durante o arrasto
		global_position = get_global_mouse_position() - _offset_arrasto

func _verificar_local_soltura():
	var posicao_soltura = get_global_mouse_position()
	var id_area_soltada = ""
	var colocacao_correta = false
	var zona_soltura_encontrada: DropZone = null
	
	# Buscar todas as zonas de soltura na cena
	var zonas_soltura = _buscar_todas_zonas_soltura()
	
	for zona in zonas_soltura:
		if zona.ponto_esta_dentro(posicao_soltura):
			zona_soltura_encontrada = zona
			id_area_soltada = zona.id
			break
	
	if id_area_soltada:
		colocacao_correta = (id_area_soltada == id_area_soltura_correta)
		
		item_soltado.emit(id, id_area_soltada, colocacao_correta, self)
		
		if colocacao_correta:
			travar_em_posicao(zona_soltura_encontrada.global_position)
		else:
			retornar_para_posicao_original()
	else:
		# Soltou em lugar nenhum
		item_soltado.emit(id, "", false, self)
		retornar_para_posicao_original()

func _buscar_todas_zonas_soltura() -> Array:
	var zonas: Array = []
	
	# Buscar recursivamente por DropZones na cena atual
	_buscar_zonas_recursivamente(get_tree().current_scene, zonas)
	
	return zonas

func _buscar_zonas_recursivamente(no: Node, resultado: Array):
	if no is DropZone:
		resultado.append(no)
	
	for filho in no.get_children():
		_buscar_zonas_recursivamente(filho, resultado)

func retornar_para_posicao_original():
	# Voltar para o pai original
	get_tree().root.remove_child(self)
	_pai_original.add_child(self)
	position = _posicao_original_no_pai
	z_index = 0

func travar_em_posicao(posicao_global_alvo: Vector2):
	get_tree().root.remove_child(self)
	_pai_original.add_child(self)

	# Calcular posição local relativa ao pai original
	position = _pai_original.to_local(posicao_global_alvo) - (size / 2)

	_travado = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Feedback visual de sucesso
	modulate = Color(0.5, 1, 0.5)  # Verde claro
>>>>>>> 150a55f936c4293772a0d280049a81d8b0491a13
