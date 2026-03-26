extends Area2D
class_name HitBox

var attack_type: String = "damage"
var amount: int = 1

func _ready() -> void:
	set_active(false)

func set_active(boolean: bool) -> void:
	for child in get_children():
		if child is not CollisionShape2D:
			continue
		child.disabled = not boolean

func _on_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		if attack_type == "capture":
			area.receive_capture(global_position)   # ← separate capture call
		else:
			area.receive_attack(attack_type, amount, global_position)
	
