extends Node

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_points: Node
@export var enemies_container: Node

var current_wave: int = 0
var enemies_alive: int = 0

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)

# Minimum enemies that must be alive based on current max answer.
# ceil(max_answer / 20) ensures total spawnable value always >= max answer.
func _min_enemies() -> int:
	var max_answer: int = 50 + GameData.difficulty_tier * 50
	return ceili(float(max_answer) / 20.0)

func _ready() -> void:
	GameData.turnover_success.connect(_on_turnover_success)
	_spawn_up_to_minimum()
	var result = EquationGenerator.generate(GameData.turnover_count)
	GameData.global_target_value = result["answer"]
	GameData.current_equation = result["equation"]
	GameData.target_changed.emit(result["answer"], result["equation"])

func _on_turnover_success(_score_bonus: int) -> void:
	current_wave += 1
	print("Wave ", current_wave, " — topping up after turnover")
	wave_started.emit(current_wave)
	_spawn_up_to_minimum()

func _spawn_up_to_minimum() -> void:
	var minimum: int = _min_enemies()
	var to_spawn: int = max(minimum - enemies_alive, 0)

	if to_spawn == 0:
		print("Enough enemies alive (", enemies_alive, ") — no top-up needed")
		return

	print("Topping up: spawning ", to_spawn, " enemies (min: ", minimum, " | alive: ", enemies_alive, ")")
	_spawn_enemies(to_spawn)

func _spawn_enemies(count: int) -> void:
	var points = spawn_points.get_children()
	enemies_alive += count

	for i in count:
		var point: Marker2D = points[randi() % points.size()]
		var scene: PackedScene = enemy_scenes[randi() % enemy_scenes.size()]

		var enemy = scene.instantiate()
		enemy.enemy_value = 20
		enemy.position = point.global_position
		enemies_container.add_child(enemy)
		enemy.tree_exited.connect(_on_enemy_removed.bind(enemy))

func _on_enemy_removed(enemy: Node) -> void:
	# Captured enemies stay in inventory — don't count toward wave-clear
	if is_instance_valid(enemy) and enemy.was_captured:
		return

	enemies_alive -= 1
	print("Enemy removed | Alive: ", enemies_alive, " | Min: ", _min_enemies())

	# Safety net: if enemies drop below minimum, top up immediately
	if enemies_alive < _min_enemies():
		print("Below minimum — topping up")
		_spawn_up_to_minimum()

func _on_enemy_died_all() -> void:
	# Full wave clear fallback (all enemies gone without turnover)
	if enemies_alive <= 0:
		wave_cleared.emit(current_wave)
		print("Wave cleared — spawning full wave")
		await get_tree().create_timer(2.0).timeout
		current_wave += 1
		wave_started.emit(current_wave)
		_spawn_up_to_minimum()
