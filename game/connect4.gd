extends Node2D

var tabuleiro: Tabuleiro = Tabuleiro.new()
var ia: Minimax = Minimax.new()
var profundidade_maxima = 4

func _ready() -> void:
	print("Iniciando jogo...")
	processar_jogo_auto()

func processar_jogo_auto() -> void:
	while not tabuleiro.estado_terminal():
		mostrar_tabuleiro()
		
		var jogador = tabuleiro.jogadorAtual
		print("Vez do jogador: ", "Amarelo" if jogador.cor == Jogador.Cor.Amarelo else "Vermelho")
		
		var jogada = ia.jogar(tabuleiro.duplicate(true), jogador, profundidade_maxima)
		
		if jogada.movimento.is_empty():
			print("Sem movimentos disponíveis!")
			break
		
		var linha = jogada.movimento[0]
		var coluna = jogada.movimento[1]
		
		print("Jogada na posição: [", linha, ", ", coluna, "]")
		
		tabuleiro.computar_jogada(linha, coluna)
		if tabuleiro.verificar_vitoria(jogador):
			mostrar_tabuleiro()
			print("Jogador ", "Amarelo" if jogador.cor == Jogador.Cor.Amarelo else "Vermelho", " venceu!")
			break
	
	if tabuleiro.verificar_empate():
		mostrar_tabuleiro()
		print("Empate!")

func mostrar_tabuleiro() -> void:
	print("\nTabuleiro:")
	for linha in range(6):
		var linha_str = ""
		for coluna in range(7):
			var cor = tabuleiro.tabuleiro[linha][coluna]
			if cor == Jogador.Cor.Nenhum:
				linha_str += ". "
			elif cor == Jogador.Cor.Amarelo:
				linha_str += "A "
			else:
				linha_str += "V "
		print(linha_str)
	print("---------------")
