extends Area2D

signal coluna_selecionada(indice_coluna)
signal mudar_jogador(cor, tipo)
signal atualizar_hover

@export var indice_coluna := 0
var animacao_fantasma = "peca_fantasma_amarela"
var cor_jogador = Jogador.Cor.Amarelo
var tipo_jogador = Jogador.TipoJogador.Humano
var mouse_over = false
var coluna_bloqueada = false

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not Global2D.is_dragging:
				coluna_selecionada.emit(indice_coluna)

func mudar_fantasma_jogador(cor, tipo):
	animacao_fantasma = "peca_fantasma_amarela" if cor == Jogador.Cor.Amarelo else "peca_fantasma_vermelha"
	cor_jogador = cor
	tipo_jogador = tipo
	
func atualizar_mouse_entered():
	if ($AnimatedSprite2D.is_playing() or mouse_over)\
		and tipo_jogador == Jogador.TipoJogador.Humano\
		and not coluna_bloqueada:
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.play(animacao_fantasma)
	else:
		$AnimatedSprite2D.visible = false
		$AnimatedSprite2D.stop()

func _on_mouse_entered() -> void:
	mouse_over = true
	
	if tipo_jogador == Jogador.TipoJogador.Humano and not coluna_bloqueada:
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play(animacao_fantasma)

func _on_mouse_exited() -> void:
	mouse_over = false

	$AnimatedSprite2D.visible = false
	$AnimatedSprite2D.stop()
