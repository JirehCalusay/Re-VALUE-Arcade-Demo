extends Node
class_name EnemyStateMachine

enum EnemyStates {
	IDLE,
	PATROL,
	CHASE,
	IMMOBILIZED,
	HURT,
	STUN,
	DEAD
}

var current_state: EnemyStates = EnemyStates.IDLE
var states: Dictionary = {}

func init(
	enemy: CharacterBody2D,
	idle: EnemyState,
	patrol: EnemyState,
	chase: EnemyState,
	immobilized: EnemyState,
	hurt: EnemyState,
	stun: EnemyState,
	dead: EnemyState
) -> void:
	states[EnemyStates.IDLE] = idle
	states[EnemyStates.PATROL] = patrol
	states[EnemyStates.CHASE] = chase
	states[EnemyStates.IMMOBILIZED] = immobilized
	states[EnemyStates.HURT] = hurt
	states[EnemyStates.STUN] = stun
	states[EnemyStates.DEAD] = dead

	for state in states.values():
		state.enemy = enemy
		state.machine = self

	states[current_state].enter()

func transition_to(new_state: EnemyStates) -> void:
	if new_state == current_state:
		return

	states[current_state].exit()
	current_state = new_state

	match current_state:
		EnemyStates.IDLE:
			pass
		EnemyStates.PATROL:
			pass
		EnemyStates.CHASE:
			pass
		EnemyStates.IMMOBILIZED:
			pass
		EnemyStates.HURT:
			pass
		EnemyStates.STUN:
			pass
		EnemyStates.DEAD:
			pass

	states[current_state].enter()

func update(delta: float) -> void:
	states[current_state].update(delta)

func physics_update(delta: float) -> void:
	states[current_state].physics_update(delta)
	
