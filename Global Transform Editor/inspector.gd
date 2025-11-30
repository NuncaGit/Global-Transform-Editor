@tool
extends EditorInspectorPlugin

# Pré-carrega o script visual para não dar erro de caminho
const GlobalRowScript = preload("res://addons/Global Transform Editor/global_row.gd")

func _can_handle(object):
	# Só aparece se for objeto 3D
	return object is Node3D

func _parse_begin(object):
	# Cria a linha visual e passa o objeto selecionado
	var row = GlobalRowScript.new()
	row.setup(object)
	add_custom_control(row)
