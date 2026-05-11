extends Node2D

@onready var peca_vermelha = "res://Assets/peca_vermelha.png"
@onready var peca_amarela = "res://Assets/peca_amarela.png"
@onready var animacao_vitoria_vermelho = "vitoria_vermelho"
@onready var animacao_vitoria_amarelo = "vitoria_amarelo"
@onready var colunas = $Tabuleiro/Colunas
@onready var espacos = $Tabuleiro/Espacos
@onready var pecas = $Pecas
@onready var opcoes_jogo = $Interface/OpcoesJogo.get_children()
@onready var info_jogo = $Interface/CenterContainer/InfoJogo
@onready var pecas_arrastaveis = $PecasArrastaveis

var peca_cena = preload("res://peca.tscn")
var peca_arrastavel_cena = preload("res://peca_arrastavel.tscn")
var profundidade_maxima = 4
var tabuleiro_jogo: Tabuleiro
var ia: Minimax = Minimax.new()

func _ready():
	reiniciar_jogo(Jogador.TipoJogador.Humano, Jogador.TipoJogador.Humano)
	for opcao_jogo in opcoes_jogo:
		opcao_jogo.connect("pressed", _on_opcoes_jogo_pressed.bind(opcao_jogo.name))

func _on_opcoes_jogo_pressed(name: String) -> void:
	match name:
		"JogadorContraJogador":
			print("Jogador vs Jogador")
			reiniciar_jogo(Jogador.TipoJogador.Humano, Jogador.TipoJogador.Humano)
		"JogadorContraIA":
			print("Jogador vs IA")
			reiniciar_jogo(Jogador.TipoJogador.Humano, Jogador.TipoJogador.Computador)
		"IAContraJogador":
			print("IA vs Jogador")
			reiniciar_jogo(Jogador.TipoJogador.Computador, Jogador.TipoJogador.Humano)
			jogar_na_posicao_IA()
		"JogoAuto":
			print("Jogo Automático")
			reiniciar_jogo(Jogador.TipoJogador.Computador, Jogador.TipoJogador.Computador)
			jogar_na_posicao_IA()

func reiniciar_jogo(tipo_jogador_amarelo, tipo_jogador_vermelho) -> void:
	desabilitar_colunas()

	tabuleiro_jogo = Tabuleiro.new()
	tabuleiro_jogo.jogador_amarelo.tipo_jogador = tipo_jogador_amarelo
	tabuleiro_jogo.jogador_vermelho.tipo_jogador = tipo_jogador_vermelho
	info_jogo.text = "Próximo a jogar: " + Jogador.Cor.keys()[tabuleiro_jogo.jogador_atual.cor]
	
	for peca_arrastavel in pecas_arrastaveis.get_children():
		peca_arrastavel.queue_free()
	for peca in pecas.get_children():
		peca.queue_free()
	for espaco in espacos.get_children():
		espaco.ocupado = false
	for i in range(20):
		var peca_arrastavel = peca_arrastavel_cena.instantiate()
		peca_arrastavel.cor_jogador = Jogador.Cor.Amarelo
		peca_arrastavel.global_position = Vector2(randi_range(50, 200), 300 + i * 10)
		peca_arrastavel.mudar_textura_jogador(peca_amarela)
		peca_arrastavel.jogada_na_coluna.connect(jogar_na_posicao_arrastando)
		
		pecas_arrastaveis.add_child(peca_arrastavel)
	for i in range(20):
		var peca_arrastavel = peca_arrastavel_cena.instantiate()
		peca_arrastavel.cor_jogador = Jogador.Cor.Vermelho
		peca_arrastavel.global_position = Vector2(randi_range(950, 1100), 300 + i * 10)
		peca_arrastavel.mudar_textura_jogador(peca_vermelha)
		peca_arrastavel.jogada_na_coluna.connect(jogar_na_posicao_arrastando)
		
		pecas_arrastaveis.add_child(peca_arrastavel)
	
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

func jogar_na_posicao_IA():
	desabilitar_colunas()
	await get_tree().create_timer(0.1).timeout
	
	var jogador = tabuleiro_jogo.jogador_atual
	var jogada = ia.jogar(tabuleiro_jogo.duplicate(true), jogador, profundidade_maxima)
	var linha = jogada.movimento[0]
	var coluna = jogada.movimento[1]

	await jogar_na_posicao(coluna, linha)

func jogar_na_posicao_arrastando(cor_jogador, coluna):
	if not cor_jogador == tabuleiro_jogo.jogador_atual.cor:
		print("Peça inválida!")
		return

	await jogar_na_posicao(coluna)

func jogar_na_posicao(coluna, linha = null):
	desabilitar_colunas()
	
	if not tabuleiro_jogo.estado_terminal():
		var jogador = tabuleiro_jogo.jogador_atual
		print("Vez do jogador: ", Jogador.Cor.keys()[jogador.cor])
		
		var espaco_disponivel = pegar_espaco_disponivel(coluna, linha)
		if espaco_disponivel == null:
			print("Coluna cheia!")
			return null
		
		var peca = peca_cena.instantiate()
		var cor_peca = peca_amarela if jogador.cor == Jogador.Cor.Amarelo else peca_vermelha
		peca.mudar_textura_jogador(cor_peca)
		pecas.add_child(peca)
	
		peca.global_position = Vector2(espaco_disponivel.global_position.x, -100)
		espaco_disponivel.ocupado = true
		await peca.jogar_peca(espaco_disponivel.global_position)

		tabuleiro_jogo.computar_jogada(espaco_disponivel.linha, espaco_disponivel.coluna)
		print("Jogada na posição: [", espaco_disponivel.linha, ", ", espaco_disponivel.coluna, "]")
		
		if tabuleiro_jogo.verificar_vitoria(jogador):
			info_jogo.text = "Jogador " + Jogador.Cor.keys()[tabuleiro_jogo.jogador_vitoria.cor] + " venceu!"
			print("Jogador ", Jogador.Cor.keys()[jogador.cor], " venceu!")
			
			marcar_vitoria()
			
			mostrar_tabuleiro_CLI()
		elif tabuleiro_jogo.verificar_empate():
			info_jogo.text = "Empate!"
			print("Empate!")
			
			mostrar_tabuleiro_CLI()
		else:
			var proximo_a_jogar = tabuleiro_jogo.proximo_a_jogar()
			info_jogo.text = "Próximo a jogar: " + Jogador.Cor.keys()[proximo_a_jogar.cor]
			await get_tree().create_timer(0.1).timeout
			habilitar_colunas()
	
			mostrar_tabuleiro_CLI()
			if tabuleiro_jogo.proximo_a_jogar().tipo_jogador == Jogador.TipoJogador.Computador:
				jogar_na_posicao_IA()

func pegar_espaco_disponivel(coluna, linha = null):
	var espaco_disponivel = null
	var espacos_jogaveis = espacos.get_children()
	espacos_jogaveis.reverse()
	
	if not linha == null:
		var espaco = espacos_jogaveis.filter(func(jogavel): return jogavel.coluna == coluna and jogavel.linha == linha)
		if not espaco == null:
			espaco_disponivel = espaco[0]
	else:
		for espaco in espacos_jogaveis:
			if espaco.coluna == coluna and not espaco.ocupado:
				if espaco_disponivel == null or espaco.linha > espaco_disponivel.linha:
					espaco_disponivel = espaco

	return espaco_disponivel

func marcar_vitoria() -> void:
	var animacao_vitoria = animacao_vitoria_amarelo if tabuleiro_jogo.jogador_vitoria.cor == Jogador.Cor.Amarelo else animacao_vitoria_vermelho
	var espacos = espacos.get_children()
	
	var vitorias_multiplas = {}
	for espaco_vitoria in tabuleiro_jogo.espacos_com_vitoria:
		if vitorias_multiplas.has(espaco_vitoria):
			continue
		
		var espaco = espacos.filter(func(esp): return esp.linha == espaco_vitoria[0] and esp.coluna == espaco_vitoria[1])[0]
		
		var peca = peca_cena.instantiate()
		pecas.add_child(peca)
		peca.iniciar_animacao_vitoria(animacao_vitoria)
		peca.global_position = Vector2(espaco.global_position.x, -100)

		await peca.jogar_peca(espaco.global_position)
		
		vitorias_multiplas[espaco_vitoria] = true
