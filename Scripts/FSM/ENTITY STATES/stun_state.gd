extends EnemyState
class_name StunState

@export var character_body_2D: CharacterBody2D
@export var animated_sprite_2D: AnimatedSprite2D
@export var stun_duration: float = 3.0

var _stun_timer: float = 0.0
var _is_stunned: bool = false

func enter() -> void:
	_stun_timer = stun_duration
	_is_stunned = true
	animated_sprite_2D.play("stunbreak")
	# show HP bar here

func update(delta: float) -> void:
	if not _is_stunned:
		return

	_stun_timer -= delta

	# still apply knockback physics during stun
	enemy.velocity.x = move_toward(enemy.velocity.x, 0, 200.0)

	if _stun_timer <= 0.0:
		_end_stun()

func physics_update(delta: float) -> void:
	if _is_stunned:
		enemy.move_and_slide()

func handle_attack(attack_type: String, hit_direction: Vector2) -> void:
	if not _is_stunned:
		return

	# during stun all damage comes from calculate_damage() on the enemy
	# nothing needed here unless you want stun-specific behavior later
	print("HP remaining: ", enemy.current_hp)

	if enemy.current_hp <= 0:
		enemy.hurt_box.on_hurt_box_died.emit()
		machine.transition_to(EnemyStateMachine.EnemyStates.DEAD)
	
func _end_stun() -> void:
	_is_stunned = false
	enemy.knockback_component.reset_kg()

	if enemy.hp <= 0:
		enemy.hurt_box.on_hurt_box_died.emit()
		machine.transition_to(EnemyStateMachine.EnemyStates.DEAD)
	else:
		# re-read from global target instead of randomizing
		enemy.enemy_value = GameData.global_target_value + randi_range(1, 10)
		enemy.target_value = GameData.global_target_value
		machine.transition_to(EnemyStateMachine.EnemyStates.CHASE)

func exit() -> void:
	_is_stunned = false
	animated_sprite_2D.stop()
	# hide HP bar here
