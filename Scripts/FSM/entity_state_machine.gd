extends Node
class_name StateMachine

enum EnemyStates {
	IDLE,
	HURT,
	STUN
}

var current_state: EnemyStates = EnemyStates.IDLE
var states: Dictionary = {}

func init(enemy: CharacterBody2D, idle: EnemyState, hurt: EnemyState, stun: EnemyState) -> void:
	states[EnemyStates.IDLE] = idle
	states[EnemyStates.HURT] = hurt
	states[EnemyStates.STUN] = stun

	# Inject the enemy reference into every state
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
			print("→ IDLE")
		EnemyStates.HURT:
			print("→ HURT")
		EnemyStates.STUN:
			print("→ STUN")

	states[current_state].enter()

func update(delta: float) -> void:
	states[current_state].update(delta)

func physics_update(delta: float) -> void:
	states[current_state].physics_update(delta)
