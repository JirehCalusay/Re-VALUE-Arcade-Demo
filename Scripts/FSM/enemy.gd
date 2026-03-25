extends CharacterBody2D

# ── Value & HP ───────────────────────────────────────────────
@export var enemy_value: int = 20
var max_hp: float
var current_hp: float
var hit_count: int = 0
var _hit_reset_timer: float = 0.0
const HIT_RESET_TIME: float = 5.0

# ── Spawn ─────────────────────────────────────────────────────
var spawn_immobilized: bool = false              # ← moved up here
var was_captured: bool = false
var spawn_knockback_direction: Vector2 = Vector2.ZERO
var spawn_knockback_force: Vector2 = Vector2.ZERO

# ── Split Scene ───────────────────────────────────────────────
const dummy_scene = preload("res://Scenes/dummy_enemy.tscn")

# ── State Machine refs ───────────────────────────────────────
var target_value: int

@onready var hurt_box: HurtBox = $AnimatedSprite2D/HurtBox
@onready var state_machine: EnemyStateMachine = $EnemyStateMachine
@onready var knockback_component: KnockbackComponent = $KnockbackComponent

@onready var idle_state: IdleState = $EnemyStateMachine/Idle
@onready var patrol_state: PatrolState = $EnemyStateMachine/Patrol
@onready var chase_state: ChaseState = $EnemyStateMachine/Chase
@onready var immobilized_state: ImmobilizedState = $EnemyStateMachine/Immobilized
@onready var hurt_state: HurtState = $EnemyStateMachine/Hurt
@onready var stun_state: StunState = $EnemyStateMachine/Stun
@onready var dead_state: DeadState = $EnemyStateMachine/Dead

var current_patrol_zone: PatrolZone = null
var last_known_zone: PatrolZone = null

@onready var dummy_label: Node2D = $EnemyLabel

func _ready() -> void:
	add_to_group("Enemies")
	_setup_hp()
	target_value = GameData.global_target_value
	dummy_label.set_value(enemy_value)  # ← add this line
	$AnimatedSprite2D.modulate = _get_tint(enemy_value)  # ← tint the sprite too
	state_machine.init(
		self,
		idle_state,
		patrol_state,
		chase_state,
		immobilized_state,
		hurt_state,
		stun_state,
		dead_state
	)

	hurt_box.on_hurt_box_hurted.connect(_on_hurt_box_hurted)
	hurt_box.on_hurt_box_stun.connect(_on_hurt_box_stun)
	hurt_box.on_hurt_box_died.connect(_on_hurt_box_died)
	hurt_box.on_hurt_box_captured.connect(_on_hurt_box_captured)
	knockback_component.knockback_launched.connect(_on_knockback_launched)
	knockback_component.immobilized.connect(_on_immobilized)
	knockback_component.kg_changed.connect(_flash_kg)

	# calculate force but don't apply yet — ImmobilizedState will apply it
	if spawn_immobilized and spawn_knockback_direction != Vector2.ZERO:
		spawn_knockback_force = Vector2(
			spawn_knockback_direction.x * randf_range(150.0, 280.0),
			randf_range(-300.0, -200.0)   # stronger upward pop
		)

func _setup_hp() -> void:
	match enemy_value:
		1:  max_hp = 10.0
		5:  max_hp = 50.0
		10: max_hp = 100.0
		20: max_hp = 200.0
	current_hp = max_hp
	print("Enemy Value: ", enemy_value, " | Max HP: ", max_hp)

# ── Hit Counter Reset ────────────────────────────────────────
func _process(delta: float) -> void:
	state_machine.update(delta)

	if hit_count > 0:
		_hit_reset_timer -= delta
		if _hit_reset_timer <= 0.0:
			hit_count = 0
			print("Hit counter reset")

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)

# ── Damage Calculation ───────────────────────────────────────
func calculate_damage() -> float:
	hit_count += 1
	_hit_reset_timer = HIT_RESET_TIME

	# 5% base, increases by 0.5% per hit, plus 5% per difficulty tier
	# tier 0: 5% base | tier 1: 10% base | tier 2: 15% base | tier 3: 20% base
	var tier_bonus: float = GameData.difficulty_tier * 0.05
	var damage_percent = 0.05 + tier_bonus + (hit_count - 1) * 0.005
	var damage = max_hp * damage_percent

	print("Hit: ", hit_count, " | Tier: ", GameData.difficulty_tier, " | Damage%: ", damage_percent * 100, "% | Damage: ", damage)
	return damage

# ── Hurt ─────────────────────────────────────────────────────
func _on_hurt_box_hurted(attack_type: String, amount: int, hit_source: Vector2) -> void:
	var raw = global_position - hit_source
	var hit_direction = Vector2(sign(raw.x), 0)

	if attack_type == "capture":
		return

	var damage = calculate_damage()
	current_hp -= damage
	print("Damage dealt: ", damage, " | HP remaining: ", current_hp)

	if current_hp <= 0:
		_trigger_split()
		return

	if state_machine.current_state == EnemyStateMachine.EnemyStates.STUN:
		stun_state.handle_attack(attack_type, hit_direction)   # ← no amount
	else:
		state_machine.transition_to(EnemyStateMachine.EnemyStates.HURT)
		hurt_state.handle_attack(attack_type, hit_direction)   # ← no amount

	knockback_component.add_kg(hit_direction)

func _on_hurt_box_stun() -> void:
	print("Value matched — enemy stunned!")

func _on_hurt_box_died() -> void:
	queue_free()
	
func _on_hurt_box_captured(_hit_source: Vector2) -> void:
	was_captured = true
	GameData.register_capture_candidate(self)

# ── Split Logic ──────────────────────────────────────────────
func _trigger_split() -> void:
	if not is_inside_tree():
		return

	match enemy_value:
		20:
			_spawn_children(10, 2)
		10:
			_spawn_children(5, 2)
		5:
			_spawn_children(1, 5)
		1:
			pass

	queue_free()

func _spawn_children(child_value: int, count: int) -> void:
	for i in count:
		var child = dummy_scene.instantiate()
		child.enemy_value = child_value

		# spread them out slightly
		var offset = Vector2(randf_range(-20, 20), 0)
		child.global_position = global_position + offset
		child.spawn_immobilized = true

		# direction away from death position — left or right alternating
		# gives a satisfying spread effect
		var direction = Vector2(1 if i % 2 == 0 else -1, 0)
		child.spawn_knockback_direction = direction

		get_parent().add_child(child)
		print("Spawned Value ", child_value, " at ", child.global_position)

func start_immobilized() -> void:
	state_machine.transition_to(EnemyStateMachine.EnemyStates.IMMOBILIZED)

# ── Knockback & Flash ────────────────────────────────────────
func _on_knockback_launched(force: Vector2) -> void:
	velocity = force

func _on_immobilized() -> void:
	if state_machine.current_state != EnemyStateMachine.EnemyStates.STUN and \
	   state_machine.current_state != EnemyStateMachine.EnemyStates.DEAD:
		state_machine.transition_to(EnemyStateMachine.EnemyStates.IMMOBILIZED)

func trigger_stun() -> void:
	hurt_box.on_hurt_box_stun.emit()

func _flash_kg(kg: int) -> void:
	var sprite = $AnimatedSprite2D
	var tween = create_tween()
	match kg:
		1:
			tween.tween_property(sprite, "modulate", Color(3, 3, 3, 1.0), 0.08)
			tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1.0), 0.2)
		2:
			tween.tween_property(sprite, "modulate", Color(6, 6, 6, 1.0), 0.08)
			tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1.0), 0.2)
		3:
			tween.tween_property(sprite, "modulate", Color(4, 0, 0, 1.0), 0.08)
			tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1.0), 0.2)

func on_entered_patrol_zone(zone: PatrolZone) -> void:
	current_patrol_zone = zone
	last_known_zone = zone

func on_exited_patrol_zone(zone: PatrolZone) -> void:
	if current_patrol_zone == zone:
		current_patrol_zone = null
		
func _get_tint(value: int) -> Color:
	match enemy_value:
		1:  return Color(1, 1, 1)
		5:  return Color(0.4, 0.8, 1)
		10: return Color(1, 0.85, 0.2)
		20: return Color(1, 0.3, 0.8)
	return Color(1, 1, 1)
