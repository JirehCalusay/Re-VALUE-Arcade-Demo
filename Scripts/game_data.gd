extends Node

var global_target_value: int = 0
var current_equation: String = ""

# ── Capture Inventory ─────────────────────────────────────────
const MAX_SLOTS = 10
var captured_enemies: Array = []   # stores dictionaries {value, hp}

signal target_changed(new_target: int, equation: String)
signal inventory_changed()         # fires whenever slots update

func try_capture(enemy_value: int, enemy_hp: float) -> bool:
	if captured_enemies.size() >= MAX_SLOTS:
		print("Slots full — cannot capture")
		return false

	captured_enemies.append({
		"value": enemy_value,
		"hp": enemy_hp
	})

	print("Captured Value: ", enemy_value, " | Slots: ", captured_enemies.size(), "/", MAX_SLOTS)
	inventory_changed.emit()
	return true

func clear_inventory() -> void:
	captured_enemies.clear()
	inventory_changed.emit()
	
