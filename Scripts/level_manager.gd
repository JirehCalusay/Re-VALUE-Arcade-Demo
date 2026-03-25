extends Node

@onready var ui: CanvasLayer = $"../UI"
@onready var game_over: CanvasLayer = $"../GameOver"
@onready var pause_menu: CanvasLayer = $"../PauseMenu"

const BASE_TIME: float = 180.0
const TIME_REDUCTION_PER_TIER: float = 30.0

var time_remaining: float = BASE_TIME
var score: int = 0
var is_running: bool = true

func _ready() -> void:
	GameData.turnover_success.connect(_on_turnover_success)

func _process(delta: float) -> void:
	if not is_running:
		return

	time_remaining -= delta
	ui.update_timer(time_remaining)

	if time_remaining <= 0.0:
		_on_time_up()

func _input(event: InputEvent) -> void:
	if not is_running:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		pause_menu.show_pause(self)
		get_viewport().set_input_as_handled()

func _on_turnover_success(score_bonus: int) -> void:
	score += score_bonus
	ui.add_score(score_bonus)
	print("Score +", score_bonus, " | Total: ", score)

	var new_tier: int = mini(GameData.turnover_count / 10, 3)
	GameData.difficulty_tier = new_tier

	var reset_time: float = max(BASE_TIME - new_tier * TIME_REDUCTION_PER_TIER, 60.0)
	time_remaining = reset_time
	print("Timer reset to ", reset_time, " (tier ", new_tier, ")")

	var result = EquationGenerator.generate(GameData.turnover_count)
	GameData.global_target_value = result["answer"]
	GameData.current_equation = result["equation"]
	GameData.target_changed.emit(result["answer"], result["equation"])
	print("New equation: ", result["equation"], " = ", result["answer"], " (tier ", GameData.turnover_count / 10, ")")
	ui.update_difficulty(GameData.turnover_count)

func _on_time_up() -> void:
	is_running = false
	print("Time's up — game over")

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var fsm = player.get_node_or_null("StateMachine")
		if fsm and fsm.has_method("disable"):
			fsm.disable()

	game_over.show_game_over(score)
