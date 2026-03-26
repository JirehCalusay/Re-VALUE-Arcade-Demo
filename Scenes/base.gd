extends Node2D

@export var camera_node_path: NodePath = "Camera2D"

@onready var spawn_manager: Node = $SpawnManager
@onready var player: Node2D   = $Player          # adjust path if nested differently

func _ready() -> void:
	SceneTransition.fade_in()
	# ── Camera resize ───────────────────────────────────────────
	var cam = get_node(camera_node_path) as Camera2D
	if cam:
		var visible_size = cam.get_camera_screen_rect().size
		DisplayServer.window_set_size(visible_size)
		var screen_size = DisplayServer.screen_get_size(0)
		var _position = (screen_size - visible_size) / 2
		DisplayServer.window_set_position(_position)

	# ── Wire capture autoload to level ──────────────────────────
	GameData.player_ref = player
	GameData.spawn_enemy.connect(_on_spawn_enemy)

func _on_spawn_enemy(value: int, position: Vector2) -> void:
	var enemies_container: Node = spawn_manager.enemies_container

	# Pick a random enemy scene from SpawnManager's list
	var scene: PackedScene = spawn_manager.enemy_scenes[
		randi() % spawn_manager.enemy_scenes.size()
	]

	var enemy = scene.instantiate()
	enemy.enemy_value = value
	enemy.global_position = position
	enemies_container.add_child(enemy)

	# Count it toward the current wave
	spawn_manager.enemies_alive += 1
	enemy.tree_exited.connect(spawn_manager._on_enemy_removed.bind(enemy))

	print("Spawned merged enemy — value: ", value, " | enemies alive: ", spawn_manager.enemies_alive)
