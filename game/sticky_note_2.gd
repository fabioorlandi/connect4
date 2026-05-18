extends TextureButton

func tocar_som_stickynote():
	$som_stickynote.play()
	$som_stickynote.seek(0.2)
func _pressed():
	tocar_som_stickynote()
