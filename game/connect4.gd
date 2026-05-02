extends Node2D

var tabuleiro: Tabuleiro = Tabuleiro.new()
var ia: Minimax = Minimax.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	processar_jogo_auto()
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func processar_jogo_auto() -> void:
	var jogador = tabuleiro.jogadorAtual
	var jogada = ia.jogar(tabuleiro.duplicate(true), jogador, 10)
	
	print(tabuleiro.jogadorAtual.cor)
