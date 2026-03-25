extends NodeState

@export var character_body_2D : CharacterBody2D
@export var animated_sprite_2D : AnimatedSprite2D
@export var pivot : Node2D

@export_category("Jump State")
@export var JUMP_HORIZONTAL_SPEED : int = 500
@export var MAX_JUMP_HORIZONTAL_SPEED : int = 300
@export var JUMP_GRAVITY : int = 800

var state_machine : NodeFiniteStateMachine

func init(_machine):
	state_machine = _machine
	return self

func on_process(_delta : float):
	pass

func on_physics_process(_delta : float):
	character_body_2D.velocity.y += JUMP_GRAVITY * _delta
	
	if character_body_2D.is_on_floor() and state_machine.CURRENT_JUMP_COUNT == 0:
		character_body_2D.velocity.y = state_machine.JUMP_HEIGHT
		state_machine.CURRENT_JUMP_COUNT += 1
		animated_sprite_2D.stop()
		animated_sprite_2D.play("jump") # Reset jump animation

	# MULTIPLE JUMPS
	if !character_body_2D.is_on_floor() and GameInputEvents.jump_input() and state_machine.CURRENT_JUMP_COUNT != state_machine.MAX_JUMP_COUNT:
		character_body_2D.velocity.y = state_machine.JUMP_HEIGHT
		state_machine.CURRENT_JUMP_COUNT += 1
		animated_sprite_2D.stop()
		animated_sprite_2D.play("jump")
		
	var dir : float = GameInputEvents.movement_input()
	
	if !character_body_2D.is_on_floor():
		character_body_2D.velocity.x += dir * JUMP_HORIZONTAL_SPEED
		character_body_2D.velocity.x = clamp(character_body_2D.velocity.x, -MAX_JUMP_HORIZONTAL_SPEED, MAX_JUMP_HORIZONTAL_SPEED)
	
	# DASH STATE (AIR DASH SUPPORTED)
	var dash_dir := GameInputEvents.dash_input()
	if dash_dir != 0 and state_machine.can_dash:
		transition.emit("Dash", dash_dir)
		state_machine.can_dash = false
		state_machine.dash_timer = state_machine.dash_cooldown
		return
		
	# FLIP
	if dir != 0:
		pivot.scale.x = 1 if dir > 0 else -1
		
	character_body_2D.move_and_slide()
	
	# TRANSITIONING STATES
	
	# IDLE STATE	 & CURRENT JUMP COUNT RESET
	if character_body_2D.is_on_floor():
		state_machine.CURRENT_JUMP_COUNT = 0
		transition.emit("Idle")
		return
		
	# FALL STATE
	if character_body_2D.velocity.y > 0:
		transition.emit("Fall")

	if GameInputEvents.release():
		GameData.release_last()

func enter():
	animated_sprite_2D.play("jump")

func exit():
	animated_sprite_2D.stop()
