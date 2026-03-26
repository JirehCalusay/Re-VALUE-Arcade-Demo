extends Node

@export var character_body_2D : CharacterBody2D
@export var animated_sprite_2D : AnimatedSprite2D

const GRAVITY : int = 1000

func _physics_process(delta):
	if !character_body_2D.is_on_floor():
		character_body_2D.velocity.y += GRAVITY * delta
		
	character_body_2D.move_and_slide()
