extends Node2D

func jogar_peca(posicao: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", posicao.y, 0.6)\
	.set_trans(Tween.TRANS_BOUNCE)\
	.set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished

func mudar_textura_jogador(caminho_arquivo_textura: String) -> void:
	$Sprite2D.texture = load(caminho_arquivo_textura)

func iniciar_animacao_vitoria(animacao_vitoria: String) -> void:
	$Sprite2D.visible = false
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play(animacao_vitoria)
