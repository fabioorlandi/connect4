#extends Node2D
#
#var tabuleiro: Tabuleiro = Tabuleiro.new()
#var ia: Minimax = Minimax.new()
#var profundidade_maxima = 4
#
#func _ready() -> void:
	#print("Iniciando jogo...")
	#processar_jogo_auto()
#
#func processar_jogo_auto() -> void:
	#while not tabuleiro.estado_terminal():
		#mostrar_tabuleiro()
		#
		#var jogador = tabuleiro.jogadorAtual
		#print("Vez do jogador: ", "Amarelo" if jogador.cor == Jogador.Cor.Amarelo else "Vermelho")
		#
		#var jogada = ia.jogar(tabuleiro.duplicate(true), jogador, profundidade_maxima)
		#
		#if jogada.movimento.is_empty():
			#print("Sem movimentos disponíveis!")
			#break
		#
		#var linha = jogada.movimento[0]
		#var coluna = jogada.movimento[1]
		#
		#print("Jogada na posição: [", linha, ", ", coluna, "]")
		#
		#tabuleiro.computar_jogada(linha, coluna)
		#if tabuleiro.verificar_vitoria(jogador):
			#mostrar_tabuleiro()
			#print("Jogador ", "Amarelo" if jogador.cor == Jogador.Cor.Amarelo else "Vermelho", " venceu!")
			#break
	#
	#if tabuleiro.verificar_empate():
		#mostrar_tabuleiro()
		#print("Empate!")
#
#func mostrar_tabuleiro() -> void:
	#print("\nTabuleiro:")
	#for linha in range(6):
		#var linha_str = ""
		#for coluna in range(7):
			#var cor = tabuleiro.tabuleiro[linha][coluna]
			#if cor == Jogador.Cor.Nenhum:
				#linha_str += ". "
			#elif cor == Jogador.Cor.Amarelo:
				#linha_str += "A "
			#else:
				#linha_str += "V "
		#print(linha_str)
	#print("---------------")


extends Node2D

@onready var board = $Tabuleiro
@onready var columns = $Tabuleiro/Colunas
@onready var pieces = $Pecas
@onready var drag_pieces = $DragPieces

var piece_scene = preload("res://peca.tscn")

func _ready():
	$Tabuleiro/Colunas/AreaColuna_0.coluna_selecionada.connect(jogar_na_coluna)
	$Tabuleiro/Colunas/AreaColuna_1.coluna_selecionada.connect(jogar_na_coluna)
	$Tabuleiro/Colunas/AreaColuna_2.coluna_selecionada.connect(jogar_na_coluna)
	$Tabuleiro/Colunas/AreaColuna_3.coluna_selecionada.connect(jogar_na_coluna)
	$Tabuleiro/Colunas/AreaColuna_4.coluna_selecionada.connect(jogar_na_coluna)
	$Tabuleiro/Colunas/AreaColuna_5.coluna_selecionada.connect(jogar_na_coluna)
	$Tabuleiro/Colunas/AreaColuna_6.coluna_selecionada.connect(jogar_na_coluna)

	#for drag_piece in drag_pieces.get_children():
		#drag_piece.dropped_on_column.connect(jogar_na_coluna)


func jogar_na_coluna(coluna):
	var lowest_slot = null

	for slot in board.get_children():
		if slot.coluna == coluna and not slot.ocupado:
			if lowest_slot == null or slot.linha < lowest_slot.linha:
				lowest_slot = slot

	if lowest_slot == null:
		print("Coluna cheia!")
		return

	var piece = piece_scene.instantiate()
	pieces.add_child(piece)

	piece.global_position = Vector2(lowest_slot.global_position.x, -100)

	lowest_slot.ocupado = true

	piece.cair_ate(lowest_slot.global_position)
