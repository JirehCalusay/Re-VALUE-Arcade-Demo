class_name NodeFiniteStateMachine
extends Node

@export var initial_node_state : NodeState
var node_states : Dictionary = {}
var current_node_state : NodeState
var current_state_name : String = ""

@export var JUMP_HEIGHT : float = -350
@export var MAX_JUMP_COUNT : int = 1
var CURRENT_JUMP_COUNT : int = 0

# DASH COOLDOWN
var can_dash : bool = true
var dash_cooldown : float = 2.0
var dash_timer : float = 0.0

func _ready():
	for child in get_children():
		if child is NodeState:
			child.init(self)
			node_states[child.name.to_lower()] = child
			
			# Accept ANY number of arguments from "transition.emit()"
			child.transition.connect(transition_to)

	if initial_node_state:
		current_node_state = initial_node_state
		current_state_name = initial_node_state.name.to_lower()
		current_node_state.enter()
	
func _process(delta):
	if current_node_state:
		current_node_state.on_process(delta)


func _physics_process(delta):
	if current_node_state:
		current_node_state.on_physics_process(delta)

	# Countdown dash cooldown
	if !can_dash:
		dash_timer -= delta
		if dash_timer <= 0:
			can_dash = true

func transition_to(state_name: String, arg = null):
	state_name = state_name.to_lower()

	# prevent transitioning to same state
	if state_name == current_state_name:
		return

	# ← block re-entering attack while already attacking
	if current_state_name == "attack" and state_name == "attack":
		return

	var new_state: NodeState = node_states.get(state_name)
	if not new_state:
		return

	if current_node_state:
		current_node_state.exit()

	if arg != null and "set_input" in new_state:
		new_state.set_input(arg)

	new_state.enter()
	current_node_state = new_state
	current_state_name = state_name

func disable() -> void:
	if current_node_state:
		current_node_state.exit()
		current_node_state = null
	current_state_name = ""
	set_process(false)
	set_physics_process(false)
