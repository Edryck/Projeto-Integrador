# MainMenu.gd
extends Control

var play_button: Button
var options_button: Button
var quit_button: Button

func _ready():
	play_button = find_child("PlayButton", true, false)
	options_button = find_child("OptionsButton", true, false)
	quit_button = find_child("QuitButton", true, false)
	
	# Conecta os sinais dos botões às funções. Você pode fazer isso pelo editor também.
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
