extends Resource
class_name Tabuleiro

var jogadorVazio = Jogador.new(Jogador.Cor.Nenhum)
var jogadorAmarelo = Jogador.new(Jogador.Cor.Amarelo)
var jogadorVermelho = Jogador.new(Jogador.Cor.Vermelho)
var jogadorAtual: Jogador

@export var tabuleiro: Array

func _init() -> void:
	var vazio = jogadorVazio
	self.tabuleiro = [
		[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],
		[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],
		[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],
		[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],
		[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],
		[vazio],[vazio],[vazio],[vazio],[vazio],[vazio],[vazio]
	]
	jogadorAtual = jogadorAmarelo

func alternar_jogador() -> void:
	jogadorAtual = proximo_a_jogar()

func proximo_a_jogar() -> Jogador:
	if self.tabuleiro.count(Jogador.Cor.Nenhum) % 2:
		return jogadorAmarelo 
	else: 
		return jogadorVermelho

func espacos_jogaveis() -> Array:
	var espacosValidos: Array = [];
	
	for coluna in range(7):
		for linha in range(6):
			if self.tabuleiro[linha][coluna] == Jogador.Cor.Nenhum:
				espacosValidos.append([linha][coluna])
				break

	return espacosValidos

func computar_jogada(pos_x: int, pos_y: int) -> void:
	if self.tabuleiro[pos_x][pos_y] == Jogador.Cor.Nenhum:
		self.tabuleiro[pos_x][pos_y] = jogadorAtual.cor
		alternar_jogador()
		
func movimentar_IA(pos_x: int, pos_y: int, jogador: Jogador) -> Tabuleiro:
	var novo_tabuleiro = self.duplicate(true)
	novo_tabuleiro.tabuleiro[pos_x][pos_y] = jogador
	return novo_tabuleiro

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
	return self.tabuleiro.count(Jogador.Cor.Nenhum) == 0

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
			var count_vazio = cores_array.count(Jogador.Cor.Nenhum)

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
				var count_vazio = cores_array.count(Jogador.Cor.Nenhum)

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
				var count_vazio = cores_array.count(Jogador.Cor.Nenhum)

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
				var count_vazio = cores_array.count(Jogador.Cor.Nenhum)

				if count_cor == nivelAmeaca and count_vazio == casasVazias:
					possui_ameaca = true
	
	return possui_ameaca

func avaliar_estado(jogador: Jogador) -> int:
	var jogadorOponente: Jogador
	if jogador.cor == jogadorAtual.cor:
		jogadorOponente = proximo_a_jogar()
	else: 
		jogadorOponente = jogadorAtual

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
