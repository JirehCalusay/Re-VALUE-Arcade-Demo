extends NodeState

@export var character_body_2D : CharacterBody2D
@export var animated_sprite_2D : AnimatedSprite2D
@export var pivot : Node2D

@export_category("Physics Friction")
@export var SLOW_DOWN_SPEED : int = 20

var state_machine: NodeFiniteStateMachine

func init(_machine):
	state_machine = _machine

func on_process(_delta : float):
	pass

func on_physics_process(_delta : float):
	character_body_2D.velocity.x = move_toward(character_body_2D.velocity.x, 0, SLOW_DOWN_SPEED)
	
	character_body_2D.move_and_slide()
	
	# TRANSITIONING STATES
	
	# FALL STATE	
	if !character_body_2D.is_on_floor():
		transition.emit("Fall")
		
	# RUN STATE
	var direction : float = GameInputEvents.movement_input()
	
	if direction and character_body_2D.is_on_floor():
		transition.emit("Run")
		
	if GameInputEvents.jump_input():
		transition.emit("Jump")
		
	# DASH STATE 
	var dash_dir := GameInputEvents.dash_input()
	if dash_dir != 0 and state_machine.can_dash:
		transition.emit("Dash", dash_dir)
		state_machine.can_dash = false
		state_machine.dash_timer = state_machine.dash_cooldown
		return
		
	if GameInputEvents.attack_damage():
		transition.emit("Attack", { "attack_type": "damage" })
	
	if GameInputEvents.attack_capture():
		transition.emit("Attack", { "attack_type": "capture" })

	if GameInputEvents.release():
		GameData.release_last()
		
func enter():
	animated_sprite_2D.play("idle")

func exit():
	animated_sprite_2D.stop()
