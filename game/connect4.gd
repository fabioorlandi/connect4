extends Node2D

@onready var peca_vermelha = "res://Assets/peca_vermelha.png"
@onready var peca_amarela = "res://Assets/peca_amarela.png"
@onready var colunas = $Tabuleiro/Colunas
@onready var espacos = $Tabuleiro/Espacos
@onready var pecas = $Pecas
@onready var opcoes_jogo = $Interface/OpcoesJogo.get_children()
@onready var info_jogo = $Interface/CenterContainer/InfoJogo
#@onready var pecas_arrastaveis = $DragPieces

var peca_cena = preload("res://peca.tscn")
var profundidade_maxima = 4
var tabuleiro_jogo: Tabuleiro
var ia: Minimax = Minimax.new()

func _ready():
	reiniciar_jogo()
	for opcao_jogo in opcoes_jogo:
		opcao_jogo.connect("pressed", _on_opcoes_jogo_pressed.bind(opcao_jogo.name))

	#if pecas_arrastaveis:
		#for peca_arrastavel in pecas_arrastaveis.get_children():
			#peca_arrastavel.dropped_on_column.connect(jogar_na_posicao)

func _on_opcoes_jogo_pressed(name: String) -> void:
	match name:
		"JogadorContraJogador":
			reiniciar_jogo()
			print("Jogador vs Jogador")
		"JogadorContraIA":
			reiniciar_jogo()
			print("Jogador vs IA")
		"IAContraJogador":
			reiniciar_jogo()
			print("IA vs Jogador")
		"JogoAuto":
			print("Jogo Automático")
			reiniciar_jogo()
			await processar_jogo_auto()

func reiniciar_jogo() -> void:
	desabilitar_colunas()
	
	tabuleiro_jogo = Tabuleiro.new()
	info_jogo.text = "Vez do jogador: " + Jogador.Cor.keys()[Jogador.Cor.Amarelo]
	
	for peca in pecas.get_children():
		peca.queue_free()
		
	for espaco in espacos.get_children():
		espaco.ocupado = false
	
	habilitar_colunas()

func desabilitar_colunas():
	$Tabuleiro/Colunas/AreaColuna_0.coluna_selecionada.disconnect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_1.coluna_selecionada.disconnect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_2.coluna_selecionada.disconnect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_3.coluna_selecionada.disconnect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_4.coluna_selecionada.disconnect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_5.coluna_selecionada.disconnect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_6.coluna_selecionada.disconnect(jogar_na_posicao)

func habilitar_colunas() :
	$Tabuleiro/Colunas/AreaColuna_0.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_1.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_2.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_3.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_4.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_5.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_6.coluna_selecionada.connect(jogar_na_posicao)

func processar_jogo_auto() -> void:
	desabilitar_colunas()
	
	while not tabuleiro_jogo.estado_terminal():
		mostrar_tabuleiro_CLI()
		
		var jogador = tabuleiro_jogo.jogador_atual
		print("Vez do jogador: ", Jogador.Cor.keys()[jogador.cor])
		info_jogo.text = "Vez do jogador: " + Jogador.Cor.keys()[jogador.cor]
		
		await get_tree().create_timer(0.1).timeout
		var jogada = ia.jogar(tabuleiro_jogo.duplicate(true), jogador, profundidade_maxima)
		
		if jogada.movimento.is_empty():
			print("Sem movimentos disponíveis!")
			break
		
		var linha = jogada.movimento[0]
		var coluna = jogada.movimento[1]
		
		await jogar_na_posicao(coluna, linha, false)
		print("Jogada na posição: [", linha, ", ", coluna, "]")
		
		tabuleiro_jogo.computar_jogada(linha, coluna)
		if tabuleiro_jogo.verificar_vitoria(jogador):
			mostrar_tabuleiro_CLI()
			print("Jogador ", "Amarelo" if jogador.cor == Jogador.Cor.Amarelo else "Vermelho", " venceu!")
			break

	if tabuleiro_jogo.verificar_empate():
		mostrar_tabuleiro_CLI()
		print("Empate!")

func mostrar_tabuleiro_CLI() -> void:
	print("\nTabuleiro:")
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
	print("-------------")

func jogar_na_posicao(coluna, linha = null, gerenciar_colunas = true):
	if not tabuleiro_jogo.estado_terminal():
		if gerenciar_colunas:
			desabilitar_colunas()
		
		var jogador = tabuleiro_jogo.jogador_atual
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
		tabuleiro_jogo.verificar_vitoria(jogador)
		
		info_jogo.text = "Vez do jogador: " + Jogador.Cor.keys()[tabuleiro_jogo.proximo_a_jogar().cor]
		
		if gerenciar_colunas:
			habilitar_colunas()

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
