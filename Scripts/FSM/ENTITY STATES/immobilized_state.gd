extends EnemyState
class_name ImmobilizedState

@export var animated_sprite_2D: AnimatedSprite2D
@export var immobilize_duration_min: float = 0.3
@export var immobilize_duration_max: float = 0.6
@export var spawn_immobilize_duration: float = 1.5
@export var friction_min: float = 400.0
@export var friction_max: float = 600.0
@export var gravity: float = 600.0   # ← controls how fast they fall back down

var _timer: float = 0.0
var _friction: float = 200.0
var _is_spawn: bool = false

func enter() -> void:
	animated_sprite_2D.play("hurt")
	_is_spawn = enemy.spawn_immobilized

	if _is_spawn:
		_timer = spawn_immobilize_duration
		enemy.spawn_immobilized = false

		# apply the stored knockback force NOW — on enter not on ready
		if enemy.spawn_knockback_force != Vector2.ZERO:
			enemy.velocity = enemy.spawn_knockback_force
			enemy.spawn_knockback_force = Vector2.ZERO
	else:
		_timer = randf_range(immobilize_duration_min, immobilize_duration_max)

	_friction = randf_range(friction_min, friction_max)

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0 and abs(enemy.velocity.x) < 10.0:
		machine.transition_to(EnemyStateMachine.EnemyStates.PATROL)

func physics_update(delta: float) -> void:
	# apply gravity so the launch arc works properly
	if not enemy.is_on_floor():
		enemy.velocity.y += gravity * get_physics_process_delta_time()

	# only apply horizontal friction, not vertical
	enemy.velocity.x = move_toward(enemy.velocity.x, 0, _friction * get_physics_process_delta_time())

	enemy.move_and_slide()

func exit() -> void:
	animated_sprite_2D.stop()
