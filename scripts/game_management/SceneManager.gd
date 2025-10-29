# SceneManager.gd 
extends Node

# Dados temporários para passar entre cenas
var dados_desafio_temp: Dictionary = {}
var dados_fase_temp: Dictionary = {}
var desafios_da_fase: Array = []
var desafio_atual_index: int = 0
var id_fase_temp: String = ""

func _ready():
	print("SCENE MANAGER - Inicializado")

# Getter para o ID da fase
func get_id_fase_temp() -> String:
	return id_fase_temp

# Preparar uma fase completa
func preparar_fase(dados_fase: Dictionary, id_fase: String):
	dados_fase_temp = dados_fase.duplicate(true)
	desafios_da_fase = dados_fase["challenges"].duplicate(true)
	desafio_atual_index = 0
	id_fase_temp = id_fase
	
	print("SceneManager: Fase preparada")
	print("   - ID Fase: ", id_fase)
	print("   - Título: ", dados_fase.get("title", "Sem título"))
	print("   - Total desafios: ", desafios_da_fase.size())
	
	# Mostrar resumo dos desafios
	for i in range(desafios_da_fase.size()):
		var desafio = desafios_da_fase[i]
		print("      ", i + 1, ". ", desafio.get("type", "?"), " - ", desafio.get("id", "?"))

# Obter o próximo desafio sem avançar o índice
func obter_proximo_desafio() -> Dictionary:
	if desafio_atual_index >= desafios_da_fase.size():
		print("SceneManager: Todos os desafios foram concluídos")
		return {}
	
	var desafio = desafios_da_fase[desafio_atual_index]
	print("SceneManager: Entregando desafio ", desafio_atual_index + 1, " de ", desafios_da_fase.size())
	print("   - Tipo: ", desafio.get("type", "desconhecido"))
	print("   - ID: ", desafio.get("id", "sem_id"))
	
	return desafio

# Avançar para o próximo desafio (incrementar índice)
func avancar_para_proximo_desafio():
	desafio_atual_index += 1
	print("SceneManager: Avançando índice para ", desafio_atual_index, " de ", desafios_da_fase.size())
	
	if desafio_atual_index < desafios_da_fase.size():
		print("   - Próximo desafio: ", desafios_da_fase[desafio_atual_index].get("id", "?"))
	else:
		print("   - Não há mais desafios")
		

# Verificar se ainda tem desafios
func tem_mais_desafios() -> bool:
	var tem_mais = desafio_atual_index < desafios_da_fase.size()
	print("SceneManager: tem_mais_desafios? ", tem_mais, " (", desafio_atual_index, "/", desafios_da_fase.size(), ")")
	return tem_mais

# Limpar todos os dados temporários
func limpar_dados():
	print("SceneManager: Limpando dados")
	print("   - Fase: ", id_fase_temp)
	print("   - Desafios completados: ", desafio_atual_index, "/", desafios_da_fase.size())
	
	dados_desafio_temp = {}
	dados_fase_temp = {}
	desafios_da_fase = []
	desafio_atual_index = 0
	id_fase_temp = ""
	
	print("SceneManager: Dados limpos com sucesso")

# Obter dados do desafio atual preparado
func obter_dados_desafio_atual() -> Dictionary:
	if dados_desafio_temp.is_empty():
		print("SceneManager: AVISO - Nenhum dado de desafio preparado!")
	else:
		print("SceneManager: Retornando dados do desafio")
		print("   - ID: ", dados_desafio_temp.get("id", "sem_id"))
		print("   - Tipo: ", dados_desafio_temp.get("type", "desconhecido"))
	
	return dados_desafio_temp

# Preparar dados de um desafio específico
func preparar_desafio_especifico(dados: Dictionary):
	dados_desafio_temp = dados.duplicate(true)
	
	print("SceneManager: Desafio específico preparado")
	print("   - ID: ", dados.get("id", "sem_id"))
	print("   - Tipo: ", dados.get("type", "desconhecido"))
	print("   - Título: ", dados.get("title", "Sem título"))
	
	# Verificar integridade dos dados baseado no tipo
	var tipo = dados.get("type", "")
	match tipo:
		"quiz":
			if dados.has("questions"):
				print("   - Questões: ", dados["questions"].size())
			else:
				print("   - AVISO: Nenhuma questão encontrada!")
		
		"relate":
			if dados.has("items_left_column") and dados.has("items_right_column"):
				print("   - Itens esquerda: ", dados["items_left_column"].size())
				print("   - Itens direita: ", dados["items_right_column"].size())
				print("   - Conexões corretas: ", dados.get("correct_connections", []).size())
			else:
				print("   - AVISO: Dados de relate incompletos!")
		
		"dragdrop":
			if dados.has("draggable_items") and dados.has("drop_zones"):
				print("   - Itens arrastáveis: ", dados["draggable_items"].size())
				print("   - Zonas de soltura: ", dados["drop_zones"].size())
			else:
				print("   - AVISO: Dados de dragdrop incompletos!")

# Obter informações sobre o progresso atual
func obter_info_progresso() -> Dictionary:
	return {
		"fase_id": id_fase_temp,
		"fase_titulo": dados_fase_temp.get("title", ""),
		"desafio_atual": desafio_atual_index + 1,
		"total_desafios": desafios_da_fase.size(),
		"percentual": float(desafio_atual_index) / desafios_da_fase.size() * 100 if desafios_da_fase.size() > 0 else 0
	}

# Debug: Imprimir estado atual completo
func debug_print_estado():
	print("\n=== ESTADO DO SCENE MANAGER ===")
	print("Fase ID: ", id_fase_temp)
	print("Fase Título: ", dados_fase_temp.get("title", "N/A"))
	print("Desafio Atual: ", desafio_atual_index + 1, "/", desafios_da_fase.size())
	print("Tem mais desafios: ", tem_mais_desafios())
	print("Dados temp preparados: ", not dados_desafio_temp.is_empty())
	if not dados_desafio_temp.is_empty():
		print("   - ID: ", dados_desafio_temp.get("id", "?"))
		print("   - Tipo: ", dados_desafio_temp.get("type", "?"))
	print("===============================\n")
