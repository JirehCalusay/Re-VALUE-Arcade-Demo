extends Area2D
class_name PatrolZone

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("DummyEnemy"):
		body.on_entered_patrol_zone(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("DummyEnemy"):
		body.on_exited_patrol_zone(self)

func get_patrol_points() -> Array:
	var points = []
	for child in get_children():
		if child is Marker2D:
			points.append(child)
	return points

func get_nearest_point(from_position: Vector2) -> Marker2D:
	var points = get_patrol_points()
	var nearest: Marker2D = null
	var nearest_dist: float = INF

	for point in points:
		var dist = from_position.distance_to(point.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = point

	return nearest
	
