extends TextureButton


var state := 0

@export var textures : Array[Texture2D]

func _pressed():
	state = (state + 1) % textures.size()
	texture_normal = textures[state]
	print(state)
