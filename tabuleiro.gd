extends Resource
class_name Tabuleiro

var jogadorAmarelo = Jogador.new(Jogador.Cor.Amarelo)
var jogadorVermelho = Jogador.new(Jogador.Cor.Vermelho)

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

func jogador_atual() -> Jogador:
	return self.tabuleiro.count(null) % 2 == 0 if jogadorAmarelo else jogadorVermelho

func verificar_vitoria(jogador: Jogador) -> bool:
	# Quantidade mínima de espaços que precisa ser avaliada
	const min_linhas_avaliacao = 3
	const min_colunas_avaliacao = 4
	
	# Verifica vitória do jogador na horizontal
	for linha in range(6):
		for coluna in range(min_colunas_avaliacao):
			var connect1 = self.tabuleiro[linha][coluna].cor
			var connect2 = self.tabuleiro[linha][coluna + 1].cor
			var connect3 = self.tabuleiro[linha][coluna + 2].cor
			var connect4 = self.tabuleiro[linha][coluna + 3].cor
			
			return connect1 == connect2 == connect3 == connect4 == jogador.cor
			
	# Verifica vitória do jogador na vertical
	for linha in range(min_linhas_avaliacao):
		for coluna in range(7):
			var connect1 = self.tabuleiro[linha][coluna].cor
			var connect2 = self.tabuleiro[linha + 1][coluna].cor
			var connect3 = self.tabuleiro[linha + 2][coluna].cor
			var connect4 = self.tabuleiro[linha + 3][coluna].cor
			
			return connect1 == connect2 == connect3 == connect4 == jogador.cor
			
	# Verifica vitória do jogador na diagonal principal
	for linha in range(min_linhas_avaliacao):
		for coluna in range(min_colunas_avaliacao):
			var connect1 = self.tabuleiro[linha][coluna].cor
			var connect2 = self.tabuleiro[linha + 1][coluna + 1].cor
			var connect3 = self.tabuleiro[linha + 2][coluna + 2].cor
			var connect4 = self.tabuleiro[linha + 3][coluna + 3].cor
			
			return connect1 == connect2 == connect3 == connect4 == jogador.cor
			
	# Verifica vitória do jogador na diagonal secundária
	for linha in range(min_linhas_avaliacao, 6):
		for coluna in range(min_colunas_avaliacao):
			var connect1 = self.tabuleiro[linha][coluna].cor
			var connect2 = self.tabuleiro[linha - 1][coluna + 1].cor
			var connect3 = self.tabuleiro[linha - 2][coluna + 2].cor
			var connect4 = self.tabuleiro[linha - 3][coluna - 3].cor
			
			return connect1 == connect2 == connect3 == connect4 == jogador.cor
	
	return false

func avaliar_estado() -> int:
	return 1
