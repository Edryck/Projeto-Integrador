# MainMenu.gd
extends Control

@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton

func _ready():
	# Conecta os sinais dos botões às funções.
	play_button.pressed.connect(_on_play_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed():
	# Muda para a cena de seleção de aluno.
	get_tree().change_scene_to_file("res://scenes/UI/StudentSelection.tscn")

func _on_options_button_pressed():
	print("Tela de Opções ainda não implementada.")
	# get_tree().change_scene_to_file("res://scenes/menus/Options.tscn")

func _on_quit_button_pressed():
	# Fecha o jogo.
	get_tree().quit()
