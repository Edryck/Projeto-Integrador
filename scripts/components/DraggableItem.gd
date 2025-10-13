# DraggableItem.gd
extends Control

@export var id: String = ""
@export var correct_drop_area_id: String = "" # ID da área de drop correta
@export var drag_speed: float = 2000.0 # Velocidade de retorno, se for o caso

signal item_dropped(drag_item_id, dropped_on_area_id, is_correct, drag_item_node)

var drag_area: Area2D # Referência ao Drag Area
var visuals: Control
var image_node: TextureRect # Assumindo que Image está dentro de DragArea
var text_node: Label # Assumindo que Text está dentro de DragArea


var _is_dragging: bool = false
var _drag_offset: Vector2 # Diferença entre o clique e o canto do item
var _original_parent: Node
var _original_position_in_parent: Vector2
var _is_locked: bool = false # Nova flag para controlar se o item pode ser arrastado

func _ready():
	drag_area = find_child("DragArea", true, false)
	visuals = find_child("Visuals", true, false)
	image_node = find_child("Image", true, false)
	text_node = find_child("Text", true, false)
	# Cache a posição original e o pai
	_original_parent = get_parent()
	_original_position_in_parent = position

func _gui_input(event: InputEvent):
	if _is_locked: return # Se o item está travado (já colocado corretamente), ignora input
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_dragging = true
			_drag_offset = get_global_mouse_position() - global_position
			reparent(get_tree().root)
		elif not event.pressed and _is_dragging:
			_is_dragging = false
			_check_drop_location()
		
	if event is InputEventMouseMotion and _is_dragging:
		global_position = event.position - _drag_offset

func _check_drop_location():
	var dropped_on_area_id = ""
	var is_correct_placement = false
	var drop_zone_node: DropZone = null
	
	# Usa o Area2D para verificar sobreposição com DropZones
	for detected_area in drag_area.get_overlapping_areas():
		# Verifica se o PAI da área detectada tem o script DropZone.gd
		if detected_area.get_parent() is DropZone: 
			# CORREÇÃO: Pegamos o pai da área, que é o nó que queremos.
			drop_zone_node = detected_area.get_parent() as DropZone
			dropped_on_area_id = drop_zone_node.id
			break
	
	if dropped_on_area_id:
		is_correct_placement = (dropped_on_area_id == correct_drop_area_id)
		item_dropped.emit(id, dropped_on_area_id, is_correct_placement, self)

		if drop_zone_node:
			is_correct_placement = (dropped_on_area_id == correct_drop_area_id)
			item_dropped.emit(id, dropped_on_area_id, is_correct_placement, self)
		
			if is_correct_placement:
				# Centraliza a lógica de "travar no lugar" usando a função lock_in_place
				lock_in_place(drop_zone_node.global_position)
			else:
				return_to_original_position()
	else:
		item_dropped.emit(id, "", false, self)
		return_to_original_position()

func return_to_original_position():
	# Remover da cena raiz
	get_tree().root.remove_child(self)
	# Adicionar de volta ao pai original na posição original
	_original_parent.add_child(self)
	position = _original_position_in_parent
	# Pode adicionar uma animação aqui (Tween)

# Método para travar o item no lugar (útil se o DragDropChallenge quiser fazer isso)
func lock_in_place(target_global_position: Vector2):
	get_tree().root.remove_child(self)
	_original_parent.add_child(self) # Adiciona de volta ao pai original para manter a hierarquia

	# Calcular a posição local dentro do PARENT ORIGINAL
	position = _original_parent.to_local(target_global_position - size / 2)

	_is_locked = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
