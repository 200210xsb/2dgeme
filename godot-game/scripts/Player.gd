extends KinematicBody2D

const GRAVITY := 1200.0
const MOVE_SPEED := 260.0
const JUMP_SPEED := -520.0
const HIT_STUN_TIME := 0.18
const INVINCIBLE_TIME := 0.35
const FLASH_TIME := 0.08

export var max_hp := 5
export var attack_cooldown := 0.16
export var combo_reset_time := 0.55
export var attack_active_time := 0.1
export(Array, int) var combo_damage = [1, 2, 3]

var weapon_order = ["sword", "spear", "hammer"]
var weapon_profiles = {
    "sword": {"attack_cooldown": 0.16, "combo_reset_time": 0.55, "attack_active_time": 0.1, "combo_damage": [1, 2, 3]},
    "spear": {"attack_cooldown": 0.2, "combo_reset_time": 0.65, "attack_active_time": 0.12, "combo_damage": [1, 2, 2]},
    "hammer": {"attack_cooldown": 0.32, "combo_reset_time": 0.75, "attack_active_time": 0.14, "combo_damage": [2, 3, 4]}
}
var weapon_index := 0
var current_weapon := "sword"
var attack_upgrade_level := 0
var hp_upgrade_level := 0
var speed_upgrade_level := 0
var crit_upgrade_level := 0
var base_attack_cooldown := 0.16
var base_combo_reset_time := 0.55

var hp := 5
var velocity := Vector2.ZERO
var face_dir := 1
var attack_timer := 0.0
var combo_timer := 0.0
var combo_step := 0
var current_attack_damage := 1
var hit_stun_timer := 0.0
var invincible_timer := 0.0

signal hp_changed(current_hp, max_hp)
signal died
signal damaged
signal weapon_changed(weapon_name)

onready var attack_area := $AttackArea

func _ready() -> void:
    hp = _effective_max_hp()
    attack_area.monitoring = false
    _apply_weapon(current_weapon)
    emit_signal("hp_changed", hp, _effective_max_hp())
    emit_signal("weapon_changed", current_weapon)

func _physics_process(delta: float) -> void:
    if invincible_timer > 0.0:
        invincible_timer -= delta

    if hit_stun_timer > 0.0:
        hit_stun_timer -= delta
        velocity.x = lerp(velocity.x, 0.0, 0.35)
    else:
        var axis := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
        velocity.x = axis * MOVE_SPEED

        if axis > 0:
            face_dir = 1
        elif axis < 0:
            face_dir = -1

        if is_on_floor() and Input.is_action_just_pressed("ui_up"):
            velocity.y = JUMP_SPEED

    $AttackArea.position.x = 36.0 * face_dir

    velocity.y += GRAVITY * delta
    velocity = move_and_slide(velocity, Vector2.UP)

    if combo_timer > 0.0:
        combo_timer -= delta
    else:
        combo_step = 0

    if attack_timer > 0.0:
        attack_timer -= delta
    elif hit_stun_timer <= 0.0 and Input.is_action_just_pressed("attack"):
        _attack()

    if Input.is_action_just_pressed("switch_weapon"):
        _switch_weapon()

func _attack() -> void:
    attack_timer = attack_cooldown
    combo_step = clamp(combo_step + 1, 1, combo_damage.size())
    combo_timer = combo_reset_time
    var base_damage = float(combo_damage[combo_step - 1]) * damage_multiplier()
    if _is_crit_attack():
        base_damage *= crit_multiplier()
    current_attack_damage = int(max(1, round(base_damage)))
    attack_area.monitoring = true
    yield(get_tree().create_timer(attack_active_time), "timeout")
    attack_area.monitoring = false

func take_damage(amount: int, source_position := Vector2.ZERO, knockback := 230.0) -> void:
    if amount <= 0 or invincible_timer > 0.0:
        return

    hp -= amount
    invincible_timer = INVINCIBLE_TIME
    hit_stun_timer = HIT_STUN_TIME
    emit_signal("damaged")

    if source_position != Vector2.ZERO:
        var kb_dir = sign(global_position.x - source_position.x)
        if kb_dir == 0:
            kb_dir = 1
        velocity.x = kb_dir * knockback

    modulate = Color(1.0, 0.5, 0.5, 1.0)
    yield(get_tree().create_timer(FLASH_TIME), "timeout")
    if is_inside_tree():
        modulate = Color(1, 1, 1, 1)

    emit_signal("hp_changed", max(hp, 0), _effective_max_hp())

    if hp <= 0:
        emit_signal("died")
        queue_free()

func _switch_weapon() -> void:
    weapon_index = (weapon_index + 1) % weapon_order.size()
    current_weapon = weapon_order[weapon_index]
    _apply_weapon(current_weapon)
    combo_step = 0
    combo_timer = 0.0
    emit_signal("weapon_changed", current_weapon)

func _apply_weapon(name: String) -> void:
    if not weapon_profiles.has(name):
        return

    var profile = weapon_profiles[name]
    base_attack_cooldown = float(profile["attack_cooldown"])
    base_combo_reset_time = float(profile["combo_reset_time"])
    attack_cooldown = base_attack_cooldown
    combo_reset_time = base_combo_reset_time
    attack_active_time = float(profile["attack_active_time"])
    combo_damage = profile["combo_damage"]
    _apply_speed_upgrade()

func set_upgrade_levels(hp_level: int, attack_level: int, speed_level := 0, crit_level := 0) -> void:
    hp_upgrade_level = max(0, hp_level)
    attack_upgrade_level = max(0, attack_level)
    speed_upgrade_level = max(0, int(speed_level))
    crit_upgrade_level = max(0, int(crit_level))
    _apply_speed_upgrade()

    var old_max = hp
    var new_max = _effective_max_hp()
    hp = min(max(old_max, new_max), new_max)

    emit_signal("hp_changed", hp, new_max)

func heal_full() -> void:
    hp = _effective_max_hp()
    emit_signal("hp_changed", hp, _effective_max_hp())

func damage_multiplier() -> float:
    return 1.0 + float(attack_upgrade_level) * 0.12

func crit_multiplier() -> float:
    return 1.6 + float(crit_upgrade_level) * 0.05

func _is_crit_attack() -> bool:
    var chance = clamp(0.05 * float(crit_upgrade_level), 0.0, 0.45)
    return randf() < chance

func _apply_speed_upgrade() -> void:
    var speed_factor = max(0.55, 1.0 - float(speed_upgrade_level) * 0.06)
    attack_cooldown = base_attack_cooldown * speed_factor
    combo_reset_time = base_combo_reset_time * max(0.6, 1.0 - float(speed_upgrade_level) * 0.04)

func _effective_max_hp() -> int:
    return max_hp + hp_upgrade_level
