extends Resource
class_name Tabuleiro

var jogador_vazio = Jogador.new(Jogador.Cor.Nenhum, Jogador.TipoJogador.Nenhum)
var jogador_amarelo = Jogador.new(Jogador.Cor.Amarelo, Jogador.TipoJogador.Humano)
var jogador_vermelho = Jogador.new(Jogador.Cor.Vermelho, Jogador.TipoJogador.Humano)
var jogador_atual: Jogador
var jogador_vitoria: Jogador
var espacos_com_vitoria: Array = []

@export var tabuleiro: Array
const PESOS_TABULEIRO = [
	[3, 4, 5, 7, 5, 4, 3],
	[4, 6, 8, 10, 8, 6, 4],
	[5, 8, 11, 13, 11, 8, 5],
	[5, 8, 11, 13, 11, 8, 5],
	[4, 6, 8, 10, 8, 6, 4],
	[3, 4, 5, 7, 5, 4, 3]
]

func _init() -> void:
	var vazio = jogador_vazio.cor
	self.tabuleiro = [
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio],
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio],
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio],
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio],
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio],
		[vazio,vazio,vazio,vazio,vazio,vazio,vazio]
	]
	jogador_atual = jogador_amarelo

func estado_terminal() -> bool:
	if verificar_empate() || jogador_vitoria != null:
		return true

	return false

func alternar_jogador() -> void:
	jogador_atual = proximo_a_jogar()

func proximo_a_jogar() -> Jogador:
	var espacos_vazios = 0
	for linha in range(6):
		for coluna in range(7):
			if self.tabuleiro[linha][coluna] == Jogador.Cor.Nenhum:
				espacos_vazios += 1
	
	if espacos_vazios % 2 == 0:
		return jogador_amarelo 
	else: 
		return jogador_vermelho

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
		self.tabuleiro[pos_x][pos_y] = jogador_atual.cor
		alternar_jogador()
		
func movimentar_IA(pos_x: int, pos_y: int, jogador: Jogador) -> Tabuleiro:
	var novo_tabuleiro = self.duplicate(true)
	novo_tabuleiro.tabuleiro[pos_x][pos_y] = jogador.cor
	novo_tabuleiro.jogador_atual = novo_tabuleiro.proximo_a_jogar()
	
	if novo_tabuleiro.verificar_vitoria(jogador):
		novo_tabuleiro.jogador_vitoria = jogador

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
			var vitoria_array = []
			for i in range(4):
				cores_array.append(self.tabuleiro[linha][coluna + i])
				vitoria_array.append([linha, coluna + i])
		
			var count_cor = cores_array.count(jogador.cor)
			if count_cor == 4:
				espacos_com_vitoria.append_array(vitoria_array)
				vitoria = true

	# Verifica vitória do jogador na vertical
	for linha in range(min_linhas_avaliacao):
		for coluna in range(7):
			var cores_array = []
			var vitoria_array = []
			for i in range(4):
				cores_array.append(self.tabuleiro[linha + i][coluna])
				vitoria_array.append([linha + i, coluna])

			var count_cor = cores_array.count(jogador.cor)
			if count_cor == 4:
				espacos_com_vitoria.append_array(vitoria_array)
				vitoria = true

	# Verifica vitória do jogador na diagonal principal
	for linha in range(min_linhas_avaliacao):
		for coluna in range(min_colunas_avaliacao):
			var cores_array = []
			var vitoria_array = []
			for i in range(4):
				cores_array.append(self.tabuleiro[linha + i][coluna + i])
				vitoria_array.append([linha + i, coluna + i])

			var count_cor = cores_array.count(jogador.cor)
			if count_cor == 4:
				espacos_com_vitoria.append_array(vitoria_array)
				vitoria = true

	# Verifica vitória do jogador na diagonal secundária
	for linha in range(min_linhas_avaliacao):
		for coluna in range(min_colunas_avaliacao):
			var cores_array = []
			var vitoria_array = []
			for i in range(4):
				cores_array.append(self.tabuleiro[linha + i][coluna + 3 - i])
				cores_array.append([linha + i, coluna + 3 - i])

			var count_cor = cores_array.count(jogador.cor)
			if count_cor == 4:
				espacos_com_vitoria.append_array(vitoria_array)
				vitoria = true
	
	if vitoria:
		jogador_vitoria = jogador
	
	return vitoria

func verificar_empate() -> bool:
	var espacos_vazios = 0
	for linha in range(6):
		for coluna in range(7):
			if self.tabuleiro[linha][coluna] == Jogador.Cor.Nenhum:
				espacos_vazios += 1
	
	return espacos_vazios == 0

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
	var jogador_oponente: Jogador
	if jogador.cor == jogador_atual.cor:
		jogador_oponente = proximo_a_jogar()
	else: 
		jogador_oponente = jogador_atual

	if verificar_vitoria(jogador):
		return 100000
	
	if verificar_vitoria(jogador_oponente):
		return -50000
	
	var pontuacao_tabuleiro = 0
	if verificar_ameaca_tripla(jogador):
		pontuacao_tabuleiro += 5000
	if verificar_ameaca_tripla(jogador_oponente):
		pontuacao_tabuleiro -= 30000
	if verificar_ameaca_dupla(jogador):
		pontuacao_tabuleiro += 500
	if verificar_ameaca_dupla(jogador_oponente):
		pontuacao_tabuleiro -= 2000
	
	for linha in range(6):
		if self.tabuleiro[linha][3] == jogador.cor:
			pontuacao_tabuleiro += 500 * (linha + 1)

	for coluna in range(7):
		for linha in range(5, -1, -1):
			if self.tabuleiro[linha][coluna] == jogador.cor:
				pontuacao_tabuleiro += linha * 100
				break

	return pontuacao_tabuleiro
