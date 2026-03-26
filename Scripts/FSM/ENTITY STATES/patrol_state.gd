extends EnemyState
class_name PatrolState

@export var animated_sprite_2D: AnimatedSprite2D
@export var detection_zone: Area2D
@export var move_speed: float = 60.0
@export var point_reached_distance: float = 8.0
@export var zone_check_interval: float = 1.5

var _current_zone: PatrolZone = null
var _patrol_points: Array = []
var _current_point_index: int = 0
var _zone_check_timer: float = 0.0
var raycast: RayCast2D

@export var raycast_update_interval: float = 0.1  # updates 10 times per second
var _raycast_timer: float = 0.0

func enter() -> void:
	animated_sprite_2D.play("idle")
	raycast = enemy.get_node("RayCast2D")  # grab from enemy directly
	_assign_zone()

func update(delta: float) -> void:
	if enemy.current_patrol_zone != null and enemy.current_patrol_zone != _current_zone:
		_current_zone = enemy.current_patrol_zone
		_patrol_points = _current_zone.get_patrol_points()
		_current_point_index = 0

func physics_update(delta: float) -> void:
	var player = _get_player()
	if player and _has_line_of_sight(player):  # ← both conditions must be true
		machine.transition_to(EnemyStateMachine.EnemyStates.CHASE)
		return

	if _patrol_points.is_empty():
		return

	var target = _patrol_points[_current_point_index].global_position
	var direction = target - enemy.global_position

	if direction.x != 0:
		animated_sprite_2D.flip_h = direction.x > 0

	var height_diff = enemy.global_position.y - target.y
	if height_diff > 80.0:
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, 200.0)
	else:
		enemy.velocity.x = sign(direction.x) * move_speed

	if not enemy.is_on_floor():
		enemy.velocity.y += 20.0

	enemy.move_and_slide()

	if enemy.global_position.distance_to(target) < point_reached_distance:
		_current_point_index = (_current_point_index + 1) % _patrol_points.size()

func _has_line_of_sight(player: Node2D) -> bool:
	_raycast_timer -= get_physics_process_delta_time()

	# only update raycast when timer hits zero
	if _raycast_timer <= 0.0:
		_raycast_timer = raycast_update_interval
		raycast.target_position = raycast.to_local(player.global_position + Vector2(0, -32))
		raycast.force_raycast_update()

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if not collider.is_in_group("Player"):
			return false

	return true

func _get_player() -> Node2D:
	for body in detection_zone.get_overlapping_bodies():
		if body.is_in_group("Player"):
			return body
	return null

func _assign_zone() -> void:
	if enemy.current_patrol_zone != null:
		if enemy.current_patrol_zone != _current_zone:
			_current_zone = enemy.current_patrol_zone
			_patrol_points = _current_zone.get_patrol_points()
			_current_point_index = 0
		return

	if enemy.last_known_zone != null:
		if enemy.last_known_zone != _current_zone:
			_current_zone = enemy.last_known_zone
			_patrol_points = _current_zone.get_patrol_points()
			_current_point_index = 0
		return

	var manager = get_tree().get_first_node_in_group("PatrolZoneManager")
	if not manager:
		return

	var new_zone = manager.get_nearest_zone(enemy.global_position)
	if new_zone and new_zone != _current_zone:
		_current_zone = new_zone
		_patrol_points = _current_zone.get_patrol_points()
		_current_point_index = 0

func exit() -> void:
	enemy.velocity.x = 0.0   # ← hard stop on exit
	animated_sprite_2D.stop()
