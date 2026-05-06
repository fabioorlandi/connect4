extends Resource
class_name Tabuleiro

var jogadorVazio = Jogador.new(Jogador.Cor.Nenhum)
var jogadorAmarelo = Jogador.new(Jogador.Cor.Amarelo)
var jogadorVermelho = Jogador.new(Jogador.Cor.Vermelho)
var jogadorAtual: Jogador
var jogadorVitoria: Jogador

const PESOS_TABULEIRO = [
	[3, 4, 5, 7, 5, 4, 3],
	[4, 6, 8, 10, 8, 6, 4],
	[5, 8, 11, 13, 11, 8, 5],
	[5, 8, 11, 13, 11, 8, 5],
	[4, 6, 8, 10, 8, 6, 4],
	[3, 4, 5, 7, 5, 4, 3]
]

@export var tabuleiro: Array

func _init() -> void:
	var vazio = jogadorVazio.cor
	self.tabuleiro = [
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio],
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio],
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio],
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio],
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio],
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio]
	]
	jogadorAtual = jogadorAmarelo

func estado_terminal() -> bool:
	if verificar_empate() || jogadorVitoria != null:
		return true

	return false

func alternar_jogador() -> void:
	jogadorAtual = proximo_a_jogar()

func proximo_a_jogar() -> Jogador:
	var espacosVazios = 0
	for linha in range(6):
		for coluna in range(7):
			if self.tabuleiro[linha][coluna] == Jogador.Cor.Nenhum:
				espacosVazios += 1
	
	if espacosVazios % 2 == 0:
		return jogadorAmarelo 
	else: 
		return jogadorVermelho

func espacos_jogaveis() -> Array:
	var espacos = []
	
	for coluna in range(7):
		for linha in range(5, -1, -1):
			if self.tabuleiro[linha][coluna] == Jogador.Cor.Nenhum:
				espacos.append([linha, coluna, PESOS_TABULEIRO[linha][coluna]])
				break
	
	espacos.sort_custom(func(a, b):	return a[2] > b[2])
	
	var resultado = []
	for espaco in espacos:
		resultado.append([espaco[0], espaco[1]])

	return resultado

func computar_jogada(pos_x: int, pos_y: int) -> void:
	if self.tabuleiro[pos_x][pos_y] == Jogador.Cor.Nenhum:
		self.tabuleiro[pos_x][pos_y] = jogadorAtual.cor
		alternar_jogador()
		
func movimentar_IA(pos_x: int, pos_y: int, jogador: Jogador) -> Tabuleiro:
	var novo_tabuleiro = self.duplicate(true)
	novo_tabuleiro.tabuleiro[pos_x][pos_y] = jogador.cor
	novo_tabuleiro.jogadorAtual = novo_tabuleiro.proximo_a_jogar()
	
	if novo_tabuleiro.verificar_vitoria(jogador):
		novo_tabuleiro.jogadorVitoria = jogador

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
				cores_array.append(self.tabuleiro[linha][coluna + i])
		
			var count_cor = cores_array.count(jogador.cor)
			if count_cor == 4:
				vitoria = true

	# Verifica vitória do jogador na vertical
	if !vitoria:
		for linha in range(min_linhas_avaliacao):
			for coluna in range(7):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna])

				var count_cor = cores_array.count(jogador.cor)
				if count_cor == 4:
					vitoria = true

	# Verifica vitória do jogador na diagonal principal
	if !vitoria:
		for linha in range(min_linhas_avaliacao):
			for coluna in range(min_colunas_avaliacao):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna + i])

				var count_cor = cores_array.count(jogador.cor)
				if count_cor == 4:
					vitoria = true

	# Verifica vitória do jogador na diagonal secundária
	if !vitoria:
		for linha in range(min_linhas_avaliacao):
			for coluna in range(min_colunas_avaliacao):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna + 3 - i])

				var count_cor = cores_array.count(jogador.cor)
				if count_cor == 4:
					vitoria = true
	
	if vitoria:
		jogadorVitoria = jogador
	
	return vitoria

func verificar_empate() -> bool:
	var espacosVazios = 0
	for linha in range(6):
		for coluna in range(7):
			if self.tabuleiro[linha][coluna] == Jogador.Cor.Nenhum:
				espacosVazios += 1
	
	return espacosVazios == 0

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
				cores_array.append(self.tabuleiro[linha][coluna + i])

			var count_cor = cores_array.count(jogador.cor)
			var count_vazio = cores_array.count(Jogador.Cor.Nenhum)

			if count_cor == nivelAmeaca and count_vazio == casasVazias:
				possui_ameaca = true

	# Verifica ameaça do jogador na vertical
	if (!possui_ameaca):
		for linha in range(min_linhas_avaliacao):
			for coluna in range(7):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna])

				var count_cor = cores_array.count(jogador.cor)
				var count_vazio = cores_array.count(Jogador.Cor.Nenhum)

				if count_cor == nivelAmeaca and count_vazio == casasVazias:
					possui_ameaca = true

	# Verifica ameaça dos jogador na diagonal principal
	if (!possui_ameaca):
		for linha in range(min_linhas_avaliacao):
			for coluna in range(min_colunas_avaliacao):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna + i])

				var count_cor = cores_array.count(jogador.cor)
				var count_vazio = cores_array.count(Jogador.Cor.Nenhum)

				if count_cor == nivelAmeaca and count_vazio == casasVazias:
					possui_ameaca = true

	# Verifica ameaça do jogador na diagonal secundária
	if (!possui_ameaca):
		for linha in range(min_linhas_avaliacao):
			for coluna in range(min_colunas_avaliacao):
				var cores_array = []
				for i in range(4):
					cores_array.append(self.tabuleiro[linha + i][coluna + 3 - i])

				var count_cor = cores_array.count(jogador.cor)
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

	if verificar_vitoria(jogador):
		return 100000
	
	if verificar_vitoria(jogadorOponente):
		return -50000
	
	var pontuacaoTabuleiro = 0
	if verificar_ameaca_tripla(jogador):
		pontuacaoTabuleiro += 5000
	if verificar_ameaca_tripla(jogadorOponente):
		pontuacaoTabuleiro -= 30000
	if verificar_ameaca_dupla(jogador):
		pontuacaoTabuleiro += 500
	if verificar_ameaca_dupla(jogadorOponente):
		pontuacaoTabuleiro -= 2000
	
	for linha in range(6):
		if self.tabuleiro[linha][3] == jogador.cor:
			pontuacaoTabuleiro += 500 * (linha + 1)

	for coluna in range(7):
		for linha in range(5, -1, -1):
			if self.tabuleiro[linha][coluna] == jogador.cor:
				pontuacaoTabuleiro += linha * 100
				break

	return pontuacaoTabuleiro
