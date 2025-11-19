# SceneManager.gd 
extends Node

# Caminhos
const caminho_cena_recompensa = "res://scenes/UI/RewardScreen.tscn"

# Dados temporários para passar entre cenas
var dados_desafio_temp: Dictionary = {}
var dados_fase_temp: Dictionary = {}
var desafios_da_fase: Array = []
var desafio_atual_index: int = 0
var id_fase_temp: String = ""

# Novo: camada para modais/rewards, criada no _ready
var overlay_layer: Control = null

func _ready():
	print("SCENE MANAGER - Inicializado")
	# Procura ou cria OverlayLayer para modais e RewardScreen
	overlay_layer = get_tree().root.get_node_or_null("OverlayLayer")
	if not overlay_layer:
		overlay_layer = Control.new()
		overlay_layer.name = "OverlayLayer"
		overlay_layer.z_index = 1000
		get_tree().root.add_child(overlay_layer)
	# Opcional: bloquear input quando overlay for mostrado
	overlay_layer.mouse_filter = Control.MOUSE_FILTER_STOP

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

func carregar_proximo_desafio():
	var desafio = obter_proximo_desafio() # Retorna { "type": "quiz", "id": "mat_1" }
	
	if desafio.is_empty():
		printerr("SceneManager: Tentativa de carregar desafio, mas a lista está vazia.")
		return
	
	var id_desafio = desafio.get("id", "")
	var tipo_desafio = desafio.get("type", "")
	var dados_completos = GameManager.instance.obter_conteudo_desafio(id_desafio, tipo_desafio) 
	
	if dados_completos.is_empty():
		printerr("SceneManager: Conteúdo do desafio (", id_desafio, ") não encontrado!")
		return
	
	dados_completos["id"] = id_desafio
	dados_completos["type"] = tipo_desafio
	
	preparar_desafio_especifico(dados_completos)
	
	var caminho_cena = ""
	# Mapear o tipo de desafio para o arquivo .tscn correspondente
	match tipo_desafio:
		"quiz":
			caminho_cena = "res://scenes/challenges/QuizChallenge.tscn"
		"relate":
			caminho_cena = "res://scenes/challenges/RelateChallenge.tscn"
		"dragdrop":
			caminho_cena = "res://scenes/challenges/DragDropChallenge.tscn"
		# Adicione outros tipos aqui
		_:
			printerr("SceneManager: Tipo de desafio desconhecido: ", tipo_desafio)
			return

	# Preparar os dados para que a próxima cena possa usá-los (usando obter_dados_desafio_atual)
	preparar_desafio_especifico(dados_completos)
	
	print("SceneManager: Carregando próximo desafio (", tipo_desafio, ") em ", caminho_cena)
	get_tree().change_scene_to_file(caminho_cena)

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

# Centralizador: exibe a RewardScreen ao receber o sinal de qualquer desafio
func exibir_reward_screen(sucesso: bool, pontuacao: int, dados: Dictionary) -> void:
	print("SceneManager: Exibindo RewardScreen modal...")
	
	var cena_recompensa = load(caminho_cena_recompensa)
	if cena_recompensa:
		var instancia_cena = cena_recompensa.instantiate()
		# Adiciona sobre a cena atual
		get_tree().get_root().add_child(instancia_cena)
		
		# Configura sobre a tela de recompensa
		instancia_cena.mostrar_resultado(sucesso, pontuacao, dados)
		while is_instance_valid(instancia_cena) and instancia_cena.is_inside_tree():
			await get_tree().process_frame
		continuar_fluxo_apos_reward()
	else:
		# Se a cena não for encontrada, pula ela e continua o fluxo
		printerr("Tela de Recompensa não foi encontrada!\n
		Continuando fluxo.")
		continuar_fluxo_apos_reward()

# Centralizar o fluxo pós-recompensa (após RewardScreen ser fechada)
# Esta função só é chamada quando a fase está completa (sem mais desafios)
func continuar_fluxo_apos_reward():
	print("Fase completa! Registrando conclusão...")
	var fase_id = get_id_fase_temp()
	if fase_id:
		GameManager.completar_fase(fase_id)
	limpar_dados()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
