extends Node2D

@onready var peca_vermelha = "res://Assets/peca_vermelha.png"
@onready var peca_amarela = "res://Assets/peca_amarela.png"
@onready var tabuleiro = $Tabuleiro
@onready var colunas = $Tabuleiro/Colunas
@onready var espacos = $Tabuleiro/Espacos
@onready var pecas = $Pecas
#@onready var pecas_arrastaveis = $DragPieces

var peca_cena = preload("res://peca.tscn")
var tabuleiro_jogo: Tabuleiro = Tabuleiro.new()
var ia: Minimax = Minimax.new()
var profundidade_maxima = 4

func _ready():
	$Tabuleiro/Colunas/AreaColuna_0.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_1.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_2.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_3.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_4.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_5.coluna_selecionada.connect(jogar_na_posicao)
	$Tabuleiro/Colunas/AreaColuna_6.coluna_selecionada.connect(jogar_na_posicao)

	#processar_jogo_auto()

	#if pecas_arrastaveis:
		#for peca_arrastavel in pecas_arrastaveis.get_children():
			#peca_arrastavel.dropped_on_column.connect(jogar_na_posicao)
			
	
func processar_jogo_auto() -> void:
	while not tabuleiro_jogo.estado_terminal():
		print()
		var jogador = tabuleiro_jogo.jogadorAtual
		print("Vez do jogador: ", "Amarelo" if jogador.cor == Jogador.Cor.Amarelo else "Vermelho")
		
		var jogada = ia.jogar(tabuleiro_jogo.duplicate(true), jogador, profundidade_maxima)
		
		if jogada.movimento.is_empty():
			print("Sem movimentos disponíveis!")
			break
		
		var linha = jogada.movimento[0]
		var coluna = jogada.movimento[1]
		
		print("Jogada na posição: [", linha, ", ", coluna, "]")
		jogar_na_posicao(coluna, linha)
		
		tabuleiro_jogo.computar_jogada(linha, coluna)
		if tabuleiro_jogo.verificar_vitoria(jogador):
			print("Jogador ", "Amarelo" if jogador.cor == Jogador.Cor.Amarelo else "Vermelho", " venceu!")
			break
	
	if tabuleiro_jogo.verificar_empate():
		print("Empate!")

func jogar_na_posicao(coluna, linha = null):
	if not tabuleiro_jogo.estado_terminal():
		var jogador = tabuleiro_jogo.jogadorAtual

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
		peca.jogar_peca(espaco_disponivel.global_position)
		
		tabuleiro_jogo.computar_jogada(espaco_disponivel.linha, espaco_disponivel.coluna)
		tabuleiro_jogo.verificar_vitoria(jogador)

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
