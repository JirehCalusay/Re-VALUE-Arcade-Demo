extends Node
class_name KnockbackComponent

signal kg_changed(current_kg: int)
signal knockback_launched(direction: Vector2)
signal immobilized()

# slight pushback ranges — KG 1 and 2
@export var pushback_min: float = 60.0
@export var pushback_max: float = 120.0

# launch ranges — KG 3
@export var launch_force_min: float = 300.0
@export var launch_force_max: float = 500.0
@export var launch_up_min: float = 200.0
@export var launch_up_max: float = 400.0

@export var kg_reset_time: float = 5.5

var current_kg: int = 0
var _reset_timer: float = 0.0
var _is_timing: bool = false

func _process(delta: float) -> void:
	if not _is_timing:
		return

	_reset_timer -= delta

	if _reset_timer <= 0.0:
		reset_kg()

func add_kg(hit_direction: Vector2) -> void:
	current_kg += 1
	_reset_timer = kg_reset_time
	_is_timing = true

	kg_changed.emit(current_kg)

	match current_kg:
		1:
			immobilized.emit()
			var force = randf_range(pushback_min, pushback_max)
			knockback_launched.emit(hit_direction * force)
		2:
			immobilized.emit()
			var force = randf_range(pushback_min, pushback_max) * 1.5  # slightly stronger
			knockback_launched.emit(hit_direction * force)
		3:
			var launch_x = randf_range(launch_force_min, launch_force_max)
			var launch_y = randf_range(launch_up_min, launch_up_max)
			var launch_dir = Vector2(hit_direction.x * launch_x, -launch_y)
			knockback_launched.emit(launch_dir)
			reset_kg()

func reset_kg() -> void:
	current_kg = 0
	_is_timing = false
	_reset_timer = 0.0
	kg_changed.emit(current_kg)
	
