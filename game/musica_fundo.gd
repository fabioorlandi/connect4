extends AudioStreamPlayer

func _ready():
	play()

	finished.connect(func():
		play()
	)
