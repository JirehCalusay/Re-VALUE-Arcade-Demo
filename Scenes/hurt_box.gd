extends Area2D
class_name HurtBox

signal on_hurt_box_hurted(attack_type: String, amount: int, hit_source: Vector2)
signal on_hurt_box_stun
signal on_hurt_box_died
signal on_hurt_box_captured(hit_source: Vector2)   # ← new signal

@export var hp: int = 3

func receive_attack(attack_type: String, amount: int, hit_source: Vector2) -> void:
	on_hurt_box_hurted.emit(attack_type, amount, hit_source)

func receive_capture(hit_source: Vector2) -> void:
	on_hurt_box_captured.emit(hit_source)              # ← fires capture signal
