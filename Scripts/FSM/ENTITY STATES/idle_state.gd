extends EnemyState
class_name IdleState

@export var animated_sprite_2D: AnimatedSprite2D
@export var idle_duration: float = 0.5
var _timer: float = 0.0

func enter() -> void:
	print("→ IDLE")
	_timer = idle_duration
	animated_sprite_2D.play("idle")

	# if spawned from a split go straight to immobilized
	if enemy.spawn_immobilized:
		machine.transition_to(EnemyStateMachine.EnemyStates.IMMOBILIZED)
		return

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		machine.transition_to(EnemyStateMachine.EnemyStates.PATROL)

func exit() -> void:
	animated_sprite_2D.stop()
