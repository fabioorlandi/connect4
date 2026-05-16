extends Area2D

signal coluna_selecionada(indice_coluna)

@export var indice_coluna := 0

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not Global2D.is_dragging:
				coluna_selecionada.emit(indice_coluna)


func _on_mouse_entered() -> void:
	
	$AnimatedSprite2D.visible = true 
	
	$AnimatedSprite2D.play("peca_fantasma")


func _on_mouse_exited() -> void:
	$AnimatedSprite2D.visible = false 
	$AnimatedSprite2D.stop()
