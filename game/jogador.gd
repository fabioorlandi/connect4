extends Resource
class_name Jogador

enum Cor {Amarelo, Vermelho, Nenhum}
enum TipoJogador {Humano, Computador, Nenhum}

var cor: Cor
var tipo_jogador: TipoJogador

func _init(cor_jogador: Cor, jogador: TipoJogador) -> void:
	cor = cor_jogador
	tipo_jogador = jogador
