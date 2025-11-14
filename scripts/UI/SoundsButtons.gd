extends Node
class_name SoundsButtons

@export var button_sound : AudioStream
@onready var audio_player := AudioStreamPlayer.new()

var target: Control

func setup() -> void:
	target.mouse_entered.connect(_on_mouse_over)
	
	if button_sound:
		audio_player.stream = button_sound
		add_child(audio_player)
		
func _on_mouse_over() -> void:
	if button_sound:
		audio_player.play()
