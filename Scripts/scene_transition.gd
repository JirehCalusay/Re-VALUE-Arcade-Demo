extends CanvasLayer

const FADE_DURATION := 0.4

var _overlay: ColorRect
var _tween: Tween

func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 1)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

func fade_in() -> void:
	_overlay.color = Color(0, 0, 0, 1)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_overlay, "color", Color(0, 0, 0, 0), FADE_DURATION)

func change_scene(path: String) -> void:
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_overlay, "color", Color(0, 0, 0, 1), FADE_DURATION)
	_tween.tween_callback(func():
		get_tree().change_scene_to_file(path)
	)
