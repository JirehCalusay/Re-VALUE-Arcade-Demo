extends Node
class_name PatrolZoneManager

func get_nearest_zone(from_position: Vector2) -> PatrolZone:
	var nearest_zone: PatrolZone = null
	var nearest_dist: float = INF

	for zone in get_children():
		if zone is PatrolZone:
			var dist = from_position.distance_to(zone.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_zone = zone

	return nearest_zone
