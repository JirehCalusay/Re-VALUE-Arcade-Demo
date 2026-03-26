extends NodeState

@export var character_body_2D : CharacterBody2D
@export var animated_sprite_2D : AnimatedSprite2D
@export var pivot : Node2D

const AnimationTransitionClass = preload("res://Scripts/animation_transition.gd")
@export var animation_helper: AnimationTransitionClass

@export_category("Run State")
@export var SPEED : float = 800.0
@export var MAX_HORIZONTAL_SPEED : float = 300.0
@export var IDLE_DELAY: float = 0.2  # Must be above this speed to trigger turn animation

var state_machine : NodeFiniteStateMachine
var prev_dir := 0.0
var idle_timer := 0.0

func init(m):
	state_machine = m

func on_physics_process(_delta):
	var dir: float = GameInputEvents.movement_input()

	var rapid_dir = GameInputEvents.rapid_turn_input()
	if rapid_dir != 0 and rapid_dir != prev_dir:
		var turn_state = state_machine.node_states["run2turn"]
		turn_state.target_dir = rapid_dir
		transition.emit("Run2Turn", rapid_dir)
		return

	# ----------------------------------------
	# MOVEMENT
	# ----------------------------------------
	if dir != 0:
		character_body_2D.velocity.x += dir * SPEED * _delta
		character_body_2D.velocity.x = clamp(
			character_body_2D.velocity.x,
			-MAX_HORIZONTAL_SPEED,
			MAX_HORIZONTAL_SPEED
		)
	else:
		# smooth stop
		character_body_2D.velocity.x = move_toward(character_body_2D.velocity.x, 0, SPEED * _delta)
		
	# ------------------------------
	# RUN → RUN2IDLE TRANSITION
	# ------------------------------
	if dir == 0:
		idle_timer += _delta
		transition.emit("Run2Idle")  # Go to Run2Idle state
	else:
		idle_timer = 0

	# Flip based on direction (works even during rapid turns)
	if dir != 0:
		pivot.scale.x = 1 if dir > 0 else -1
		
	prev_dir = dir
	character_body_2D.move_and_slide()

	# ----------------------------------------
	# OTHER STATE TRANSITIONS
	# ----------------------------------------

	if GameInputEvents.jump_input():
		transition.emit("Jump")

	if !character_body_2D.is_on_floor():
		transition.emit("Fall")

	var dash_dir := GameInputEvents.dash_input()
	if dash_dir != 0 and state_machine.can_dash:
		transition.emit("Dash", dash_dir)
		state_machine.can_dash = false
		state_machine.dash_timer = state_machine.dash_cooldown
		
	if GameInputEvents.attack_damage():
		transition.emit("Attack", { "attack_type": "damage" })
	
	if GameInputEvents.attack_capture():
		transition.emit("Attack", { "attack_type": "capture" })

	if GameInputEvents.release():
		GameData.release_last()

func enter():
	animated_sprite_2D.play("run")
	prev_dir = 0
	idle_timer = 0

func exit():
	animated_sprite_2D.stop()
