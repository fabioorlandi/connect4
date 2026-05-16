extends Area2D

signal coluna_selecionada(indice_coluna)
signal mudar_cor_jogador(cor_jogador)
signal atualizar_hover(animacao)

@export var indice_coluna := 0
var animacao_fantasma = "peca_fantasma_amarela"
var cor_jogador = Jogador.Cor.Amarelo
var mostrar_animacao = true

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not Global2D.is_dragging:
				coluna_selecionada.emit(indice_coluna)

func mudar_fantasma_jogador(cor):
	animacao_fantasma = "peca_fantasma_amarela" if cor == Jogador.Cor.Amarelo else "peca_fantasma_vermelha"
	cor_jogador = cor
	
func atualizar_mouse_entered(atualizar_animacao):
	mostrar_animacao = atualizar_animacao
	
	if not mostrar_animacao:
		$AnimatedSprite2D.visible = false
		$AnimatedSprite2D.stop()
	elif $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.play(animacao_fantasma)

func _on_mouse_entered() -> void:
	if mostrar_animacao:
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play(animacao_fantasma)

func _on_mouse_exited() -> void:
	$AnimatedSprite2D.visible = false
	$AnimatedSprite2D.stop()
