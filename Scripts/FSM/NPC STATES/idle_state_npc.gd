extends EntityState

@export var character_body_2D : CharacterBody2D
@export var animated_sprite_2D : AnimatedSprite2D
@export var slow_down_speed : int = 50

func on_process(_delta : float):
	pass

func on_physics_process(_delta : float):
	character_body_2D.velocity.x = move_toward(character_body_2D.velocity.x, 0, slow_down_speed * _delta)
	character_body_2D.move_and_slide()

func enter():
	animated_sprite_2D.play("idle")
	
func exit():
	pass
