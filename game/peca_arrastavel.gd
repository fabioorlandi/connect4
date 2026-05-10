extends Area2D

signal jogada_na_coluna(cor_jogador, indice_coluna)

var cor_jogador := Jogador.Cor.Nenhum
var mouse_over := false
var dragging := false
var posicao_inicial: Vector2
var hovering_columns: Array[Area2D] = []

func _process(delta):
	if mouse_over and Input.is_action_just_pressed("click") and not Global2D.is_dragging:
		posicao_inicial = global_position
		dragging = true
		Global2D.is_dragging = true

	if dragging and Input.is_action_pressed("click"):
		global_position = get_global_mouse_position()

	if dragging and Input.is_action_just_released("click"):
		dragging = false
		Global2D.is_dragging = false

		if hovering_columns.size() > 0:
			var coluna = hovering_columns[-1]
			jogada_na_coluna.emit(cor_jogador, coluna.indice_coluna)
			queue_free()
		else:
			global_position = posicao_inicial

func _on_mouse_entered():
	if not Global2D.is_dragging:
		mouse_over = true
		scale = Vector2(0.75, 0.75)

func _on_mouse_exited():
	if not dragging:
		mouse_over = false
		scale = Vector2(0.5, 0.5)

func _on_area_entered(area):
	if area.is_in_group("AreaColunas"):
		hovering_columns.push_back(area)

func _on_area_exited(area):
	if area.is_in_group("AreaColunas"):
		var indice = hovering_columns.find(area)
		if indice != -1:
			hovering_columns.remove_at(indice)
			
func mudar_textura_jogador(caminho_arquivo_textura: String) -> void:
	$Sprite2D.texture = load(caminho_arquivo_textura)
