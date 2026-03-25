extends NodeState

@export var character_body_2D : CharacterBody2D
@export var animated_sprite_2D : AnimatedSprite2D

const AnimationTransitionClass = preload("res://Scripts/animation_transition.gd")
@export var animation_helper: AnimationTransitionClass

@export var TRANSITION_DURATION := 0.2  # Length of Run2Idle animation
@export var INERTIA_SPEED := 500     # How fast player slows down

var timer := 0.0
var state_machine : NodeFiniteStateMachine

func init(m):
	state_machine = m

func enter():
	timer = TRANSITION_DURATION
	animation_helper.play_transition("run2idle") # Play the transition animation

func on_physics_process(_delta):
	timer -= _delta

	# Apply smooth inertia while stopping
	character_body_2D.velocity.x = move_toward(character_body_2D.velocity.x, 0, INERTIA_SPEED * _delta)
	character_body_2D.move_and_slide()

	# When animation finishes, go to Idle
	if timer <= 0:
		transition.emit("Idle")
		
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

func exit():
	animated_sprite_2D.play("idle")
	
