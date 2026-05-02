extends Resource
class_name Jogador

enum Cor {Amarelo, Vermelho, Nenhum}

@export var cor: Cor;

func _init(corJogador: Cor) -> void:
	cor = corJogador
