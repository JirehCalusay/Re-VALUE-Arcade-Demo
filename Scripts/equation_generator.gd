extends Node
class_name EquationGenerator

static func generate(turnover_count: int = 0) -> Dictionary:
	# Every 10 turnovers, max_answer increases by 50, starting at 50. No hard cap.
	var difficulty_tier: int = turnover_count / 10
	var max_answer: int = 50 + difficulty_tier * 50

	var answer: int = randi_range(1, max_answer)
	var equation: String
	var style = randi_range(0, 2)
	match style:
		0:
			# addition: a + b = answer
			var a = randi_range(0, answer)
			var b = answer - a
			equation = "%d + %d" % [a, b]
		1:
			# subtraction: a - b = answer
			var b = randi_range(0, min(50 + difficulty_tier * 10, answer))
			var a = answer + b
			equation = "%d - %d" % [a, b]
		2:
			# multiplication + addition: a × b + c = answer
			var multiplier = randi_range(2, min(5 + difficulty_tier, 10))
			var safe_max = max(1, answer / multiplier)
			var base = randi_range(1, min(safe_max, 40 + difficulty_tier * 10))
			var remainder = answer - (base * multiplier)
			if remainder < 0:
				var a = randi_range(0, answer)
				var b = answer - a
				equation = "%d + %d" % [a, b]
			else:
				equation = "%d × %d + %d" % [multiplier, base, remainder]
	return {
		"answer": answer,
		"equation": equation,
		"max_answer": max_answer,
		"difficulty_tier": difficulty_tier
	}
