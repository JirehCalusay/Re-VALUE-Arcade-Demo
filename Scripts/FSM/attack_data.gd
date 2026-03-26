extends Node
class_name AttackData

@export var animation_damage: String = "attack1"    # K key animation
@export var animation_capture: String = "capture"   # J key animation
@export var attack_type: String = "damage"          # "damage" or "capture"
@export var amount: int = 1
@export var return_state: String = "Idle"
