extends Node2D

signal peca_destruida

func jogar_peca(posicao: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", posicao.y, 0.6)\
	.set_trans(Tween.TRANS_BOUNCE)\
	.set_ease(Tween.EASE_OUT)
	$Peca_caindo.pitch_scale = randf_range(1.9, 2.0)
	$Peca_caindo.play()
	await tween.finished

func destruir_peca() -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", 600, 0.6)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	await tween.finished
	peca_destruida.emit()

	self.queue_free()

func mudar_textura_jogador(caminho_arquivo_textura: String) -> void:
	$Sprite2D.texture = load(caminho_arquivo_textura)

func iniciar_animacao_vitoria(animacao_vitoria: String) -> void:
	$Sprite2D.visible = false
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play(animacao_vitoria)
