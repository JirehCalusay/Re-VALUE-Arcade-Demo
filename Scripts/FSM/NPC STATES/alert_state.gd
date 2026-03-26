extends EntityState

@export var character_body_2D: CharacterBody2D
@export var animated_sprite_2D: AnimatedSprite2D

var player: Node2D = null

func enter():
	player = null          # reset cleanly
	_find_player()
	if animated_sprite_2D:
		animated_sprite_2D.stop()
		if animated_sprite_2D.sprite_frames and animated_sprite_2D.sprite_frames.has_animation("alert"):
			animated_sprite_2D.play("alert")
		else:
			animated_sprite_2D.play("idle")

func exit():
	player = null  # ← clear the reference so state is clean on re-entry

func on_process(_delta):
	if player and is_instance_valid(player):  # ← guard against freed nodes
		_face_player()

func on_physics_process(_delta):
	character_body_2D.velocity = Vector2.ZERO
	character_body_2D.move_and_slide()

func _find_player():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _face_player():
	if not is_instance_valid(player):
		player = null
		return
	var dir = player.global_position.x - character_body_2D.global_position.x
	if dir > 0:
		animated_sprite_2D.flip_h = false
	elif dir < 0:
		animated_sprite_2D.flip_h = true
