extends Resource
class_name Minimax

func jogar(tabuleiro: Tabuleiro, jogador: Jogador, profMax: int) -> Jogada:
	var jogada: Jogada = minimax(tabuleiro, jogador, profMax, 0)
	return jogada

func minimax(tabuleiro: Tabuleiro, jogador: Jogador, profMax: int, prof: int) -> Jogada:
	if tabuleiro.estado_terminal() or tabuleiro.verificar_empate() or prof == profMax:
		var avaliacao = tabuleiro.avaliar_estado(jogador)
		return Jogada.new([], avaliacao)
	
	var melhoresJogadas: Array = []
	
	if tabuleiro.jogadorAtual.cor == jogador.cor:
		# MAX
		var melhorPontuacao = -99999
		
		for movimento in tabuleiro.espacos_jogaveis():
			var novoTabuleiro = tabuleiro.movimentar_IA(movimento[0], movimento[1], tabuleiro.jogadorAtual)
			var resultado = minimax(novoTabuleiro, jogador, profMax, prof + 1)
			var jogada = Jogada.new(movimento, resultado.avaliacao)

			if jogada.avaliacao > melhorPontuacao:
				melhorPontuacao = jogada.avaliacao
				melhoresJogadas = []
				melhoresJogadas.append(jogada)
			elif jogada.avaliacao == melhorPontuacao:
				melhoresJogadas.append(jogada)
	else:
		# MIN
		var melhorPontuacao = 99999
		
		for movimento in tabuleiro.espacos_jogaveis():
			var novoTabuleiro = tabuleiro.movimentar_IA(movimento[0], movimento[1], tabuleiro.jogadorAtual)
			var resultado = minimax(novoTabuleiro, jogador, profMax, prof + 1)
			var jogada = Jogada.new(movimento, resultado.avaliacao)

			if jogada.avaliacao < melhorPontuacao:
				melhorPontuacao = jogada.avaliacao
				melhoresJogadas = []
				melhoresJogadas.append(jogada)
			elif jogada.avaliacao == melhorPontuacao:
				melhoresJogadas.append(jogada)
	
	if !melhoresJogadas.is_empty():
		melhoresJogadas.shuffle()
		return melhoresJogadas[0]
	else:
		return Jogada.new([], 0)
