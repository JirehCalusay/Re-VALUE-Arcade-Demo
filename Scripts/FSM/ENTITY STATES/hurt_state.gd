extends EnemyState
class_name HurtState

@export var character_body_2D: CharacterBody2D
@export var animated_sprite_2D: AnimatedSprite2D

func enter() -> void:
	_play_hurt()

func handle_attack(attack_type: String, hit_direction: Vector2) -> void:
	enemy.knockback_component.add_kg(hit_direction)

	if enemy.enemy_value == enemy.target_value:
		enemy.trigger_stun()
		machine.transition_to(EnemyStateMachine.EnemyStates.STUN)
	else:
		_play_hurt()

func _play_hurt() -> void:
	if animated_sprite_2D.is_connected("animation_finished", _on_animation_finished):
		animated_sprite_2D.disconnect("animation_finished", _on_animation_finished)

	animated_sprite_2D.stop()
	animated_sprite_2D.play("hurt")
	animated_sprite_2D.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_animation_finished() -> void:
	machine.transition_to(EnemyStateMachine.EnemyStates.IDLE)

func exit() -> void:
	enemy.velocity.x = 0.0   # ← hard stop on exit
	animated_sprite_2D.stop()
	if animated_sprite_2D.is_connected("animation_finished", _on_animation_finished):
		animated_sprite_2D.disconnect("animation_finished", _on_animation_finished)
	
