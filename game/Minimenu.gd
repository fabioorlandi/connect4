extends CanvasLayer

@onready var panel = $Panel

func _ready():
	panel.visible = false

func _input(event):
	if event.is_action_pressed("minimenu"):
		abrir_menu()
		
func abrir_menu():
	panel.visible = !panel.visible
	$som_stickynote.play()
	$som_stickynote.seek(0.2)
	
func _on_menu_icone_pressed() -> void:
	abrir_menu()
	$som_stickynote.play()
	$som_stickynote.seek(0.2)


func _on_button_pressed() -> void:
	get_tree().quit()


func _on_barra_volume_value_changed(value: float) -> void:
		AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Efeitos"),
		linear_to_db(value/100.0))


func _on_barra_volume_musica_value_changed(value: float) -> void:
		AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Musica_Fundo"),
		linear_to_db(value/100.0))


func _on_botao_fechar_pressed() -> void:
	panel.visible = false
	$som_stickynote.play()
	$som_stickynote.seek(0.2)
