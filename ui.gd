extends CanvasLayer

const FALIMER_NEUT      := preload("res://Assets/Falimer_Neut.png")
const FALIMER_HAPPY     := preload("res://Assets/Falimer_Happy.png")
const FALIMER_CONCERNED := preload("res://Assets/Falimer_Concerned.png")

const LINES_HAPPY: Array = [
	"Delicious digits!",
	"Mmm, perfectly balanced!",
	"My tummy is SO happy!",
	"That's the good math!!",
	"Yummy yummy numbers!",
	"*chef's kiss* Exquisite!",
	"Feed me MORE!!",
	"Scrumptious equation!",
	"I can taste the algebra!",
	"Magnificent! Encore!!",
]

const LINES_CONCERNED: Array = [
	"That's... not quite it.",
	"Hmm, my tummy says no.",
	"The numbers don't add up!",
	"Are you even trying??",
	"Wrong flavor of math!",
	"My gut feeling says nope.",
	"Recount! RECOUNT!",
	"I'm getting indigestion...",
	"That equation tastes OFF.",
	"Math crimes! Math crimes!",
]

const LINES_NEUT: Array = [
	"My belly is empty...",
	"Bring me something first!",
	"I can't eat nothing!!",
	"Where's my math snack?",
	"Nothing to chew on here.",
	"Go catch some numbers!",
	"Feed me equations pls.",
	"I hunger for digits!!",
	"My stomach is growling...",
	"No numbers, no service!",
]

@onready var timer_label: Label = $TopBar/TimerDisplay/TimerLabel
@onready var equation_label: Label = $EquationDisplay/EquationLabel
@onready var icon_container: HBoxContainer = $CaptureBar/SlotWrapper/IconContainer
@onready var score_label: Label = $TopBar/ScoreDisplay/ScoreLabel
@onready var difficulty_label: Label = $DifficultyDisplay/DifficultyLabel
@onready var slot_graphic: TextureRect = $CaptureBar/SlotWrapper/SlotGraphic

@export var dummy_icon: Texture2D
@export var font: Font

const MAX_SLOTS = 10

var score: int = 0

# each entry is { label: Label, icon: TextureRect }
var slot_nodes: Array = []
var _reaction_node: Control = null
var _reaction_tween: Tween = null

func _ready() -> void:
	_apply_font()
	_build_slots()
	_connect_signals()
	await get_tree().process_frame
	await get_tree().process_frame  # two frames ensures layout is fully calculated
	_align_icon_container()
	icon_container.add_theme_constant_override("separation", 16)

func _align_icon_container() -> void:
	var slot_rect = slot_graphic.get_global_rect()
	var h_padding = 156.0
	var v_padding = 10.0
	icon_container.global_position = slot_rect.position + Vector2(h_padding / 2, v_padding / 2)
	icon_container.size = slot_rect.size - Vector2(h_padding, v_padding)
	icon_container.clip_contents = true

func _apply_font() -> void:
	timer_label.add_theme_font_override("font", font)
	equation_label.add_theme_font_override("font", font)
	score_label.add_theme_font_override("font", font)
	score_label.text = "Score: %02d" % score
	difficulty_label.add_theme_font_override("font", font)

# ── Build Slots ───────────────────────────────────────────────
func _build_slots() -> void:
	icon_container.alignment = BoxContainer.ALIGNMENT_CENTER
	icon_container.size_flags_horizontal = Control.SIZE_FILL
	icon_container.size_flags_vertical = Control.SIZE_FILL

	for i in MAX_SLOTS:
		# wrapper: stacks label on top of icon vertically
		var slot = VBoxContainer.new()
		slot.alignment = BoxContainer.ALIGNMENT_CENTER
		slot.custom_minimum_size = Vector2(40, 56)
		slot.size_flags_horizontal = Control.SIZE_FILL

		# value label sits above the icon
		var label = Label.new()
		label.text = ""
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 10)
		label.visible = false

		# the dummy icon
		var icon = TextureRect.new()
		icon.texture = dummy_icon
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(40, 40)
		icon.visible = false

		slot.add_child(label)
		slot.add_child(icon)
		icon_container.add_child(slot)

		slot_nodes.append({ "label": label, "icon": icon })

# ── Signals ───────────────────────────────────────────────────
func _connect_signals() -> void:
	GameData.target_changed.connect(_on_target_changed)
	GameData.inventory_changed.connect(_on_inventory_changed)
	GameData.turnover_success.connect(func(_b): _show_falimer_reaction(FALIMER_HAPPY, LINES_HAPPY))
	GameData.turnover_failed.connect(func(): _show_falimer_reaction(FALIMER_CONCERNED, LINES_CONCERNED))
	GameData.turnover_empty.connect(func(): _show_falimer_reaction(FALIMER_NEUT, LINES_NEUT))

func _on_inventory_changed() -> void:
	update_slots(GameData.captured_enemies)

# ── Score ────────────────────────────────────────────────────
func add_score(amount: int) -> void:
	score += amount
	score_label.text = "Score: %02d" % score

# ── Difficulty ───────────────────────────────────────────────
const DIFFICULTY_LABELS: Array = [
	"Piece of Cake",
	"Getting Spicy",
	"Bananas",
	"Total Chaos"
]

func update_difficulty(turnover_count: int) -> void:
	var tier: int = mini(turnover_count / 10, DIFFICULTY_LABELS.size() - 1)
	difficulty_label.text = DIFFICULTY_LABELS[tier]

# ── Timer ─────────────────────────────────────────────────────
func update_timer(seconds: float) -> void:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]
	timer_label.modulate = Color(1, 0.2, 0.2) if seconds <= 15.0 else Color(1, 1, 1)

# ── Equation ──────────────────────────────────────────────────
func _on_target_changed(_target: int, equation: String) -> void:
	equation_label.text = equation

# ── Capture Slots ─────────────────────────────────────────────
func update_slots(captured: Array) -> void:
	for i in MAX_SLOTS:
		var slot = slot_nodes[i]
		if i < captured.size():
			var value = captured[i]["value"]
			var tint = _get_dummy_tint(value)
			slot["icon"].visible = true
			slot["icon"].modulate = tint
			slot["label"].visible = true
			slot["label"].text = str(value)
			slot["label"].modulate = tint
		else:
			slot["icon"].visible = false
			slot["label"].visible = false
			slot["label"].text = ""

# ── Falimer Reaction ─────────────────────────────────────────
func _show_falimer_reaction(texture: Texture2D, lines: Array) -> void:
	# Kill any existing reaction
	if _reaction_tween and _reaction_tween.is_valid():
		_reaction_tween.kill()
	if _reaction_node:
		_reaction_node.queue_free()
		_reaction_node = null

	# Root container — anchored bottom-right, moves as one during peek
	var root := Control.new()
	root.anchor_left   = 1.0
	root.anchor_right  = 1.0
	root.anchor_top    = 1.0
	root.anchor_bottom = 1.0
	root.offset_left   = -280.0
	root.offset_right  = -20.0
	root.offset_top    = -340.0
	root.offset_bottom = 0.0
	root.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	root.grow_vertical   = Control.GROW_DIRECTION_BEGIN
	add_child(root)
	_reaction_node = root

	# Text box — styled panel, sits above the sprite
	var panel := PanelContainer.new()
	panel.anchor_left   = 0.0
	panel.anchor_right  = 1.0
	panel.anchor_top    = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_top    = 0.0
	panel.offset_bottom = 80.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.1, 0.28, 0.92)
	panel_style.set_border_width_all(2)
	panel_style.border_color = Color(0.4, 0.5, 1.0, 1)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	root.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var line: String = lines[randi() % lines.size()]
	var lbl := Label.new()
	lbl.text = line
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_override("font", font)
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	lbl.add_theme_color_override("font_outline_color", Color(0.2, 0.24, 0.57))
	lbl.add_theme_constant_override("outline_size", 6)
	margin.add_child(lbl)

	# Falimer sprite — bottom of the container
	var img := TextureRect.new()
	img.texture = texture
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.anchor_left   = 0.0
	img.anchor_right  = 1.0
	img.anchor_top    = 1.0
	img.anchor_bottom = 1.0
	img.offset_top    = -250.0
	img.offset_bottom = 0.0
	img.grow_horizontal = Control.GROW_DIRECTION_BOTH
	img.grow_vertical   = Control.GROW_DIRECTION_BEGIN
	root.add_child(img)

	# Peek animation: start hidden below, slide up, hold, slide back down
	var peek_distance := 340.0
	root.offset_top    += peek_distance
	root.offset_bottom += peek_distance

	_reaction_tween = create_tween()
	_reaction_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	# Peek up
	_reaction_tween.tween_property(root, "offset_top",    root.offset_top    - peek_distance, 0.35)
	_reaction_tween.parallel().tween_property(root, "offset_bottom", root.offset_bottom - peek_distance, 0.35)
	# Hold for 3 seconds
	_reaction_tween.tween_interval(3.0)
	# Peek back down
	_reaction_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_reaction_tween.tween_property(root, "offset_top",    root.offset_top    + peek_distance, 0.35)
	_reaction_tween.parallel().tween_property(root, "offset_bottom", root.offset_bottom + peek_distance, 0.35)
	# Clean up
	_reaction_tween.tween_callback(func():
		if _reaction_node:
			_reaction_node.queue_free()
			_reaction_node = null
	)

func _get_dummy_tint(value: int) -> Color:
	match value:
		1:  return Color(1, 1, 1)
		5:  return Color(0.4, 0.8, 1)
		10: return Color(1, 0.85, 0.2)
		20: return Color(1, 0.3, 0.8)
	return Color(1, 1, 1)
