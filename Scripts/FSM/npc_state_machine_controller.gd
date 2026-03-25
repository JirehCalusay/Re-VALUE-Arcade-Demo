extends Node

@export var entity_state_machine: EntityStateMachine

func _on_vision_area_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		entity_state_machine.transition_to("alert")

func _on_vision_area_body_exited(body):
	if body.is_in_group("Player"):
		entity_state_machine.transition_to("idle")
