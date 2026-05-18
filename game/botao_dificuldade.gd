extends TextureButton

var estado := 0
@export var dificuldade: Dificuldade.SeletorDificuldade

@export var textures : Array[Texture2D]

func tocar_som_botao_dificuldade():
	$botaodificuldadeclique.pitch_scale = randf_range(1.5,1.6)
	$botaodificuldadeclique.play()
	$botaodificuldadeclique.seek(2.0)
	
func _pressed():
	
	estado = (estado + 1) % textures.size()
	texture_normal = textures[estado]

	if estado == 0:
		dificuldade = Dificuldade.SeletorDificuldade.Facil
	elif estado == 1:
		dificuldade = Dificuldade.SeletorDificuldade.Medio
	elif estado == 2:
		dificuldade = Dificuldade.SeletorDificuldade.Dificil
	tocar_som_botao_dificuldade()
	
