extends CanvasLayer

const FONT := preload("res://Assets/RE:VALUE ASSETS/fibberish.otf")
const CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

var char_indices := [0, 0, 0]
var cursor: int = 0
var name_confirmed: bool = false
var final_score: int = 0

var _score_label: Label
var _char_labels: Array = []
var _name_entry: HBoxContainer
var _prompt_label: Label
var _enter_name_label: Label
var _hint_label: Label

func _ready() -> void:
	_build_ui()
	set_process_input(false)

func _build_ui() -> void:
	# Dark dim
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0.05, 0.78)
	add_child(dim)

	# Center panel
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -300.0
	panel.offset_top = -240.0
	panel.offset_right = 300.0
	panel.offset_bottom = 240.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.28, 0.92)
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
	vbox.add_theme_constant_override("separation", 20)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	# Game Over title
	var go_lbl := Label.new()
	go_lbl.text = "GAME OVER"
	go_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_lbl.add_theme_font_override("font", FONT)
	go_lbl.add_theme_font_size_override("font_size", 80)
	go_lbl.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	go_lbl.add_theme_color_override("font_outline_color", Color(0.5, 0.05, 0.05))
	go_lbl.add_theme_constant_override("outline_size", 24)
	vbox.add_child(go_lbl)

	# Score
	_score_label = Label.new()
	_score_label.text = "Score: 0"
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score_label.add_theme_font_override("font", FONT)
	_score_label.add_theme_font_size_override("font_size", 48)
	_score_label.add_theme_color_override("font_outline_color", Color(0.2, 0.24, 0.57))
	_score_label.add_theme_constant_override("outline_size", 14)
	vbox.add_child(_score_label)

	# Enter name label
	_enter_name_label = Label.new()
	_enter_name_label.text = "Enter your name"
	_enter_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_enter_name_label.add_theme_font_override("font", FONT)
	_enter_name_label.add_theme_font_size_override("font_size", 24)
	_enter_name_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	vbox.add_child(_enter_name_label)

	# 3-char name entry
	_name_entry = HBoxContainer.new()
	_name_entry.alignment = BoxContainer.ALIGNMENT_CENTER
	_name_entry.add_theme_constant_override("separation", 16)
	vbox.add_child(_name_entry)

	for i in 3:
		var lbl := Label.new()
		lbl.text = "A"
		lbl.custom_minimum_size = Vector2(60, 0)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_override("font", FONT)
		lbl.add_theme_font_size_override("font_size", 64)
		lbl.add_theme_color_override("font_outline_color", Color(0.2, 0.24, 0.57))
		lbl.add_theme_constant_override("outline_size", 18)
		_name_entry.add_child(lbl)
		_char_labels.append(lbl)

	# Hint
	_hint_label = Label.new()
	_hint_label.text = "UP/DOWN: change  LEFT/RIGHT: move  ENTER: confirm"
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_override("font", FONT)
	_hint_label.add_theme_font_size_override("font_size", 20)
	_hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	vbox.add_child(_hint_label)

	# Prompt
	_prompt_label = Label.new()
	_prompt_label.text = ""
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.add_theme_font_override("font", FONT)
	_prompt_label.add_theme_font_size_override("font_size", 28)
	_prompt_label.add_theme_color_override("font_outline_color", Color(0.2, 0.24, 0.57))
	_prompt_label.add_theme_constant_override("outline_size", 10)
	vbox.add_child(_prompt_label)

func show_game_over(score: int) -> void:
	final_score = score
	_score_label.text = "Score: %d" % score
	_update_char_display()
	visible = true
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not name_confirmed:
		_handle_name_input(event)
	else:
		if event is InputEventKey and event.pressed:
			_go_to_menu()

func _handle_name_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	match event.keycode:
		KEY_UP:
			char_indices[cursor] = (char_indices[cursor] + 1) % CHARS.length()
			_update_char_display()
		KEY_DOWN:
			char_indices[cursor] = (char_indices[cursor] - 1 + CHARS.length()) % CHARS.length()
			_update_char_display()
		KEY_LEFT:
			cursor = max(cursor - 1, 0)
			_update_char_display()
		KEY_RIGHT:
			cursor = min(cursor + 1, 2)
			_update_char_display()
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			_confirm_name()

func _update_char_display() -> void:
	for i in 3:
		var lbl: Label = _char_labels[i]
		lbl.text = CHARS[char_indices[i]]
		if i == cursor:
			lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
		else:
			lbl.add_theme_color_override("font_color", Color(1, 1, 1))

func _confirm_name() -> void:
	var player_name := ""
	for i in 3:
		player_name += CHARS[char_indices[i]]
	HighScoreManager.add_score(player_name, final_score)
	name_confirmed = true
	_name_entry.visible = false
	_enter_name_label.visible = false
	_hint_label.visible = false
	_prompt_label.text = "Press any key to continue"

func _go_to_menu() -> void:
	GameData.turnover_count = 0
	GameData.difficulty_tier = 0
	GameData.captured_enemies.clear()
	SceneTransition.change_scene("res://Scenes/main_menu.tscn")
