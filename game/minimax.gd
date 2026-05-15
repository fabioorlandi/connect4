extends Resource
class_name Minimax

func jogar(tabuleiro: Tabuleiro, jogador: Jogador, profMax: int) -> Jogada:
	var jogada: Jogada = minimax(tabuleiro, jogador, profMax, 0)
	return jogada

func minimax(tabuleiro: Tabuleiro, jogador: Jogador, profMax: int, prof: int) -> Jogada:
	if Global2D.cancelar_IA:
		return Jogada.new([], 0)
	
	if tabuleiro.estado_terminal() or tabuleiro.verificar_empate() or prof == profMax:
		var avaliacao = tabuleiro.avaliar_estado(jogador)
		return Jogada.new([], avaliacao)
	
	var melhores_jogadas: Array = []
	
	if tabuleiro.jogador_atual.cor == jogador.cor:
		# MAX
		var melhor_pontuacao = -99999
		
		for movimento in tabuleiro.espacos_jogaveis():
			var novo_tabuleiro = tabuleiro.movimentar_IA(movimento[0], movimento[1], tabuleiro.jogador_atual)
			var resultado = minimax(novo_tabuleiro, jogador, profMax, prof + 1)
			var jogada = Jogada.new(movimento, resultado.avaliacao)

			if jogada.avaliacao > melhor_pontuacao:
				melhor_pontuacao = jogada.avaliacao
				melhores_jogadas = []
				melhores_jogadas.append(jogada)
			elif jogada.avaliacao == melhor_pontuacao:
				melhores_jogadas.append(jogada)
	else:
		# MIN
		var melhor_pontuacao = 99999
		
		for movimento in tabuleiro.espacos_jogaveis():
			var novo_tabuleiro = tabuleiro.movimentar_IA(movimento[0], movimento[1], tabuleiro.jogador_atual)
			var resultado = minimax(novo_tabuleiro, jogador, profMax, prof + 1)
			var jogada = Jogada.new(movimento, resultado.avaliacao)

			if jogada.avaliacao < melhor_pontuacao:
				melhor_pontuacao = jogada.avaliacao
				melhores_jogadas = []
				melhores_jogadas.append(jogada)
			elif jogada.avaliacao == melhor_pontuacao:
				melhores_jogadas.append(jogada)
	
	if !melhores_jogadas.is_empty():
		melhores_jogadas.shuffle()
		return melhores_jogadas[0]
	else:
		return Jogada.new([], 0)
