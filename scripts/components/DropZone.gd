# DropZone.gd
extends Area2D

signal item_dropped(item, drop_zone)

func _ready():
	# Configurar a área de drop
	collision_layer = 2
	collision_mask = 1

func _on_area_entered(area):
	if area.is_class("DraggableItem"):
		item_dropped.emit(area, self)
