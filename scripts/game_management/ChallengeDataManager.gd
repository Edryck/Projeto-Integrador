# ChallengeDataManager.gd
extends Node

var fases_data: Dictionary
var quiz_data: Dictionary
var relate_data: Dictionary
var dragdrop_data: Dictionary

func _ready(): 
	# Na versão final, seria carregado os JSONs aqui
	# Por enquanto, vamos simular com os dados direto no script
	fases_data = carregar_json("res://data/levels/fases.json")
	quiz_data = carregar_json("res://data/levels/quiz.json")
	relate_data = carregar_json("res://data/levels/relate.json")
	dragdrop_data = carregar_json("res://data/levels/dragdrop.json")

# Função para carregar e parsear um arquivo JSON
func carregar_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Erro: Arquivo não encontrado: ", path)
		return {}
		
	var content = file.get_as_text()
	file.close()
	
	print("Carregando: ", path)
	print("Conteúdo: ", content.substr(0, 200), "...")  # Mostra os primeiros 200 chars
	
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		print("ERRO no JSON ", path, " - Linha ", json.get_error_line(), ": ", json.get_error_message())
		return {}
		
	return json.get_data()

# Função principal, ela monta a lista completa de desafios para uma nova fase específica.
func get_challenges_for_phase(phase_id: String) -> Array:
	print("Buscando desafios para fase: ", phase_id)
	
	if not fases_data.has(phase_id):
		print("Fase não encontrada: ", phase_id)
		return []
	
	var phase_info = fases_data[phase_id]
	var challenge_pointers = phase_info["challenges"]
	var full_challenge_list = []
	
	print("Pointers encontrados: ", challenge_pointers)
	
	for pointer in challenge_pointers:
		var challenge_type = pointer["type"]
		var challenge_id = pointer["id"]
		var challenge_data = {}
		
		print("Processando: tipo=", challenge_type, ", id=", challenge_id)
		
		match challenge_type:
			"quiz":
				if quiz_data.has(challenge_id):
					challenge_data = quiz_data[challenge_id].duplicate(true)
					print("Dados do quiz carregados: ", challenge_data)
			"relate":
				if relate_data.has(challenge_id):
					challenge_data = relate_data[challenge_id].duplicate(true)
			"dragdrop":
				# Tenta carregar dragdrop, mas não quebra se falhar
				if dragdrop_data.has(challenge_id):
					challenge_data = dragdrop_data[challenge_id].duplicate(true)
				else:
					print("AVISO: Dados de dragdrop não encontrados, usando quiz como fallback")
					challenge_type = "quiz"  # Fallback para quiz
					if quiz_data.has(challenge_id):
						challenge_data = quiz_data[challenge_id].duplicate(true)
		
		if not challenge_data.is_empty():
			challenge_data["type"] = challenge_type
			challenge_data["id"] = challenge_id
			full_challenge_list.append(challenge_data)
			print("Desafio adicionado: ", challenge_id)
		else:
			print("AVISO: Desafio não encontrado, pulando: ", challenge_id)
	
	print("Total de desafios carregados: ", full_challenge_list.size())
	return full_challenge_list
