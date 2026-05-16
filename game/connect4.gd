extends Node2D

@onready var peca_vermelha = "res://Assets/peca_vermelha.png"
@onready var peca_amarela = "res://Assets/peca_amarela.png"
@onready var peca_amarela_mesa = "res://Assets/peca_amarela_mesa.png"
@onready var peca_vermelha_mesa = "res://Assets/peca_vermelha_mesa.png"
@onready var animacao_vitoria_vermelho = "vitoria_vermelho"
@onready var animacao_vitoria_amarelo = "vitoria_amarelo"
@onready var colunas = $Tabuleiro/Colunas
@onready var espacos = $Tabuleiro/Espacos
@onready var pecas = $Pecas
@onready var opcoes_jogo = $Interface/OpcoesJogo
@onready var botao_dificuldade = $Interface/BotaoDificuldade
@onready var info_jogo = $Interface/InfoJogo
@onready var pecas_arrastaveis = $PecasArrastaveis

var peca_cena = preload("res://peca.tscn")
var peca_arrastavel_cena = preload("res://peca_arrastavel.tscn")
var tabuleiro_jogo: Tabuleiro
var aguardar_jogada_IA = false
var thread_IA: Thread = Thread.new()
var mutex: Mutex = Mutex.new()
var semaphore: Semaphore = Semaphore.new()
var ia: Minimax = Minimax.new()

var reiniciando_jogo = false
var marcando_vitoria = false
var profundidade_maxima: int = 2
var tipo_jogador_amarelo_atual: Jogador.TipoJogador = Jogador.TipoJogador.Humano
var tipo_jogador_vermelho_atual: Jogador.TipoJogador = Jogador.TipoJogador.Humano

func _ready():
	botao_dificuldade.connect("pressed", _on_dificuldade_pressed)
	for opcao_jogo in opcoes_jogo.get_children():
		opcao_jogo.connect("pressed", _on_opcoes_jogo_pressed.bind(opcao_jogo.name))

	call_deferred("iniciar_jogo")

func _on_dificuldade_pressed() -> void:
	match botao_dificuldade.dificuldade:
		Dificuldade.SeletorDificuldade.Facil:
			profundidade_maxima = 2
		Dificuldade.SeletorDificuldade.Medio:
			profundidade_maxima = 3
		Dificuldade.SeletorDificuldade.Dificil:
			profundidade_maxima = 4

	await reiniciar_jogo()

func _on_opcoes_jogo_pressed(nome_opcao: String) -> void:
	opcoes_jogo.tocar_som_botao_opcao()
	
	match nome_opcao:
		"JogadorContraJogador":
			print("Jogador vs Jogador")
			tipo_jogador_amarelo_atual = Jogador.TipoJogador.Humano
			tipo_jogador_vermelho_atual = Jogador.TipoJogador.Humano
			await reiniciar_jogo()
		"JogadorContraIA":
			print("Jogador vs IA")
			tipo_jogador_amarelo_atual = Jogador.TipoJogador.Humano
			tipo_jogador_vermelho_atual = Jogador.TipoJogador.Computador
			await reiniciar_jogo()
		"IAContraJogador":
			print("IA vs Jogador")
			tipo_jogador_amarelo_atual = Jogador.TipoJogador.Computador
			tipo_jogador_vermelho_atual = Jogador.TipoJogador.Humano
			await reiniciar_jogo()
		"IAContraIA":
			print("IA vs IA")
			tipo_jogador_amarelo_atual = Jogador.TipoJogador.Computador
			tipo_jogador_vermelho_atual = Jogador.TipoJogador.Computador
			await reiniciar_jogo()

func iniciar_jogo() -> void:
	for i in range(21):
		var peca_arrastavel = peca_arrastavel_cena.instantiate()
		peca_arrastavel.cor_jogador = Jogador.Cor.Amarelo
		peca_arrastavel.global_position = Vector2(-500, 475 + i * 5)
		peca_arrastavel.mudar_textura_jogador(peca_amarela_mesa)
		peca_arrastavel.jogada_na_coluna.connect(jogar_na_posicao_arrastando)
		
		pecas_arrastaveis.add_child(peca_arrastavel)
	for i in range(21):
		var peca_arrastavel = peca_arrastavel_cena.instantiate()
		peca_arrastavel.cor_jogador = Jogador.Cor.Vermelho
		peca_arrastavel.global_position = Vector2(1750, 475 + i * 5)
		peca_arrastavel.mudar_textura_jogador(peca_vermelha_mesa)
		peca_arrastavel.jogada_na_coluna.connect(jogar_na_posicao_arrastando)
		
		pecas_arrastaveis.add_child(peca_arrastavel)

	await reiniciar_jogo()

func reiniciar_jogo() -> void:
	if reiniciando_jogo || marcando_vitoria:
		return
	
	reiniciando_jogo = true
	
	desabilitar_colunas()

	Global2D.cancelar_IA = true
	aguardar_jogada_IA = true
	if thread_IA.is_started():
		semaphore.post()
		thread_IA.wait_to_finish()
	
	await reiniciar_pecas()
	for espaco in espacos.get_children():
		espaco.ocupado = false
	
	tabuleiro_jogo = Tabuleiro.new()
	tabuleiro_jogo.jogador_amarelo.tipo_jogador = tipo_jogador_amarelo_atual
	tabuleiro_jogo.jogador_vermelho.tipo_jogador = tipo_jogador_vermelho_atual
	info_jogo.text = "Jogador: " + Jogador.Cor.keys()[tabuleiro_jogo.jogador_atual.cor]

	Global2D.cancelar_IA = false
	aguardar_jogada_IA = false
	thread_IA.start(iniciar_jogada_IA)
	
	if tabuleiro_jogo.jogador_atual.tipo_jogador == Jogador.TipoJogador.Computador:
		semaphore.post()

	habilitar_colunas()
	
	reiniciando_jogo = false

func reiniciar_pecas() -> void:
	for peca_arrastavel in pecas_arrastaveis.get_children():
		destruir_peca_arrastavel(peca_arrastavel)
	for peca in pecas.get_children():
		peca.destruir_peca()
	
	var pecas_destruidas = []
	pecas_destruidas.append_array(pecas_arrastaveis.get_children())
	pecas_destruidas.append_array(pecas.get_children())
	for peca in pecas_destruidas:
		await peca.peca_destruida
		
	for peca_arrastavel in pecas_arrastaveis.get_children():
		construir_peca_arrastavel(peca_arrastavel)
	for peca_arrastavel in pecas_arrastaveis.get_children():
		await peca_arrastavel.peca_construida

func construir_peca_arrastavel(peca_arrastavel):
	var posicao_x = randi_range(25, 225) if peca_arrastavel.cor_jogador == Jogador.Cor.Amarelo else randi_range(925, 1125)
	peca_arrastavel.construir_peca_arrastavel(Vector2(posicao_x, peca_arrastavel.global_position.y))

func destruir_peca_arrastavel(peca_arrastavel):
	var posicao_x = -500 if peca_arrastavel.cor_jogador == Jogador.Cor.Amarelo else 1750
	peca_arrastavel.destruir_peca_arrastavel(Vector2(posicao_x, peca_arrastavel.global_position.y))

func desabilitar_colunas():
	if $Tabuleiro/Colunas/AreaColuna_0.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_0.coluna_selecionada.disconnect(jogar_na_posicao)
	if $Tabuleiro/Colunas/AreaColuna_1.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_1.coluna_selecionada.disconnect(jogar_na_posicao)
	if $Tabuleiro/Colunas/AreaColuna_2.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_2.coluna_selecionada.disconnect(jogar_na_posicao)
	if $Tabuleiro/Colunas/AreaColuna_3.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_3.coluna_selecionada.disconnect(jogar_na_posicao)
	if $Tabuleiro/Colunas/AreaColuna_4.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_4.coluna_selecionada.disconnect(jogar_na_posicao)
	if $Tabuleiro/Colunas/AreaColuna_5.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_5.coluna_selecionada.disconnect(jogar_na_posicao)
	if $Tabuleiro/Colunas/AreaColuna_6.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_6.coluna_selecionada.disconnect(jogar_na_posicao)
		
	for peca_arrastavel in $PecasArrastaveis.get_children():
		if peca_arrastavel.is_connected("jogada_na_coluna", jogar_na_posicao_arrastando):
			peca_arrastavel.jogada_na_coluna.disconnect(jogar_na_posicao_arrastando)

func habilitar_colunas():
	if not $Tabuleiro/Colunas/AreaColuna_0.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_0.coluna_selecionada.connect(jogar_na_posicao)
	if not $Tabuleiro/Colunas/AreaColuna_1.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_1.coluna_selecionada.connect(jogar_na_posicao)
	if not $Tabuleiro/Colunas/AreaColuna_2.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_2.coluna_selecionada.connect(jogar_na_posicao)
	if not $Tabuleiro/Colunas/AreaColuna_3.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_3.coluna_selecionada.connect(jogar_na_posicao)
	if not $Tabuleiro/Colunas/AreaColuna_4.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_4.coluna_selecionada.connect(jogar_na_posicao)
	if not $Tabuleiro/Colunas/AreaColuna_5.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_5.coluna_selecionada.connect(jogar_na_posicao)
	if not $Tabuleiro/Colunas/AreaColuna_6.is_connected("coluna_selecionada", jogar_na_posicao):
		$Tabuleiro/Colunas/AreaColuna_6.coluna_selecionada.connect(jogar_na_posicao)
		
	for peca_arrastavel in $PecasArrastaveis.get_children():
		if not peca_arrastavel.is_connected("jogada_na_coluna", jogar_na_posicao_arrastando):
			peca_arrastavel.jogada_na_coluna.connect(jogar_na_posicao_arrastando)

func mostrar_tabuleiro_CLI() -> void:
	print("Tabuleiro:")
	for linha in range(6):
		var linha_str = ""
		for coluna in range(7):
			var cor = tabuleiro_jogo.tabuleiro[linha][coluna]
			if cor == Jogador.Cor.Nenhum:
				linha_str += ". "
			elif cor == Jogador.Cor.Amarelo:
				linha_str += "A "
			else:
				linha_str += "V "
		print(linha_str)
	print("-------------\n")

func iniciar_jogada_IA():
	while true:
		semaphore.wait()
		if Global2D.cancelar_IA:
			break

		if not tabuleiro_jogo.estado_terminal()\
			and tabuleiro_jogo.jogador_atual.tipo_jogador == Jogador.TipoJogador.Computador:
			mutex.lock()
			aguardar_jogada_IA = true
			mutex.unlock()

			var jogador = tabuleiro_jogo.jogador_atual
			var jogada = ia.jogar(tabuleiro_jogo.duplicate(true), jogador, profundidade_maxima)

			if not Global2D.cancelar_IA:
				call_deferred("finalizar_jogada_IA", jogada)

func finalizar_jogada_IA(jogada: Jogada):
	desabilitar_colunas()

	var linha = jogada.movimento[0]
	var coluna = jogada.movimento[1]
	
	if Global2D.cancelar_IA:
		return
		
	aguardar_jogada_IA = false
	await jogar_na_posicao(coluna, linha)

func jogar_na_posicao_arrastando(peca_arrastavel, coluna):
	if not peca_arrastavel.cor_jogador == tabuleiro_jogo.jogador_atual.cor:
		print("Peça inválida!")
		return
	elif aguardar_jogada_IA:
		return
	else:
		destruir_peca_arrastavel(peca_arrastavel)

		await jogar_na_posicao(coluna, null, false)

func jogar_na_posicao(coluna, linha = null, limpar_peca_arrastavel = true):
	desabilitar_colunas()
	
	if not tabuleiro_jogo.estado_terminal() and not aguardar_jogada_IA:
		var jogador = tabuleiro_jogo.jogador_atual
		print("Vez do jogador: ", Jogador.Cor.keys()[jogador.cor])
		
		var espaco_disponivel = pegar_espaco_disponivel(coluna, linha)
		if espaco_disponivel == null:
			print("Coluna cheia!")
			aguardar_jogada_IA = false
			habilitar_colunas()
			return
		
		var peca = peca_cena.instantiate()
		var cor_peca = peca_amarela if jogador.cor == Jogador.Cor.Amarelo else peca_vermelha
		peca.mudar_textura_jogador(cor_peca)
		pecas.add_child(peca)
	
		peca.global_position = Vector2(espaco_disponivel.global_position.x, 75)
		espaco_disponivel.ocupado = true
		await peca.jogar_peca(espaco_disponivel.global_position)
		
		if limpar_peca_arrastavel:
			var arrastaveis = pecas_arrastaveis.get_children()
			arrastaveis.shuffle()
			var peca_arrastavel = arrastaveis.filter(func (arrastavel): return arrastavel.cor_jogador == jogador.cor)[0]
			destruir_peca_arrastavel(peca_arrastavel)

		tabuleiro_jogo.computar_jogada(espaco_disponivel.linha, espaco_disponivel.coluna)
		print("Jogada na posição: [", espaco_disponivel.linha, ", ", espaco_disponivel.coluna, "]")
		
		if tabuleiro_jogo.verificar_vitoria(jogador):
			info_jogo.text = Jogador.Cor.keys()[tabuleiro_jogo.jogador_vitoria.cor] + " venceu!"
			print("Jogador ", Jogador.Cor.keys()[jogador.cor], " venceu!")
			
			await marcar_vitoria()
			
			mostrar_tabuleiro_CLI()
		elif tabuleiro_jogo.verificar_empate():
			info_jogo.text = "Empate!"
			print("Empate!")
			
			mostrar_tabuleiro_CLI()
		else:
			var proximo_a_jogar = tabuleiro_jogo.proximo_a_jogar()
			info_jogo.text = "Jogador: " + Jogador.Cor.keys()[proximo_a_jogar.cor]
			habilitar_colunas()
	
			mostrar_tabuleiro_CLI()
			if tabuleiro_jogo.proximo_a_jogar().tipo_jogador == Jogador.TipoJogador.Computador\
				and not aguardar_jogada_IA:
				semaphore.post()

func pegar_espaco_disponivel(coluna, linha = null):
	var espaco_disponivel = null
	var espacos_jogaveis = espacos.get_children()
	espacos_jogaveis.reverse()
	
	if not linha == null:
		var espaco = espacos_jogaveis.filter(func(jogavel):\
			return jogavel.coluna == coluna and jogavel.linha == linha)
		if not espaco == null:
			espaco_disponivel = espaco[0]
	else:
		for espaco in espacos_jogaveis:
			if espaco.coluna == coluna and not espaco.ocupado:
				if espaco_disponivel == null or espaco.linha > espaco_disponivel.linha:
					espaco_disponivel = espaco

	return espaco_disponivel

func marcar_vitoria() -> void:
	marcando_vitoria = true
	
	var animacao_vitoria = animacao_vitoria_amarelo\
		if tabuleiro_jogo.jogador_vitoria.cor == Jogador.Cor.Amarelo else animacao_vitoria_vermelho
	var espacos_jogo = espacos.get_children()
	
	var vitorias_multiplas = {}
	for espaco_vitoria in tabuleiro_jogo.espacos_com_vitoria:
		if vitorias_multiplas.has(espaco_vitoria):
			continue
		
		var espaco = espacos_jogo.filter(func(esp):\
			return esp.linha == espaco_vitoria[0] and esp.coluna == espaco_vitoria[1])[0]
		
		var peca = peca_cena.instantiate()
		pecas.add_child(peca)
		peca.iniciar_animacao_vitoria(animacao_vitoria)
		peca.global_position = Vector2(espaco.global_position.x, 75)

		await peca.jogar_peca(espaco.global_position)
		
		vitorias_multiplas[espaco_vitoria] = true
		
	marcando_vitoria = false
