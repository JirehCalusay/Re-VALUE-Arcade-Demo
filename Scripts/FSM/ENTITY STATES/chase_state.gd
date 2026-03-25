extends EnemyState
class_name ChaseState

@export var animated_sprite_2D: AnimatedSprite2D
@export var move_speed: float = 100.0
@export var jump_force: float = -400.0
@export var detection_zone: Area2D
@export var jump_height_threshold: float = 40.0
@export var raycast_update_interval: float = 0.1

# how long the enemy chases before caring about line of sight
@export var chase_grace_period: float = 2.0

# how long enemy can't see player before giving up
@export var lost_sight_timeout: float = 2.5

@export var jump_cooldown: float = 2.5
var _jump_timer: float = 2.5

# --- separation + offset settings ---
@export var separation_radius: float = 32.0
@export var separation_strength: float = 1.5
@export var target_offset_range: float = 40.0

var _target_offset: Vector2

var raycast: RayCast2D
var _raycast_timer: float = 0.0
var _grace_timer: float = 0.0
var _lost_sight_timer: float = 0.0
var _can_see_player: bool = false

func enter() -> void:
	animated_sprite_2D.play("idle")
	raycast = enemy.get_node("RayCast2D")

	_grace_timer = chase_grace_period
	_lost_sight_timer = 0.0
	_can_see_player = true
	_jump_timer = jump_cooldown

	# assign random offset per enemy
	_target_offset = Vector2(
		randf_range(-target_offset_range, target_offset_range),
		0
	)

func physics_update(delta: float) -> void:
	var player = _get_player()

	if not player:
		machine.transition_to(EnemyStateMachine.EnemyStates.PATROL)
		return

	if _grace_timer > 0.0:
		_grace_timer -= delta

	_raycast_timer -= delta
	if _raycast_timer <= 0.0:
		_raycast_timer = raycast_update_interval
		raycast.target_position = raycast.to_local(player.global_position + Vector2(0, -32))
		raycast.force_raycast_update()

		if raycast.is_colliding():
			var collider = raycast.get_collider()
			_can_see_player = collider.is_in_group("Player")
		else:
			_can_see_player = true

	if _grace_timer > 0.0:
		_move_toward_player(player, delta)
		return

	if _can_see_player:
		_lost_sight_timer = 0.0
		_move_toward_player(player, delta)
	else:
		_lost_sight_timer += delta

		if _lost_sight_timer >= lost_sight_timeout:
			machine.transition_to(EnemyStateMachine.EnemyStates.PATROL)
			return

		_move_toward_player(player, delta)

func _move_toward_player(player: Node2D, delta: float) -> void:
	# apply offset to player target
	var target_pos = player.global_position + _target_offset
	var direction = target_pos - enemy.global_position

	# separation force
	var separation = _get_separation_force()

	# combine direction + separation
	var combined = direction.x + separation

	# deadzone (prevents jitter)
	if abs(combined) < 0.1:
		combined = 0.0

	# desired velocity
	var dir = sign(combined)

	# deadzone still applies
	if abs(combined) < 0.1:
		dir = 0

	var desired_velocity_x = dir * move_speed

	# smooth movement (no snapping)
	enemy.velocity.x = lerp(enemy.velocity.x, desired_velocity_x, 6.0 * delta)

	# flip only when actually moving
	if abs(enemy.velocity.x) > 5:
		animated_sprite_2D.flip_h = enemy.velocity.x > 0

	# jump logic
	_jump_timer -= delta

	if direction.y < -jump_height_threshold and enemy.is_on_floor() and _jump_timer <= 0.0:
		enemy.velocity.y = jump_force
		_jump_timer = jump_cooldown

	enemy.move_and_slide()

# separation function
func _get_separation_force() -> float:
	var force := 0.0
	var neighbors = get_tree().get_nodes_in_group("Enemies")

	for other in neighbors:
		if other == enemy:
			continue

		var distance = enemy.global_position.distance_to(other.global_position)

		if distance < separation_radius and distance > 0:
			var push_dir = enemy.global_position.direction_to(other.global_position)
			force -= push_dir.x * (separation_radius - distance) / separation_radius

	# clamp to prevent overcorrection
	return clamp(force * separation_strength, -1.0, 1.0)

func _get_player() -> Node2D:
	for body in detection_zone.get_overlapping_bodies():
		if body.is_in_group("Player"):
			return body
	return null

func exit() -> void:
	enemy.velocity.x = 0.0
	animated_sprite_2D.stop()
