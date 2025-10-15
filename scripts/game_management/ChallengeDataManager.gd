# ChallengeDataManager.gd
extends Node

var fases_data: Dictionary
var quiz_data: Dictionary
var relate_data: Dictionary
var dragdrop_data: Dictionary

func _ready():
	fases_data = _carregar_json("res://data/levels/fases.json")
	quiz_data = _carregar_json("res://data/levels/quiz.json")
	relate_data = _carregar_json("res://data/levels/relate.json")
	dragdrop_data = _carregar_json("res://data/levels/dragdrop.json")

<<<<<<< HEAD
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
=======
func _carregar_json(caminho: String) -> Dictionary:
	var arquivo = FileAccess.open(caminho, FileAccess.READ)
	if arquivo == null:
		print("Erro: Arquivo não encontrado: ", caminho)
		return {}
	
	var conteudo = arquivo.get_as_text()
	arquivo.close()
	
	var json = JSON.new()
	var erro = json.parse(conteudo)
	if erro != OK:
		print("ERRO no JSON ", caminho, " - Linha ", json.get_error_line(), ": ", json.get_error_message())
		return {}
	
	return json.get_data()

func get_challenges_for_phase(id_fase: String) -> Array:
	print("Buscando desafios para fase: ", id_fase)
	
	if not fases_data.has(id_fase):
		print("Fase não encontrada: ", id_fase)
>>>>>>> 9bd3b91e70dc7065013bfc314b91e94c4e59cf4d
		return []
	
	var info_fase = fases_data[id_fase]
	var ponteiros_desafios = info_fase["challenges"]
	var lista_desafios_completa = []
	
<<<<<<< HEAD
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
=======
	print("Pointers encontrados: ", ponteiros_desafios)
	
	for ponteiro in ponteiros_desafios:
		var tipo_desafio = ponteiro["type"]
		var id_desafio = ponteiro["id"]
		var dados_desafio = {}
		
		print("Processando: tipo=", tipo_desafio, ", id=", id_desafio)
		
		match tipo_desafio:
			"quiz":
				if quiz_data.has(id_desafio):
					dados_desafio = quiz_data[id_desafio].duplicate(true)
>>>>>>> 9bd3b91e70dc7065013bfc314b91e94c4e59cf4d
			"relate":
				if relate_data.has(id_desafio):
					dados_desafio = relate_data[id_desafio].duplicate(true)
			"dragdrop":
<<<<<<< HEAD
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
=======
				if dragdrop_data.has(id_desafio):
					dados_desafio = dragdrop_data[id_desafio].duplicate(true)
				else:
					print("AVISO: Dados de dragdrop não encontrados, usando quiz como fallback")
					tipo_desafio = "quiz"
					if quiz_data.has(id_desafio):
						dados_desafio = quiz_data[id_desafio].duplicate(true)
		
		if not dados_desafio.is_empty():
			dados_desafio["type"] = tipo_desafio
			dados_desafio["id"] = id_desafio
			lista_desafios_completa.append(dados_desafio)
			print("Desafio adicionado: ", id_desafio)
		else:
			print("AVISO: Desafio não encontrado, pulando: ", id_desafio)
	
	print("Total de desafios carregados: ", lista_desafios_completa.size())
	return lista_desafios_completa
>>>>>>> 9bd3b91e70dc7065013bfc314b91e94c4e59cf4d
