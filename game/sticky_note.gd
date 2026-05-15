extends TextureButton

var start_position
var start_rotation

func _ready():
	start_position = position + Vector2(randf_range(-20,20), randf_range(-10,10))
	start_rotation = rotation_degrees + randf_range(-10,10)
	
func _pressed():
	var tween = create_tween()

	tween.set_trans(Tween.TRANS_SINE)

	tween.parallel().tween_property(self,"position:y",700, 2)

	tween.parallel().tween_property(self,"position:x",position.x + randf_range(-50,50), randf_range(2.0,3.0))

	tween.parallel().tween_property(self,"rotation_degrees",randf_range(-20,20), randf_range(2.0,3.0))
	
	await tween.finished
	modulate.a = 0.0
	position = start_position
	rotation_degrees = start_rotation
	create_tween().tween_property(self,"modulate:a",1.0,0.5)
