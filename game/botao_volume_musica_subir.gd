extends TextureButton

@onready var barra = $"../BarraVolumeMusica"

func _pressed():
	barra.value = min(barra.value + 10, 100)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musica_Fundo"),
		linear_to_db(barra.value / 100.0))
