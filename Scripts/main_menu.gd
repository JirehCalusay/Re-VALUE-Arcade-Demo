extends Node2D

const FONT := preload("res://Assets/RE:VALUE ASSETS/fibberish.otf")
const BG1  := preload("res://Assets/Enjl-Starry Space Background/background_1.png")
const BG2  := preload("res://Assets/Enjl-Starry Space Background/background_2.png")
const BG3  := preload("res://Assets/Enjl-Starry Space Background/background_3.png")
const BG4  := preload("res://Assets/Enjl-Starry Space Background/background_4.png")

var _scores_vbox: VBoxContainer

func _ready() -> void:
	SceneTransition.fade_in()
	_build_background()
	_build_ui()

# ── Background ────────────────────────────────────────────────
func _build_background() -> void:
	for pair in [
		[BG1, Vector2(10.24, 11.39)],
		[BG2, Vector2(2.03, 1.96)],
		[BG3, Vector2(1.85, 1.85)],
		[BG4, Vector2(2.02, 2.02)]
	]:
		var s := Sprite2D.new()
		s.texture = pair[0]
		s.centered = true
		s.position = Vector2(640, 360)
		s.scale = pair[1]
		add_child(s)

# ── UI ────────────────────────────────────────────────────────
func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	# ── Logo — top center ─────────────────────────────────────
	var title := Label.new()
	title.text = "Re:VALUE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_left   = 0.0
	title.anchor_right  = 1.0
	title.anchor_top    = 0.0
	title.anchor_bottom = 0.0
	title.offset_top    = 40.0
	title.offset_bottom = 160.0
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.add_theme_font_override("font", FONT)
	title.add_theme_font_size_override("font_size", 90)
	title.add_theme_color_override("font_outline_color", Color(0.2, 0.24, 0.57))
	title.add_theme_constant_override("outline_size", 28)
	root.add_child(title)

	# ── Left half — buttons ───────────────────────────────────
	var left := VBoxContainer.new()
	left.anchor_left   = 0.0
	left.anchor_right  = 0.5
	left.anchor_top    = 0.0
	left.anchor_bottom = 1.0
	left.offset_left   = 60.0
	left.offset_right  = -60.0
	left.offset_top    = 180.0
	left.offset_bottom = 0.0
	left.grow_horizontal = Control.GROW_DIRECTION_BOTH
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	left.add_theme_constant_override("separation", 28)
	root.add_child(left)

	var new_game := _make_button("New Game")
	new_game.pressed.connect(_on_new_game)
	left.add_child(new_game)

	var exit_btn := _make_button("Exit")
	exit_btn.pressed.connect(_on_exit)
	left.add_child(exit_btn)

	# ── Right half — high scores ──────────────────────────────
	var right := PanelContainer.new()
	right.anchor_left   = 0.5
	right.anchor_right  = 1.0
	right.anchor_top    = 0.0
	right.anchor_bottom = 1.0
	right.offset_left   = 20.0
	right.offset_right  = -40.0
	right.offset_top    = 180.0
	right.offset_bottom = -40.0
	right.grow_horizontal = Control.GROW_DIRECTION_BOTH
	right.grow_vertical   = Control.GROW_DIRECTION_BOTH
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.08, 0.22, 0.88)
	panel_style.set_border_width_all(2)
	panel_style.border_color = Color(0.3, 0.4, 0.9, 0.8)
	panel_style.set_corner_radius_all(10)
	right.add_theme_stylebox_override("panel", panel_style)
	root.add_child(right)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 20)
	right.add_child(margin)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 12)
	margin.add_child(inner)

	var hs_title := Label.new()
	hs_title.text = "High Scores"
	hs_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hs_title.add_theme_font_override("font", FONT)
	hs_title.add_theme_font_size_override("font_size", 42)
	hs_title.add_theme_color_override("font_outline_color", Color(0.2, 0.24, 0.57))
	hs_title.add_theme_constant_override("outline_size", 14)
	inner.add_child(hs_title)

	var divider := HSeparator.new()
	inner.add_child(divider)

	_scores_vbox = VBoxContainer.new()
	_scores_vbox.add_theme_constant_override("separation", 10)
	inner.add_child(_scores_vbox)

	_populate_scores()

# ── Button factory ────────────────────────────────────────────
func _make_button(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(360, 72)
	btn.add_theme_font_override("font", FONT)
	btn.add_theme_font_size_override("font_size", 42)
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

# ── Scores ────────────────────────────────────────────────────
func _populate_scores() -> void:
	for child in _scores_vbox.get_children():
		child.queue_free()

	var scores := HighScoreManager.get_scores()
	if scores.is_empty():
		var lbl := Label.new()
		lbl.text = "No scores yet!"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_override("font", FONT)
		lbl.add_theme_font_size_override("font_size", 26)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
		_scores_vbox.add_child(lbl)
		return

	for i in scores.size():
		var entry = scores[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)

		var rank := Label.new()
		rank.text = "%d." % (i + 1)
		rank.custom_minimum_size = Vector2(36, 0)
		rank.add_theme_font_override("font", FONT)
		rank.add_theme_font_size_override("font_size", 30)
		rank.add_theme_color_override("font_color", _rank_color(i))

		var name_lbl := Label.new()
		name_lbl.text = entry["name"]
		name_lbl.custom_minimum_size = Vector2(80, 0)
		name_lbl.add_theme_font_override("font", FONT)
		name_lbl.add_theme_font_size_override("font_size", 30)
		name_lbl.add_theme_color_override("font_color", Color(1, 1, 1))

		var score_lbl := Label.new()
		score_lbl.text = str(entry["score"])
		score_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		score_lbl.add_theme_font_override("font", FONT)
		score_lbl.add_theme_font_size_override("font_size", 30)
		score_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.2))

		row.add_child(rank)
		row.add_child(name_lbl)
		row.add_child(score_lbl)
		_scores_vbox.add_child(row)

func _rank_color(i: int) -> Color:
	match i:
		0: return Color(1.0, 0.84, 0.0)
		1: return Color(0.75, 0.75, 0.75)
		2: return Color(0.8, 0.5, 0.2)
		_: return Color(1, 1, 1)

func _on_new_game() -> void:
	GameData.turnover_count = 0
	GameData.difficulty_tier = 0
	GameData.captured_enemies.clear()
	SceneTransition.change_scene("res://Scenes/base.tscn")

func _on_exit() -> void:
	get_tree().quit()
