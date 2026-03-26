extends NodeState

@export var character_body_2D : CharacterBody2D
@export var animated_sprite_2D : AnimatedSprite2D
@export var pivot : Node2D

const AnimationTransitionClass = preload("res://Scripts/animation_transition.gd")
@export var animation_helper: AnimationTransitionClass

@export var TURN_DURATION := 0.1
@export var GRACE_PERIOD := 0.05  # additional small time for early turn activation
@export var FRICTION := 0.1       # how much velocity is dampened during turn

var timer := 0.0
var target_dir := 0   # direction to face after turn
var state_machine : NodeFiniteStateMachine

func init(m):
	state_machine = m

func set_input(dir):
	target_dir = dir

func enter():
	timer = TURN_DURATION + GRACE_PERIOD
	animation_helper.play_transition("run2turn")

func on_physics_process(_delta):
	character_body_2D.velocity.x = lerp(character_body_2D.velocity.x, 0.0, FRICTION)

	# Allow drift physics during turn
	character_body_2D.move_and_slide()
	
	timer -= _delta
	
	if timer <= GRACE_PERIOD:
		var dir: float = GameInputEvents.movement_input()
		if dir == 0:
			transition.emit("Run2Idle")
		if timer <= 0:
			pivot.scale.x = 1 if dir > 0 else -1	
			transition.emit("Run")
			
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
	animated_sprite_2D.play("run")
	
