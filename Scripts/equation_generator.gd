extends Node
class_name EquationGenerator

static func generate() -> Dictionary:
	var answer: int
	var equation: String

	# 85% positive, 15% negative
	if randf() < 0.85:
		answer = randi_range(0, 50)
	else:
		answer = randi_range(-10, 0)

	# pick a random equation style that produces that answer
	var style = randi_range(0, 2)

	match style:
		0:
			# simple addition: a + b = answer
			var a = randi_range(0, 20)
			var b = answer - a
			equation = "%d + %d" % [a, b]

		1:
			# simple subtraction: a - b = answer
			var a = answer + randi_range(0, 20)
			var b = a - answer
			equation = "%d - %d" % [a, b]

		2:
			# multiplication then addition: a × b + c = answer
			# keep it simple — small multiplier
			var multiplier = randi_range(2, 5)
			var base = answer / multiplier  # integer division
			var remainder = answer - (base * multiplier)
			equation = "%d × %d + %d" % [multiplier, base, remainder]

	return {
		"answer": answer,
		"equation": equation
	}
