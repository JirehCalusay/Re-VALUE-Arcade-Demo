extends EnemyState
class_name DeadState

@export var character_body_2D: CharacterBody2D
@export var animated_sprite_2D: AnimatedSprite2D

func enter() -> void:
	animated_sprite_2D.play("stunbreak")
	animated_sprite_2D.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_animation_finished() -> void:
	enemy.queue_free()

func exit() -> void:
	pass
