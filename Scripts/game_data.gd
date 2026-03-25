extends Node

var global_target_value: int = 0
var current_equation: String = ""
var _capture_candidates: Array = []  # collects enemies hit this frame
var _capture_pending: bool = false

# ── Capture Inventory ─────────────────────────────────────────
const MAX_SLOTS = 10
var captured_enemies: Array = []   # stores dictionaries {value, hp}

signal target_changed(new_target: int, equation: String)
signal inventory_changed()
signal spawn_enemy(value: int, position: Vector2)  # listened to by the level to spawn the enemy node
signal turnover_success(score_bonus: int)  # emitted when a correct turnover happens

# ── Turnover ──────────────────────────────────────────────────
var turnover_count: int = 0
var difficulty_tier: int = 0  # 0–3, updated on each turnover

# ── Merge Rules (how many of X combine into Y) ────────────────
const MERGE_RULES: Array = [
	{"count": 5, "from": 1,  "into": 5},
	{"count": 2, "from": 5,  "into": 10},
	{"count": 2, "from": 10, "into": 20},
]

var player_ref: Node = null  # set this from your level: GlobalCapture.player_ref = $Player
const SPAWN_RADIUS: float = 150.0

# ── Capture ────────────────────────────────────────────────────
func try_capture(enemy_value: int, enemy_hp: float) -> bool:
	if captured_enemies.size() >= MAX_SLOTS:
		print("Slots full — cannot capture")
		return false

	captured_enemies.append({
		"value": enemy_value,
		"hp":    enemy_hp
	})
	print("Captured Value: ", enemy_value, " | Slots: ", captured_enemies.size(), "/", MAX_SLOTS)
	_sort_inventory()
	inventory_changed.emit()

	_check_merge()
	return true

# ── Merge Check (one pass only) ───────────────────────────────
func _check_merge() -> void:
	for rule in MERGE_RULES:
		var from_value: int   = rule["from"]
		var needed_count: int = rule["count"]
		var into_value: int   = rule["into"]

		# Count how many slots hold this value
		var indices: Array = []
		for i in range(captured_enemies.size()):
			if captured_enemies[i]["value"] == from_value:
				indices.append(i)
			if indices.size() == needed_count:
				break

		if indices.size() == needed_count:
			# Remove merged slots (reverse order to keep indices valid)
			indices.sort()
			indices.reverse()
			for i in indices:
				captured_enemies.remove_at(i)

			print("Merged ", needed_count, "×", from_value, " → spawning ", into_value)
			_sort_inventory()
			inventory_changed.emit()
			_spawn_near_player(into_value)
			return  # only one merge per capture

# ── Spawn ──────────────────────────────────────────────────────
func _spawn_near_player(value: int) -> void:
	var spawn_pos := Vector2.ZERO

	if player_ref != null:
		# PI to TAU = bottom half, 0 to PI = top half (in Godot Y-down, negative Y is up)
		# So we use angle range of -PI to 0 to bias upward
		var angle := randf_range(-PI, 0.0)
		spawn_pos = player_ref.global_position + Vector2(
			cos(angle), sin(angle)
		) * randf_range(SPAWN_RADIUS * 0.5, SPAWN_RADIUS)
	else:
		push_warning("GlobalCapture: player_ref not set — spawning at origin")

	spawn_enemy.emit(value, spawn_pos)

# ── Release ───────────────────────────────────────────────────
func release_last() -> bool:
	if captured_enemies.is_empty():
		print("Nothing to release")
		return false

	var entry = captured_enemies.pop_back()
	print("Released Value: ", entry["value"], " | Slots: ", captured_enemies.size(), "/", MAX_SLOTS)
	_sort_inventory()
	inventory_changed.emit()
	_spawn_near_player(entry["value"])
	return true

# ── Turnover ──────────────────────────────────────────────────
func try_turnover(time_remaining: float) -> bool:
	if captured_enemies.is_empty():
		print("Turnover failed — inventory empty")
		return false

	var total: int = 0
	for entry in captured_enemies:
		total += entry["value"]

	print("Turnover attempt — total: ", total, " | target: ", global_target_value)

	if total != global_target_value:
		print("Turnover failed — value mismatch")
		return false

	# Success
	turnover_count += 1
	var bonus: int = int(time_remaining)
	print("Turnover success #", turnover_count, " | Score bonus: ", bonus)
	clear_inventory()
	turnover_success.emit(bonus)
	return true

# ── Sort ──────────────────────────────────────────────────────
func _sort_inventory() -> void:
	captured_enemies.sort_custom(func(a, b): return a["value"] > b["value"])

# ── Utility ───────────────────────────────────────────────────
func clear_inventory() -> void:
	captured_enemies.clear()
	inventory_changed.emit()

# ── Capture (nearest only) ─────────────────────────────────────
func register_capture_candidate(enemy: Node) -> void:
	_capture_candidates.append(enemy)
	if not _capture_pending:
		_capture_pending = true
		# defer to end of frame so all candidates register first
		_resolve_capture.call_deferred()

func _resolve_capture() -> void:
	_capture_pending = false
	if _capture_candidates.is_empty():
		return

	if player_ref == null:
		_capture_candidates.clear()
		return

	# Find the nearest candidate to the player
	var nearest: Node = null
	var nearest_dist: float = INF
	for enemy in _capture_candidates:
		if not is_instance_valid(enemy):
			continue
		var dist = player_ref.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy

	_capture_candidates.clear()

	if nearest == null:
		return

	# Now capture only that one
	var success = try_capture(nearest.enemy_value, nearest.current_hp)
	if success:
		nearest.queue_free()
	else:
		print("Slots full — nearest enemy not captured")
