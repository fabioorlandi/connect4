extends Node2D

func jogar_peca(posicao: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", posicao.y, 0.6)\
	.set_trans(Tween.TRANS_BOUNCE)\
	.set_ease(Tween.EASE_OUT)
