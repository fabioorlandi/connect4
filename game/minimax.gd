extends Resource
class_name Minimax

func jogar(tabuleiro: Tabuleiro, jogador: Jogador, prof_max: int) -> Jogada:
	var jogada: Jogada = minimax(tabuleiro, jogador, prof_max, 0)
	return jogada

func minimax(tabuleiro: Tabuleiro, jogador: Jogador, prof_max: int, prof: int) -> Jogada:
	var avaliacao: int = tabuleiro.avaliar_estado(jogador)
	# Checa se o jogo acabou ou se atingiu a profundidade máxima de busca
	if tabuleiro.verificar_empate() or prof_max == prof:
		return Jogada.new([], avaliacao)

	var melhoresJogadas: Array = []
	var melhorPontuacao: int
	if tabuleiro.jogadorAtual == jogador:
		melhorPontuacao = -INF
	else:
		melhorPontuacao = +INF

	for espaco_jogavel in tabuleiro.espacos_jogaveis():
		var novo_tabuleiro: Tabuleiro = tabuleiro.movimentar_IA(espaco_jogavel[0], espaco_jogavel[1], jogador)

		var jogadorOponente: Jogador
		if jogador == tabuleiro.jogadorAmarelo:
			jogadorOponente = tabuleiro.jogadorVermelho
		else:
			jogadorOponente = tabuleiro.jogadorAmarelo

		var jogada: Jogada = minimax(novo_tabuleiro, jogadorOponente, prof_max, prof + 1)
		jogada.movimento = espaco_jogavel

		#Atualizar a melhor jogada
		if novo_tabuleiro.jogadorAtual == jogador:
			#MAX
			if jogada.avaliacao > melhorPontuacao:
				melhorPontuacao = jogada.avaliacao
				melhoresJogadas = []
				melhoresJogadas.append(jogada)
			elif jogada.avaliacao == melhorPontuacao:
				melhoresJogadas.append(jogada)
		else:
			#MIN
			if jogada.avaliacao < melhorPontuacao:
				melhorPontuacao = jogada.avaliacao
				melhoresJogadas = []
				melhoresJogadas.append(jogada)
			elif jogada.avaliacao == melhorPontuacao:
				melhoresJogadas.append(jogada)

	# Retorna a melhor jogada
	melhoresJogadas.shuffle()
	return melhoresJogadas[0]
