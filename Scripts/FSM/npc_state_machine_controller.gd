extends Node

@export var entity_state_machine: EntityStateMachine

var _player_in_range: bool = false

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		entity_state_machine.force_transition_to("alert")

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		entity_state_machine.transition_to("idle")

func _on_turnover_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_in_range = true

func _on_turnover_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_in_range = false

func _process(_delta: float) -> void:
	if _player_in_range and GameInputEvents.turnover():
		var level_manager = get_tree().get_first_node_in_group("LevelManager")
		if level_manager:
			GameData.try_turnover(level_manager.time_remaining)
		else:
			GameData.try_turnover(0.0)
