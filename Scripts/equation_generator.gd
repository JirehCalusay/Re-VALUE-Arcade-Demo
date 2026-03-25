extends Node
class_name EquationGenerator

static func generate(question_count: int = 0) -> Dictionary:
	var difficulty_tier = question_count / 10  # 0–3
	var max_answer = min(50 + difficulty_tier * 50, 200)  # 50, 100, 150, 200

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
			var b = randi_range(0, 50)
			var a = answer + b
			equation = "%d - %d" % [a, b]
		2:
			# multiplication + addition: a × b + c = answer
			var multiplier = randi_range(2, 5)
			var base = randi_range(1, min(answer / multiplier, 40))
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
		"max_answer": max_answer
	}
