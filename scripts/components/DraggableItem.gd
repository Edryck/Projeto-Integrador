# DraggableItem.gd
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
