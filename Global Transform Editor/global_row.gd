@tool
extends VBoxContainer

# --- MEMÓRIA GLOBAL ---
static var show_pos = true
static var show_rot = false

var node_ref: Node3D

var sliders_pos = []
var sliders_rot = []

var container_pos: HBoxContainer
var container_rot: HBoxContainer
var btn_toggle_pos: Button
var btn_toggle_rot: Button

const COLOR_X = Color(0.96, 0.20, 0.32)
const COLOR_Y = Color(0.53, 0.84, 0.01)
const COLOR_Z = Color(0.10, 0.34, 0.90)

func setup(node):
	node_ref = node
	
	# --- SEÇÃO DE POSIÇÃO ---
	btn_toggle_pos = _create_header("Global Position", "pos", show_pos)
	container_pos = _create_row_container()
	container_pos.visible = show_pos
	
	_create_action_button(container_pos, "Copy", "pos")
	_build_sliders(container_pos, sliders_pos, "pos")
	add_child(container_pos)

	# --- SEÇÃO DE ROTAÇÃO ---
	btn_toggle_rot = _create_header("Global Rotation", "rot", show_rot)
	container_rot = _create_row_container()
	container_rot.visible = show_rot 
	
	_create_action_button(container_rot, "Copy", "rot")
	_build_sliders(container_rot, sliders_rot, "rot")
	add_child(container_rot)
	
	_update_header_icon(btn_toggle_pos, show_pos)
	_update_header_icon(btn_toggle_rot, show_rot)

func _create_header(text: String, type: String, is_pressed: bool) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.toggle_mode = true
	btn.button_pressed = is_pressed
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.flat = true
	btn.icon = EditorInterface.get_editor_theme().get_icon("ArrowRight", "EditorIcons")
	btn.toggled.connect(_on_header_toggled.bind(btn, type))
	add_child(btn)
	return btn

func _create_row_container() -> HBoxContainer:
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	return hbox

func _create_action_button(parent, text, type):
	var btn = Button.new()
	btn.text = text
	btn.auto_translate = false # Impede tradução para "Copiar"
	btn.flat = true
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.tooltip_text = "Copy Global " + ("Position" if type == "pos" else "Rotation")
	btn.modulate = Color(1, 1, 1, 0.5)
	btn.pressed.connect(_on_copy_click.bind(type))
	parent.add_child(btn)

func _build_sliders(parent, slider_array, type):
	_create_single_slider(parent, slider_array, "x", COLOR_X, type)
	_create_single_slider(parent, slider_array, "y", COLOR_Y, type)
	_create_single_slider(parent, slider_array, "z", COLOR_Z, type)

func _create_single_slider(parent, slider_array, axis, color, type):
	var slider = EditorSpinSlider.new()
	slider.size_flags_horizontal = SIZE_EXPAND_FILL
	slider.custom_minimum_size.x = 60
	slider.step = 0.001 if type == "pos" else 0.1
	slider.min_value = -99999.0
	slider.max_value = 99999.0
	slider.hide_slider = true
	slider.flat = true
	slider.label = axis
	slider.add_theme_color_override("label_color", color)
	slider.value_changed.connect(_on_user_changed_value.bind(axis, type))
	parent.add_child(slider)
	slider_array.append({"obj": slider, "axis": axis})

func _on_header_toggled(pressed, btn, type):
	_update_header_icon(btn, pressed)
	if type == "pos":
		container_pos.visible = pressed
		show_pos = pressed 
	else:
		container_rot.visible = pressed
		show_rot = pressed 

func _update_header_icon(btn, pressed):
	var theme = EditorInterface.get_editor_theme()
	if pressed:
		btn.icon = theme.get_icon("ArrowDown", "EditorIcons")
	else:
		btn.icon = theme.get_icon("ArrowRight", "EditorIcons")

func _on_copy_click(type):
	if not is_instance_valid(node_ref): return
	var data = ""
	if type == "pos":
		data = "Vector3" + str(node_ref.global_position)
	else:
		data = "Vector3" + str(node_ref.global_rotation_degrees)
	DisplayServer.clipboard_set(data)
	print_rich("[color=gray]Global Copied:[/color] [color=cyan]", data, "[/color]")

# --- AQUI ESTAVA O ERRO ---
func _on_user_changed_value(new_value, axis, type):
	if not is_instance_valid(node_ref): return
	
	# CORREÇÃO: Usamos get_editor_undo_redo() direto da interface
	var undo = EditorInterface.get_editor_undo_redo()
	
	if undo:
		undo.create_action("Set Global " + axis.to_upper())
		if type == "pos":
			var new_pos = node_ref.global_position
			new_pos[axis] = new_value
			undo.add_do_property(node_ref, "global_position", new_pos)
			undo.add_undo_property(node_ref, "global_position", node_ref.global_position)
		else:
			var new_rot = node_ref.global_rotation_degrees
			new_rot[axis] = new_value
			undo.add_do_property(node_ref, "global_rotation_degrees", new_rot)
			undo.add_undo_property(node_ref, "global_rotation_degrees", node_ref.global_rotation_degrees)
		undo.commit_action()
	else:
		if type == "pos":
			node_ref.global_position[axis] = new_value
		else:
			node_ref.global_rotation_degrees[axis] = new_value

func _process(_delta):
	if not is_instance_valid(node_ref): return
	
	if show_pos:
		var current_pos = node_ref.global_position
		for item in sliders_pos:
			var val = current_pos[item.axis]
			if not is_equal_approx(item.obj.value, val):
				item.obj.set_value_no_signal(val)

	if show_rot:
		var current_rot = node_ref.global_rotation_degrees
		for item in sliders_rot:
			var val = current_rot[item.axis]
			if not is_equal_approx(item.obj.value, val):
				item.obj.set_value_no_signal(val)
