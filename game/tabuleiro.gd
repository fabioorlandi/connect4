extends Resource
class_name Tabuleiro

var jogadorAmarelo = Jogador.new(Jogador.Cor.Amarelo)
var jogadorVermelho = Jogador.new(Jogador.Cor.Vermelho)
var jogadorAtual: Jogador

@export var tabuleiro: Array

func _init() -> void:
	self.tabuleiro = [
		[null],[null],[null],[null],[null],[null],[null],
		[null],[null],[null],[null],[null],[null],[null],
		[null],[null],[null],[null],[null],[null],[null],
		[null],[null],[null],[null],[null],[null],[null],
		[null],[null],[null],[null],[null],[null],[null],
		[null],[null],[null],[null],[null],[null],[null]
	]
	jogadorAtual = jogadorAmarelo

func alternar_jogador() -> void:
	jogadorAtual = proximo_a_jogar()

func proximo_a_jogar() -> Jogador:
	return self.tabuleiro.count(null) % 2 == 0 if jogadorAmarelo else jogadorVermelho

func espacos_disponiveis() -> int:
	return self.tabuleiro.count(null)

func verificar_vitoria(jogador: Jogador) -> bool:
	var vitoria = false
	
	# Quantidade mínima de espaços que precisa ser avaliada
	const min_linhas_avaliacao = 3
	const min_colunas_avaliacao = 4
	
	# Verifica vitória do jogador na horizontal
	for linha in range(6):
		for coluna in range(min_colunas_avaliacao):
			var cores_array = []
			for i in range(4):
				cores_array.append(self.tabuleiro[linha][coluna + i].cor)
		
			var count_cor = cores_array.count(jogador)
			if count_cor == 4:
				vitoria = true

	# Verifica vitória do jogador na vertical
	if !vitoria:
		for linha in range(min_linhas_avaliacao):
			for coluna in range(7):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna].cor)

				var count_cor = cores_array.count(jogador)
				if count_cor == 4:
					vitoria = true

	# Verifica vitória do jogador na diagonal principal
	if !vitoria:
		for linha in range(min_linhas_avaliacao):
			for coluna in range(min_colunas_avaliacao):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna + i].cor)

				var count_cor = cores_array.count(jogador)
				if count_cor == 4:
					vitoria = true

	# Verifica vitória do jogador na diagonal secundária
	if !vitoria:
		for linha in range(min_linhas_avaliacao, 6):
			for coluna in range(min_colunas_avaliacao):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna + 3 - i].cor)

				var count_cor = cores_array.count(jogador)
				if count_cor == 4:
					vitoria = true
	
	return false

func verificar_empate() -> bool:
	return self.tabuleiro.count(null) == 0

func verificar_ameaca_dupla(jogador: Jogador) -> bool:
	return verificar_ameaca(jogador, 2, 2)
	
func verificar_ameaca_tripla(jogador: Jogador) -> bool:
	return verificar_ameaca(jogador, 3, 1)

func verificar_ameaca(jogador: Jogador, nivelAmeaca: int, casasVazias: int) -> bool:
	var possui_ameaca = false

	# Quantidade mínima de espaços que precisa ser avaliada
	const min_linhas_avaliacao = 3
	const min_colunas_avaliacao = 4

	# Verifica ameaça do jogador na horizontal
	for linha in range(6):
		for coluna in range(min_colunas_avaliacao):
			var cores_array = []
			for i in range(4):
				cores_array.append(self.tabuleiro[linha][coluna + i].cor)

			var count_cor = cores_array.count(jogador)
			var count_vazio = cores_array.count(null)

			if count_cor == nivelAmeaca and count_vazio == casasVazias:
				possui_ameaca = true

	# Verifica ameaça do jogador na vertical
	if (!possui_ameaca):
		for linha in range(min_linhas_avaliacao):
			for coluna in range(7):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna].cor)

				var count_cor = cores_array.count(jogador)
				var count_vazio = cores_array.count(null)

				if count_cor == nivelAmeaca and count_vazio == casasVazias:
					possui_ameaca = true

	# Verifica ameaça dos jogador na diagonal principal
	if (!possui_ameaca):
		for linha in range(min_linhas_avaliacao):
			for coluna in range(min_colunas_avaliacao):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna + i].cor)

				var count_cor = cores_array.count(jogador)
				var count_vazio = cores_array.count(null)

				if count_cor == nivelAmeaca and count_vazio == casasVazias:
					possui_ameaca = true

	# Verifica ameaça do jogador na diagonal secundária
	if (!possui_ameaca):
		for linha in range(min_linhas_avaliacao):
			for coluna in range(min_colunas_avaliacao):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna + 3 - i].cor)

				var count_cor = cores_array.count(jogador)
				var count_vazio = cores_array.count(null)

				if count_cor == nivelAmeaca and count_vazio == casasVazias:
					possui_ameaca = true
	
	return possui_ameaca

func avaliar_estado(jogador: Jogador) -> int:
	var jogadorOponente = jogador.cor == jogadorAtual.cor if proximo_a_jogar() else jogadorAtual
	
	var pontuacao_tabuleiro = 0
	if verificar_vitoria(jogador) || verificar_empate():
		pontuacao_tabuleiro += 50
	elif verificar_ameaca_tripla(jogador):
		pontuacao_tabuleiro += 10
	elif verificar_ameaca_dupla(jogador):
		pontuacao_tabuleiro += 5
	
	if verificar_vitoria(jogadorOponente):
		pontuacao_tabuleiro -= 20

	return pontuacao_tabuleiro
