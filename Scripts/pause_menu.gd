extends CanvasLayer

const FONT := preload("res://Assets/RE:VALUE ASSETS/fibberish.otf")

var _level_manager: Node = null

func _ready() -> void:
	_build_ui()
	set_process_input(false)

func _build_ui() -> void:
	# Dim overlay
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0.05, 0.72)
	add_child(dim)

	# Center panel
	var panel := PanelContainer.new()
	panel.anchor_left   = 0.5
	panel.anchor_top    = 0.5
	panel.anchor_right  = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left   = -220.0
	panel.offset_top    = -200.0
	panel.offset_right  = 220.0
	panel.offset_bottom = 200.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical   = Control.GROW_DIRECTION_BOTH
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.28, 0.95)
	style.set_border_width_all(3)
	style.border_color = Color(0.4, 0.5, 1.0, 1)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	margin.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FONT)
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_outline_color", Color(0.2, 0.24, 0.57))
	title.add_theme_constant_override("outline_size", 22)
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	# Resume button
	var resume_btn := _make_button("Resume")
	resume_btn.pressed.connect(_on_resume)
	vbox.add_child(resume_btn)

	# Main Menu button
	var menu_btn := _make_button("Main Menu")
	menu_btn.pressed.connect(_on_main_menu)
	vbox.add_child(menu_btn)

func _make_button(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(340, 68)
	btn.add_theme_font_override("font", FONT)
	btn.add_theme_font_size_override("font_size", 40)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(0.8, 0.9, 1.0))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.1, 0.13, 0.35, 0.85)
	normal.set_border_width_all(3)
	normal.border_color = Color(0.4, 0.5, 1.0, 1)
	normal.set_corner_radius_all(8)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.2, 0.25, 0.6, 0.95)
	hover.set_border_width_all(3)
	hover.border_color = Color(0.6, 0.7, 1.0, 1)
	hover.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", normal)
	return btn

func show_pause(level_manager: Node) -> void:
	_level_manager = level_manager
	get_tree().paused = true
	visible = true
	set_process_input(true)

func _on_resume() -> void:
	get_tree().paused = false
	visible = false
	set_process_input(false)

func _on_main_menu() -> void:
	get_tree().paused = false
	GameData.turnover_count = 0
	GameData.difficulty_tier = 0
	GameData.captured_enemies.clear()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_resume()
		get_viewport().set_input_as_handled()
