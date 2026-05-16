extends Area2D

signal jogada_na_coluna(peca_arrastavel, indice_coluna)
signal peca_construida
signal peca_destruida

@onready var peca_vermelha = "res://Assets/peca_vermelha.png"
@onready var peca_amarela = "res://Assets/peca_amarela.png"
@onready var peca_amarela_mesa = "res://Assets/peca_amarela_mesa.png"
@onready var peca_vermelha_mesa = "res://Assets/peca_vermelha_mesa.png"

var cor_jogador := Jogador.Cor.Nenhum
var mouse_over := false
var dragging := false
var posicao_inicial: Vector2
var hovering_columns: Array[Area2D] = []

func _process(delta):
	var cor_peca = peca_amarela if cor_jogador == Jogador.Cor.Amarelo else peca_vermelha
	var cor_peca_mesa = peca_amarela_mesa if cor_jogador == Jogador.Cor.Amarelo else peca_vermelha_mesa
		
	if mouse_over and Input.is_action_just_pressed("click") and not Global2D.is_dragging:
		self.mudar_textura_jogador(cor_peca)
		self.scale = Vector2(0.4, 0.4)
		self.z_index = 7
		
		posicao_inicial = global_position
		dragging = true
		Global2D.is_dragging = true

	if dragging and Input.is_action_pressed("click"):
		global_position = get_global_mouse_position()

	if dragging and Input.is_action_just_released("click"):
		dragging = false
		Global2D.is_dragging = false
		self.mudar_textura_jogador(cor_peca_mesa)

		if hovering_columns.size() > 0:
			var coluna = hovering_columns[-1]
			jogada_na_coluna.emit(self, coluna.indice_coluna)

		global_position = posicao_inicial

func _on_mouse_entered():
	if not Global2D.is_dragging:
		mouse_over = true
		scale = Vector2(0.55, 0.55)

func _on_mouse_exited():
	if not dragging:
		mouse_over = false
		scale = Vector2(0.4, 0.4)

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

func construir_peca_arrastavel(posicao: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position:x", posicao.x, 0.4)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_OUT)
	await tween.finished
	
	peca_construida.emit()

func destruir_peca_arrastavel(posicao: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position:x", posicao.x, 0.4)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_IN)
	await tween.finished

	peca_destruida.emit()
