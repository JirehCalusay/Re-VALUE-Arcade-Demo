extends NodeState

@export var character_body_2D : CharacterBody2D
@export var animated_sprite_2D : AnimatedSprite2D

@export_category("Dash Settings")
@export var DASH_SPEED : float = 1200
@export var DASH_DURATION : float = 0.15
@export var DASH_FRICTION : float = 0.2

var state_machine : NodeFiniteStateMachine
var dash_direction : int = 0
var dash_timer : float = 0.0

func set_input(dir: int) -> void:
	dash_direction = dir
	dash_timer = DASH_DURATION

func enter() -> void:
	character_body_2D.velocity.y = 0
	character_body_2D.velocity.x = dash_direction * DASH_SPEED
	animated_sprite_2D.play("dash")

func on_physics_process(delta: float) -> void:
	character_body_2D.velocity.x = lerp(character_body_2D.velocity.x, dash_direction * DASH_SPEED, DASH_FRICTION)
	character_body_2D.move_and_slide()

	dash_timer -= delta
	if dash_timer <= 0:
		character_body_2D.velocity.x = 0
		if character_body_2D.is_on_floor():
			transition.emit("Idle")
		else:
			transition.emit("Fall")

func exit() -> void:
	animated_sprite_2D.stop()
	character_body_2D.velocity.x = 0
