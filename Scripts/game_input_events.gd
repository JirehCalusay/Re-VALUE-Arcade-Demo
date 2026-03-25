extends Node
class_name GameInputEvents

static var last_left_time := 0.0
static var last_right_time := 0.0
static var facing_dir := 1
const DOUBLE_TAP_TIME := 0.25

static func movement_input() -> float:
	return Input.get_axis("move_left", "move_right")

static func update_facing() -> void:
	if Input.is_action_just_pressed("move_left"):
		facing_dir = -1
	elif Input.is_action_just_pressed("move_right"):
		facing_dir = 1

static func get_facing_dir() -> int:
	return facing_dir

static func rapid_turn_input() -> int:
	if Input.is_action_just_pressed("move_left"):
		return -1
	elif Input.is_action_just_pressed("move_right"):
		return 1
	return 0

static func dash_input() -> int:
	var now = Time.get_ticks_msec() / 1000.0
	if Input.is_action_just_pressed("move_left"):
		if now - last_left_time <= DOUBLE_TAP_TIME:
			last_left_time = now
			return -1
		last_left_time = now
	if Input.is_action_just_pressed("move_right"):
		if now - last_right_time <= DOUBLE_TAP_TIME:
			last_right_time = now
			return 1
		last_right_time = now
	return 0

static func jump_input() -> float:
	return Input.is_action_just_pressed("jump")

# ── renamed from attack_add/attack_minus ──────────────────────
static func attack_damage() -> bool:
	return Input.is_action_just_pressed("attack")   # K key

static func attack_capture() -> bool:
	return Input.is_action_just_pressed("capture")  # J key
	
static func merge_release() -> bool:
	return Input.is_action_just_pressed("merge-release")  # J key
	
