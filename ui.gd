extends CanvasLayer

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

func _get_dummy_tint(value: int) -> Color:
	match value:
		1:  return Color(1, 1, 1)
		5:  return Color(0.4, 0.8, 1)
		10: return Color(1, 0.85, 0.2)
		20: return Color(1, 0.3, 0.8)
	return Color(1, 1, 1)
