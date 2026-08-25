extends Resource
class_name Minimax

func jogar(tabuleiro: Tabuleiro, jogador: Jogador, profMax: int, aleatoriedade: int) -> Jogada:
	var jogada: Jogada = minimax(tabuleiro, jogador, profMax, 0, aleatoriedade)
	return jogada

func minimax(tabuleiro: Tabuleiro, jogador: Jogador, profMax: int, prof: int, aleatoriedade: int) -> Jogada:
	if Global2D.cancelar_IA:
		return Jogada.new([], 0)
	
	if tabuleiro.estado_terminal() or tabuleiro.verificar_empate() or prof == profMax:
		var avaliacao = tabuleiro.avaliar_estado(jogador)
		return Jogada.new([], avaliacao)
	
	var melhores_jogadas: Array = []
	var jogadas_aleatorias: Array = []
	
	if tabuleiro.jogador_atual.cor == jogador.cor:
		# MAX
		var melhor_pontuacao = -99999
		
		for movimento in tabuleiro.espacos_jogaveis():
			var novo_tabuleiro = tabuleiro.movimentar_IA(movimento[0], movimento[1], tabuleiro.jogador_atual)
			var resultado = minimax(novo_tabuleiro, jogador, profMax, prof + 1, aleatoriedade)
			var jogada = Jogada.new(movimento, resultado.avaliacao)

			if randi_range(0, 100) < aleatoriedade:
				jogadas_aleatorias.append(jogada)
				continue

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
			var resultado = minimax(novo_tabuleiro, jogador, profMax, prof + 1, aleatoriedade)
			var jogada = Jogada.new(movimento, resultado.avaliacao)

			if randi_range(0, 100) < aleatoriedade:
				jogadas_aleatorias.append(jogada)
				continue

			if jogada.avaliacao < melhor_pontuacao:
				melhor_pontuacao = jogada.avaliacao
				melhores_jogadas = []
				melhores_jogadas.append(jogada)
			elif jogada.avaliacao == melhor_pontuacao:
				melhores_jogadas.append(jogada)
	
	if !melhores_jogadas.is_empty():
		melhores_jogadas.append_array(jogadas_aleatorias)
		melhores_jogadas.shuffle()
		return melhores_jogadas[0]
	elif !jogadas_aleatorias.is_empty():
		jogadas_aleatorias.shuffle()
		return jogadas_aleatorias[0]
	else:
		return Jogada.new([], 0)
