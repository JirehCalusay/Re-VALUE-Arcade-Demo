extends Node

@onready var ui: CanvasLayer = $"../UI"

const START_TIME: float = 99.0
const TIME_EXTENSION: float = 15.0

var time_remaining: float = START_TIME
var score: int = 0
var is_running: bool = true

func _process(delta: float) -> void:
	if not is_running:
		return

	time_remaining -= delta
	ui.update_timer(time_remaining)

	if time_remaining <= 0.0:
		_on_time_up()

func add_time() -> void:
	time_remaining += TIME_EXTENSION
	print("Time extended! +15 seconds")

func add_score(value: int) -> void:
	score += value
	ui.update_score(score)

func _on_time_up() -> void:
	is_running = false
	print("Time's up — run over")
