extends Resource

class_name EnemyData

# Current combat value (matches game loop mechanics)
@export var value: int = 0

# Maximum value for the enemy (area-based)
@export var max_value: int = 20

# Target value set by the Oracle Harbinger
@export var target_value: int = 10

func randomize_target():
	target_value = randi_range(0, 20)

# Optional: HP after stun (small enemies = 1, bosses = higher)
@export var hp: int = 1

# Optional: Enemy type (Weak, Standard, Elite, Boss)
@export var enemy_type: String = "Weak"

# Optional: defense modifier
@export var defense: int = 0
