extends NodeState
class_name AttackState

@export var character_body_2d: CharacterBody2D
@export var animation_player: AnimationPlayer
@onready var hit_box: HitBox = $"../../Pivot/AnimatedSprite2D/HitBox"

# animation names — set these to match exactly what you have
@export var damage_anim_1: String = "attack1"
@export var damage_anim_2: String = "attack2"
@export var capture_anim: String = "capture"   # ← your capture animation name

var current_attack: String = "damage"
var animation_finished := false
var incoming_params := {}
var _combo_index: int = 0
var _next_combo_queued: bool = false
var _is_active: bool = false          # ← tracks if we are mid attack

func set_input(params: Dictionary) -> void:
	incoming_params = params

var _combo_listen_delay: float = 0.0
const COMBO_LISTEN_TIME: float = 0.05  # wait one frame before listening

func enter() -> void:
	animation_finished = false
	_next_combo_queued = false
	_combo_index = 0
	_is_active = true
	_combo_listen_delay = COMBO_LISTEN_TIME  # ← start the delay
	hit_box.set_active(false)

	current_attack = incoming_params.get("attack_type", "damage")

	if current_attack == "damage":
		hit_box.attack_type = "damage"
		hit_box.amount = 1
		_play_damage_combo()
	else:
		hit_box.attack_type = "capture"
		animation_player.play(capture_anim)

	if not animation_player.is_connected("animation_finished", _on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func on_process(delta: float) -> void:
	if not _is_active:
		return

	# wait for delay before listening for combo input
	if _combo_listen_delay > 0.0:
		_combo_listen_delay -= delta
		return   # ← don't check input yet

	if current_attack == "damage" and GameInputEvents.attack_damage():
		_next_combo_queued = true
		print("combo queued at index: ", _combo_index)

func _play_damage_combo() -> void:
	print("playing combo index: ", _combo_index)
	if _combo_index % 2 == 0:
		animation_player.play(damage_anim_1)
	else:
		animation_player.play(damage_anim_2)

func _on_animation_finished(_anim_name: String) -> void:
	animation_finished = true
	hit_box.set_active(false)

	if current_attack == "damage" and _next_combo_queued:
		_next_combo_queued = false
		_combo_index += 1
		print("advancing to combo index: ", _combo_index)

		# reconnect before playing next
		if not animation_player.is_connected("animation_finished", _on_animation_finished):
			animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

		_play_damage_combo()
	else:
		_combo_index = 0
		_is_active = false
		_go_back_to_default()

func exit() -> void:
	hit_box.set_active(false)
	animation_player.stop()
	_combo_index = 0
	_next_combo_queued = false
	_is_active = false

func _go_back_to_default() -> void:
	if character_body_2d.velocity.x != 0 and character_body_2d.is_on_floor():
		transition.emit("Run")
	elif not character_body_2d.is_on_floor():
		transition.emit("Fall")
	else:
		transition.emit("Idle")
