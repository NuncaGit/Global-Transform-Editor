@tool
extends EditorInspectorPlugin

const GlobalRowScript = preload("res://addons/Global Transform Editor/global_row.gd")

func _can_handle(object):
	return object is Node3D

func _parse_begin(object):
	var row = GlobalRowScript.new()
	row.setup(object)
	add_custom_control(row)
