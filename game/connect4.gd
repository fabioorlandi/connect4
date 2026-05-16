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
@onready var opcoes_jogo = $Interface/OpcoesJogo.get_children()
@onready var botao_dificuldade = $Interface/BotaoDificuldade
@onready var info_jogo = $Interface/InfoJogo
@onready var pecas_arrastaveis = $PecasArrastaveis

var peca_cena = preload("res://peca.tscn")
var peca_arrastavel_cena = preload("res://peca_arrastavel.tscn")
var profundidade_maxima: int
var tabuleiro_jogo: Tabuleiro
var aguardar_jogada_IA = false
var thread: Thread = Thread.new()
var mutex: Mutex = Mutex.new()
var semaphore: Semaphore = Semaphore.new()
var ia: Minimax = Minimax.new()

var tipo_jogador_amarelo_atual: Jogador.TipoJogador
var tipo_jogador_vermelho_atual: Jogador.TipoJogador

func _ready():
	profundidade_maxima = 2
	reiniciar_jogo(Jogador.TipoJogador.Humano, Jogador.TipoJogador.Humano)

	botao_dificuldade.connect("pressed", _on_dificuldade_pressed)
	for opcao_jogo in opcoes_jogo:
		opcao_jogo.connect("pressed", _on_opcoes_jogo_pressed.bind(opcao_jogo.name))

func _on_dificuldade_pressed() -> void:
	match botao_dificuldade.dificuldade:
		Dificuldade.SeletorDificuldade.Facil:
			profundidade_maxima = 2
		Dificuldade.SeletorDificuldade.Medio:
			profundidade_maxima = 3
		Dificuldade.SeletorDificuldade.Dificil:
			profundidade_maxima = 4
			
	reiniciar_jogo(tipo_jogador_amarelo_atual, tipo_jogador_vermelho_atual)

func _on_opcoes_jogo_pressed(nome_opcao: String) -> void:
	match nome_opcao:
		"JogadorContraJogador":
			print("Jogador vs Jogador")
			tipo_jogador_amarelo_atual = Jogador.TipoJogador.Humano
			tipo_jogador_vermelho_atual = Jogador.TipoJogador.Humano
			reiniciar_jogo(tipo_jogador_amarelo_atual, tipo_jogador_vermelho_atual)
		"JogadorContraIA":
			print("Jogador vs IA")
			tipo_jogador_amarelo_atual = Jogador.TipoJogador.Humano
			tipo_jogador_vermelho_atual = Jogador.TipoJogador.Computador
			reiniciar_jogo(tipo_jogador_amarelo_atual, tipo_jogador_vermelho_atual)
		"IAContraJogador":
			print("IA vs Jogador")
			tipo_jogador_amarelo_atual = Jogador.TipoJogador.Computador
			tipo_jogador_vermelho_atual = Jogador.TipoJogador.Humano
			reiniciar_jogo(tipo_jogador_amarelo_atual, tipo_jogador_vermelho_atual)
		"IAContraIA":
			print("IA vs IA")
			tipo_jogador_amarelo_atual = Jogador.TipoJogador.Computador
			tipo_jogador_vermelho_atual = Jogador.TipoJogador.Computador
			reiniciar_jogo(tipo_jogador_amarelo_atual, tipo_jogador_vermelho_atual)

func reiniciar_jogo(tipo_jogador_amarelo, tipo_jogador_vermelho) -> void:
	desabilitar_colunas()

	botao_dificuldade.disabled = true
	for opcao_jogo in opcoes_jogo:
		opcao_jogo.disabled = true
		
	Global2D.cancelar_IA = true
	aguardar_jogada_IA = true
	if thread.is_started():
		semaphore.post()
		thread.wait_to_finish()

	for peca_arrastavel in pecas_arrastaveis.get_children():
		peca_arrastavel.destruir_peca_arrastavel()
	for peca in pecas.get_children():
		await peca.destruir_peca()
	for espaco in espacos.get_children():
		espaco.ocupado = false
	for i in range(21):
		var peca_arrastavel = peca_arrastavel_cena.instantiate()
		peca_arrastavel.cor_jogador = Jogador.Cor.Amarelo
		peca_arrastavel.global_position = Vector2(randi_range(25, 225), 475 + i * 5)
		peca_arrastavel.mudar_textura_jogador(peca_amarela_mesa)
		peca_arrastavel.jogada_na_coluna.connect(jogar_na_posicao_arrastando)
		
		pecas_arrastaveis.add_child(peca_arrastavel)
	for i in range(21):
		var peca_arrastavel = peca_arrastavel_cena.instantiate()
		peca_arrastavel.cor_jogador = Jogador.Cor.Vermelho
		peca_arrastavel.global_position = Vector2(randi_range(925, 1125), 475 + i * 5)
		peca_arrastavel.mudar_textura_jogador(peca_vermelha_mesa)
		peca_arrastavel.jogada_na_coluna.connect(jogar_na_posicao_arrastando)
		
		pecas_arrastaveis.add_child(peca_arrastavel)
	
	tabuleiro_jogo = Tabuleiro.new()
	tabuleiro_jogo.jogador_amarelo.tipo_jogador = tipo_jogador_amarelo
	tabuleiro_jogo.jogador_vermelho.tipo_jogador = tipo_jogador_vermelho
	info_jogo.text = "Jogador: " + Jogador.Cor.keys()[tabuleiro_jogo.jogador_atual.cor]

	Global2D.cancelar_IA = false
	aguardar_jogada_IA = false
	thread.start(iniciar_jogada_IA)
	
	if tabuleiro_jogo.jogador_atual.tipo_jogador == Jogador.TipoJogador.Computador:
		semaphore.post()

	botao_dificuldade.disabled = false
	for opcao_jogo in opcoes_jogo:
		opcao_jogo.disabled = false

	habilitar_colunas()

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
		peca_arrastavel.queue_free()
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
			arrastaveis.filter(func (arrastavel): return arrastavel.cor_jogador == jogador.cor)[0].queue_free()

		tabuleiro_jogo.computar_jogada(espaco_disponivel.linha, espaco_disponivel.coluna)
		print("Jogada na posição: [", espaco_disponivel.linha, ", ", espaco_disponivel.coluna, "]")
		
		if tabuleiro_jogo.verificar_vitoria(jogador):
			info_jogo.text = Jogador.Cor.keys()[tabuleiro_jogo.jogador_vitoria.cor] + " venceu!"
			print("Jogador ", Jogador.Cor.keys()[jogador.cor], " venceu!")
			
			marcar_vitoria()
			
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
