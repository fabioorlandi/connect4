extends TextureButton

func _pressed():

	if button_pressed:
		AudioServer.set_bus_mute(
			AudioServer.get_bus_index("Master"),
			true
		)
	else:
		AudioServer.set_bus_mute(
			AudioServer.get_bus_index("Master"),
			false
		)
