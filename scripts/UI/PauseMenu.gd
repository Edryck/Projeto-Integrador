# PauseMenu.gd
extends CanvasLayer

# Sinais que este menu vai emitir para que o GameManager saiba o que fazer.
signal resume_game
signal restart_phase
signal quit_to_map

func _ready():
	# Conecta os botões locais às suas funções
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_button_pressed)
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_button_pressed)
	$VBoxContainer/QuitToMapButton.pressed.connect(_on_quit_to_map_button_pressed)

func _on_resume_button_pressed():
	# Despausa o jogo e se remove da tela
	get_tree().paused = false
	resume_game.emit() # Avisa que o jogo continuou
	queue_free()

func _on_restart_button_pressed():
	# Primeiro despausa para evitar problemas
	get_tree().paused = false
	restart_phase.emit() # Avisa que o jogador quer recomeçar
	queue_free()

func _on_quit_to_map_button_pressed():
	get_tree().paused = false
	quit_to_map.emit() # Avisa que o jogador quer sair
	queue_free()

# Permite fechar o menu de pause com a tecla Esc também
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): # ui_cancel é a tecla Esc por padrão
		_on_resume_button_pressed()
