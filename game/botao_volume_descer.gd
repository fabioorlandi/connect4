extends TextureButton

@onready var barra = $"../BarraVolume"

func _pressed():
	barra.value = max(barra.value - 10, 0)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Efeitos"),
		linear_to_db(barra.value / 100.0))
