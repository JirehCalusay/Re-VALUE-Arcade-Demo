class_name EntityStateMachine
extends Node

@export var initial_state : EntityState
var states := {}
var current_state: EntityState
var state_name := ""

func _ready():
	for child in get_children():
		if child is EntityState:
			states[child.name.to_lower()] = child
			child.init(self)
			child.transition.connect(transition_to)

	if initial_state:
		current_state = initial_state
		state_name = initial_state.name.to_lower()
		initial_state.enter()

func _process(delta):
	if current_state:
		current_state.on_process(delta)

func _physics_process(delta):
	if current_state:
		current_state.on_physics_process(delta)

func transition_to(new_state: String):
	new_state = new_state.to_lower()
	if new_state == state_name:
		return

	if not states.has(new_state):
		return

	current_state.exit()
	current_state = states[new_state]
	state_name = new_state
	current_state.enter()

# Forces a state transition even if already in that state — re-runs exit+enter.
func force_transition_to(new_state: String):
	new_state = new_state.to_lower()
	if not states.has(new_state):
		return

	if current_state:
		current_state.exit()
	current_state = states[new_state]
	state_name = new_state
	current_state.enter()
