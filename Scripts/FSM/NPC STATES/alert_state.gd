extends EntityState

@export var character_body_2D: CharacterBody2D
@export var animated_sprite_2D: AnimatedSprite2D

var player: Node2D = null

func enter():
	_find_player()
	if animated_sprite_2D:
		animated_sprite_2D.play("alert")

func exit():
	pass

func on_process(_delta):
	if player:
		_face_player()

func on_physics_process(_delta):
	character_body_2D.velocity = Vector2.ZERO
	character_body_2D.move_and_slide()

func _find_player():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _face_player():
	if not player:
		return

	var dir = player.global_position.x - character_body_2D.global_position.x
	if dir != 0:
		animated_sprite_2D.flip_h = dir < 0
		
