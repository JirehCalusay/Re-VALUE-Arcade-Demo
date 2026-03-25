extends Node2D

@onready var label: Label = $Label

@export var font: Font
@export var offset: Vector2 = Vector2(0, -30)  # how high above the dummy

func _ready() -> void:
	label.add_theme_font_override("font", font)
	position = offset

func set_value(value: int) -> void:
	label.text = str(value)
	label.modulate = _get_tint(value)

func _get_tint(value: int) -> Color:
	match value:
		1:  return Color(1, 1, 1)        # white
		5:  return Color(0.4, 0.8, 1)    # blue
		10: return Color(1, 0.85, 0.2)   # gold
		20: return Color(1, 0.3, 0.8)    # pink/purple
	return Color(1, 1, 1)
