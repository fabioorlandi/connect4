extends TextureButton

var estado := 0
@export var dificuldade: Dificuldade.SeletorDificuldade

@export var textures : Array[Texture2D]

func _pressed():
	estado = (estado + 1) % textures.size()
	texture_normal = textures[estado]
	print(estado)

	if estado == 0:
		dificuldade = Dificuldade.SeletorDificuldade.Facil
	elif estado == 1:
		dificuldade = Dificuldade.SeletorDificuldade.Medio
	elif estado == 2:
		dificuldade = Dificuldade.SeletorDificuldade.Dificil
