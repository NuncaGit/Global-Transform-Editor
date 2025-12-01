@tool
extends VBoxContainer

static var show_pos = true
static var show_rot = false

var node_ref: Node3D

var sliders_pos = []
var sliders_rot = []

var row_pos: HBoxContainer
var row_rot: HBoxContainer
var btn_toggle_pos: Button
var btn_toggle_rot: Button

const COLOR_X = Color(0.96, 0.20, 0.32)
const COLOR_Y = Color(0.53, 0.84, 0.01)
const COLOR_Z = Color(0.10, 0.34, 0.90)

func setup(node):
	node_ref = node
	
	btn_toggle_pos = _create_toggle_btn("Global Position", "pos", show_pos)
	add_child(btn_toggle_pos)
	
	row_pos = HBoxContainer.new()
	row_pos.visible = show_pos
	add_child(row_pos)
	
	_create_icon_btn(row_pos, "Copy", "pos", _on_copy_click)
	_create_icon_btn(row_pos, "Paste", "pos", _on_paste_click)
	
	var panel_pos = _create_background_panel()
	row_pos.add_child(panel_pos)
	
	var sliders_container_pos = HBoxContainer.new()
	sliders_container_pos.add_theme_constant_override("separation", 0)
	panel_pos.add_child(sliders_container_pos)
	
	_build_sliders(sliders_container_pos, sliders_pos, "pos")

	btn_toggle_rot = _create_toggle_btn("Global Rotation", "rot", show_rot)
	add_child(btn_toggle_rot)
	
	row_rot = HBoxContainer.new()
	row_rot.visible = show_rot
	add_child(row_rot)
	
	_create_icon_btn(row_rot, "Copy", "rot", _on_copy_click)
	_create_icon_btn(row_rot, "Paste", "rot", _on_paste_click)
	
	var panel_rot = _create_background_panel()
	row_rot.add_child(panel_rot)
	
	var sliders_container_rot = HBoxContainer.new()
	sliders_container_rot.add_theme_constant_override("separation", 0)
	panel_rot.add_child(sliders_container_rot)
	
	_build_sliders(sliders_container_rot, sliders_rot, "rot")
	
	_update_header_icon(btn_toggle_pos, show_pos)
	_update_header_icon(btn_toggle_rot, show_rot)

func _create_background_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = EditorInterface.get_editor_theme().get_color("dark_color_2", "Editor")
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	style.content_margin_left = 4
	style.content_margin_right = 4
	
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _create_toggle_btn(text: String, type: String, is_pressed: bool) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.toggle_mode = true
	btn.button_pressed = is_pressed
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.flat = true
	btn.icon = EditorInterface.get_editor_theme().get_icon("ArrowRight", "EditorIcons")
	btn.toggled.connect(_on_header_toggled.bind(btn, type))
	return btn

func _create_icon_btn(parent, text, type, callback) -> Button:
	var btn = Button.new()
	var icon_name = "ActionCopy" if text == "Copy" else "ActionPaste"
	btn.icon = EditorInterface.get_editor_theme().get_icon(icon_name, "EditorIcons")
	btn.flat = true
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.tooltip_text = text + " Global " + ("Position" if type == "pos" else "Rotation")
	btn.modulate = Color(1, 1, 1, 0.6)
	btn.pressed.connect(callback.bind(type))
	parent.add_child(btn)
	return btn

func _build_sliders(parent, slider_array, type):
	_create_single_slider(parent, slider_array, "x", COLOR_X, type)
	_create_single_slider(parent, slider_array, "y", COLOR_Y, type)
	_create_single_slider(parent, slider_array, "z", COLOR_Z, type)

func _create_single_slider(parent, slider_array, axis, color, type):
	var slider = EditorSpinSlider.new()
	slider.size_flags_horizontal = SIZE_EXPAND_FILL
	slider.custom_minimum_size.x = 40
	slider.step = 0.001 if type == "pos" else 0.1
	slider.min_value = -99999.0
	slider.max_value = 99999.0
	slider.hide_slider = true
	slider.flat = true 
	slider.label = axis
	slider.add_theme_color_override("label_color", color)
	
	var empty_style = StyleBoxEmpty.new()
	slider.add_theme_stylebox_override("normal", empty_style)
	slider.add_theme_stylebox_override("hover", empty_style)
	slider.add_theme_stylebox_override("pressed", empty_style)
	slider.add_theme_stylebox_override("focus", empty_style)
	
	slider.value_changed.connect(_on_user_changed_value.bind(axis, type))
	parent.add_child(slider)
	slider_array.append({"obj": slider, "axis": axis})

func _on_header_toggled(pressed, btn, type):
	_update_header_icon(btn, pressed)
	if type == "pos":
		row_pos.visible = pressed
		show_pos = pressed 
	else:
		row_rot.visible = pressed
		show_rot = pressed 

func _update_header_icon(btn, pressed):
	var theme = EditorInterface.get_editor_theme()
	if pressed:
		btn.icon = theme.get_icon("ArrowDown", "EditorIcons")
	else:
		btn.icon = theme.get_icon("ArrowRight", "EditorIcons")

func _on_copy_click(type):
	if not is_instance_valid(node_ref): return
	var data_str = ""
	if type == "pos":
		data_str = "Vector3" + str(node_ref.global_position)
	else:
		data_str = "Vector3" + str(node_ref.global_rotation_degrees)
	DisplayServer.clipboard_set(data_str)
	print_rich("[color=gray]Global Copied:[/color] [color=cyan]", data_str, "[/color]")

func _on_paste_click(type):
	if not is_instance_valid(node_ref): return
	var text = DisplayServer.clipboard_get()
	if text.is_empty(): return
	var vec_val = _parse_vector3_from_string(text)
	if vec_val == null:
		print_rich("[color=red]Invalid Vector3 format.[/color]")
		return

	var undo = EditorInterface.get_editor_undo_redo()
	if not undo: return
	undo.create_action("Paste Global " + ("Position" if type == "pos" else "Rotation"))
	if type == "pos":
		undo.add_do_property(node_ref, "global_position", vec_val)
		undo.add_undo_property(node_ref, "global_position", node_ref.global_position)
	else:
		undo.add_do_property(node_ref, "global_rotation_degrees", vec_val)
		undo.add_undo_property(node_ref, "global_rotation_degrees", node_ref.global_rotation_degrees)
	undo.commit_action()

func _parse_vector3_from_string(text: String) -> Variant:
	var clean = text.replace("Vector3", "").replace("(", "").replace(")", "").replace(" ", "")
	var parts = clean.split(",")
	if parts.size() >= 3:
		if parts[0].is_valid_float() and parts[1].is_valid_float() and parts[2].is_valid_float():
			return Vector3(float(parts[0]), float(parts[1]), float(parts[2]))
	return null

func _on_user_changed_value(new_value, axis, type):
	if not is_instance_valid(node_ref): return
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
