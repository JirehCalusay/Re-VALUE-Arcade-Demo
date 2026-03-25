extends NodeState

@export var character_body_2D : CharacterBody2D
@export var animated_sprite_2D : AnimatedSprite2D
@export var FALL_GRAVITY : int = 700
@export var SPEED : int = 600
@export var MAX_FALL_SPEED : int = 200
@export var pivot : Node2D

const AnimationTransitionClass = preload("res://Scripts/animation_transition.gd")
@export var animation_helper: AnimationTransitionClass

var state_machine : NodeFiniteStateMachine
var current_transition: String = ""

func init(_machine):
	state_machine = _machine
	return self

func on_process(_delta : float):
	pass

func on_physics_process(_delta : float):
	# DASH STATE 
	var dash_dir := GameInputEvents.dash_input()
	if dash_dir != 0 and state_machine.can_dash:
		transition.emit("Dash", dash_dir)
		state_machine.can_dash = false
		state_machine.dash_timer = state_machine.dash_cooldown
		return
		
	character_body_2D.velocity.y += FALL_GRAVITY * _delta
	var dir : float = GameInputEvents.movement_input()

	# Multiple Jumps in Fall State
	if GameInputEvents.jump_input() and state_machine.CURRENT_JUMP_COUNT < state_machine.MAX_JUMP_COUNT:
		character_body_2D.velocity.y = state_machine.JUMP_HEIGHT
		state_machine.CURRENT_JUMP_COUNT += 1
		transition.emit("Jump") # Transition back to JumpState
		return # prevents the character_body_2D.move_and_slide() from running and interrupt the jump
	 
	if dir:
		character_body_2D.velocity.x += dir * SPEED
		character_body_2D.velocity.x = clamp(character_body_2D.velocity.x, -MAX_FALL_SPEED, MAX_FALL_SPEED)
	
	if abs(character_body_2D.velocity.x) > 0:
		character_body_2D.velocity.x = move_toward(
			character_body_2D.velocity.x,
			0,
			SPEED * _delta
		)
	
	character_body_2D.move_and_slide()
	
	# FLIP
	if dir != 0:
		pivot.scale.x = 1 if dir > 0 else -1
	
	# TRANSITIONING STATES
	
	# IDLE STATE	 & CURRENT JUMP COUNT RESET
	if character_body_2D.is_on_floor():
		state_machine.CURRENT_JUMP_COUNT = 0
		transition.emit("Idle")

func enter():
	animation_helper.play_transition("jump2fall")

func exit():
	var cb = Callable(self, "_on_animation_finished")
	if animated_sprite_2D.animation_finished.is_connected(cb):
		animated_sprite_2D.animation_finished.disconnect(cb)
