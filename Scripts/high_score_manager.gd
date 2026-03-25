extends Node

const SAVE_PATH := "user://high_scores.json"
const MAX_SCORES := 10

# Each entry: { "name": "AAA", "score": 999 }
var scores: Array = []

func _ready() -> void:
	_load()

func add_score(player_name: String, score: int) -> int:
	player_name = player_name.to_upper().left(3)
	scores.append({ "name": player_name, "score": score })
	scores.sort_custom(func(a, b): return a["score"] > b["score"])
	if scores.size() > MAX_SCORES:
		scores.resize(MAX_SCORES)
	_save()
	# Return the rank (1-indexed)
	for i in scores.size():
		if scores[i]["name"] == player_name and scores[i]["score"] == score:
			return i + 1
	return -1

func get_scores() -> Array:
	return scores

func _save() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(scores))

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var result = JSON.parse_string(file.get_as_text())
		if result is Array:
			scores = result
