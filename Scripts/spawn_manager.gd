extends Node

# drag your enemy packed scenes into these slots in the Inspector
@export var enemy_scenes: Array[PackedScene] = []

@export var spawn_points: Node                                 # drag SpawnPoints node here
@export var enemies_container: Node                           # drag EnemiesContainer node here

@export var base_enemies_per_wave: int = 2                    # wave 1 starts with this many
@export var enemies_increase_per_wave: int = 1                # each wave adds this many more

var current_wave: int = 0
var enemies_alive: int = 0

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)

func _ready() -> void:
	start_next_wave()

func start_next_wave() -> void:
	current_wave += 1
	print("Wave ", current_wave, " started!")

	# generate new global target for this wave
	var result = EquationGenerator.generate()
	GameData.global_target_value = result["answer"]
	GameData.current_equation = result["equation"]
	GameData.target_changed.emit(result["answer"], result["equation"])

	print("New equation: ", result["equation"])

	wave_started.emit(current_wave)
	_spawn_wave()

func _spawn_wave() -> void:
	var points = spawn_points.get_children()
	var count = base_enemies_per_wave + (current_wave - 1) * enemies_increase_per_wave

	enemies_alive = count
	print("Spawning ", count, " enemies")

	for i in count:
		var point: Marker2D = points[randi() % points.size()]
		var scene: PackedScene = enemy_scenes[randi() % enemy_scenes.size()]

		var enemy = scene.instantiate()
		enemy.enemy_value = 20          # ← always spawn as 20 at wave start
		enemy.position = point.global_position
		enemies_container.add_child(enemy)
		enemy.tree_exited.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	enemies_alive -= 1
	print("Enemies remaining: ", enemies_alive)

	if enemies_alive <= 0:
		wave_cleared.emit(current_wave)
		print("Wave ", current_wave, " cleared!")
		await get_tree().create_timer(2.0).timeout  # short pause before next wave
		start_next_wave()
