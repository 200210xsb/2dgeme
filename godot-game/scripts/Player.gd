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

var weapon_order = ["sword", "spear", "hammer", "dagger", "axe", "bow"]
var weapon_profiles = {
    "sword": {"attack_cooldown": 0.16, "combo_reset_time": 0.55, "attack_active_time": 0.1, "combo_damage": [1, 2, 3], "range": 36, "type": "melee"},
    "spear": {"attack_cooldown": 0.2, "combo_reset_time": 0.65, "attack_active_time": 0.12, "combo_damage": [1, 2, 2], "range": 48, "type": "melee"},
    "hammer": {"attack_cooldown": 0.32, "combo_reset_time": 0.75, "attack_active_time": 0.14, "combo_damage": [2, 3, 4], "range": 32, "type": "melee"},
    "dagger": {"attack_cooldown": 0.12, "combo_reset_time": 0.45, "attack_active_time": 0.08, "combo_damage": [1, 1, 2], "range": 30, "type": "melee"},
    "axe": {"attack_cooldown": 0.38, "combo_reset_time": 0.85, "attack_active_time": 0.16, "combo_damage": [2, 3, 5], "range": 34, "type": "melee"},
    "bow": {"attack_cooldown": 0.45, "combo_reset_time": 0.9, "attack_active_time": 0.18, "combo_damage": [2, 2, 3], "range": 500, "type": "ranged"}
}
var current_weapon_type := "melee"
var dash_enabled := true  # 启用冲刺
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
var is_attacking := false
var air_attack_used := false
var block_active := false
var block_angle := 0.08
var perfect_block_timer := 0.0
var perfect_block_window := 0.15
var last_block_time := -999.0
var was_parried := false

signal hp_changed(current_hp, max_hp)
signal died
signal damaged
signal weapon_changed(weapon_name)

onready var attack_area := $AttackArea
onready var sprite := $Sprite if has_node("Sprite") else null
onready var attack_effect := $AttackEffect if has_node("AttackEffect") else null
onready var sound_manager := get_tree().get_nodes_in_group("sound_manager")[0] if not get_tree().get_nodes_in_group("sound_manager").empty() else null
onready var hit_stop_manager := get_node_or_null("../../HitStopManager")
onready var hit_effects := get_node_or_null("../../HitEffects")

var status_effects = null

var input_buffer_ref = null
var move_acceleration := 1200.0
var move_deceleration := 800.0
var attack_motion_blur := false
var attack_cancelable := false
var cancel_window_timer := 0.0
var dash_enabled := false
var dash_cooldown_time := 0.28
var dash_speed := 520.0
var dash_duration := 0.12
var dash_cooldown_timer := 0.0
var is_dashing := false

func _get_face_dir() -> int:
    return face_dir

func _ready() -> void:
    hp = _effective_max_hp()
    attack_area.monitoring = false
    _apply_weapon(current_weapon)
    emit_signal("hp_changed", hp, _effective_max_hp())
    emit_signal("weapon_changed", current_weapon)
    
    # 初始化状态效果
    status_effects = preload("res://scripts/StatusEffects.gd").new()
    add_child(status_effects)

func _physics_process(delta: float) -> void:
    if invincible_timer > 0.0:
        invincible_timer -= delta

    if dash_cooldown_timer > 0.0:
        dash_cooldown_timer -= delta

    if cancel_window_timer > 0.0:
        cancel_window_timer -= delta
    else:
        attack_cancelable = false
    
    if perfect_block_timer > 0.0:
        perfect_block_timer -= delta
    
    # 处理状态效果
    var effect_damage = 0
    if status_effects != null:
        effect_damage = status_effects.process_effects(delta)
        if effect_damage > 0:
            hp -= effect_damage
            if hp <= 0:
                emit_signal("died")
                queue_free()
                return

    if hit_stun_timer > 0.0:
        hit_stun_timer -= delta
        velocity.x = lerp(velocity.x, 0.0, 0.35)
    elif is_dashing:
        var dash_dir := face_dir
        velocity.x = dash_dir * dash_speed
        velocity.y = 0.0
    else:
        var axis := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
        
        # 直接加速，不要平滑
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

    # 落地重置空中攻击
    if is_on_floor():
        air_attack_used = false

    if combo_timer > 0.0:
        combo_timer -= delta
    else:
        combo_step = 0

    if attack_timer > 0.0:
        attack_timer -= delta
    elif hit_stun_timer <= 0.0:
        var block_pressed = Input.is_action_pressed("block")
        
        # 完美格挡判定：受击前 0.15s 内按下格挡
        if block_pressed and not is_attacking:
            if perfect_block_timer > 0:
                # 触发完美格挡
                block_active = true
            else:
                block_active = true
            last_block_time = 0.0  # 重置用于计算
        else:
            block_active = false
        
        # 完美格挡窗口计时
        if block_pressed:
            perfect_block_timer = perfect_block_window
        
        if Input.is_action_just_pressed("attack"):
            _attack()
        elif input_buffer_ref != null:
            var buffered = input_buffer_ref.check_and_consume("attack")
            if buffered:
                _attack()

    if Input.is_action_just_pressed("switch_weapon"):
        _switch_weapon()

    if dash_enabled and Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and hit_stun_timer <= 0.0:
        _perform_dash()

func _attack() -> void:
    # 空中攻击限制
    if not is_on_floor() and air_attack_used:
        return
    
    if current_weapon == "bow":
        air_attack_used = true
    
    attack_timer = attack_cooldown
    combo_step = clamp(combo_step + 1, 1, combo_damage.size())
    combo_timer = combo_reset_time
    is_attacking = true
    var base_damage = float(combo_damage[combo_step - 1]) * damage_multiplier()
    if _is_crit_attack():
        base_damage *= crit_multiplier()
    current_attack_damage = int(max(1, round(base_damage)))
    
    # 弓箭射击
    if current_weapon_type == "ranged":
        _shoot_arrow()
    else:
        # 近战攻击
        attack_area.monitoring = true
        attack_cancelable = true
        cancel_window_timer = attack_active_time * 0.6
        
        if is_dashing:
            is_dashing = false
        
        # 播放攻击特效
        if attack_effect != null:
            attack_effect.play(global_position + Vector2(36 * face_dir, 0), face_dir, current_weapon)
        
        # 播放攻击音效
        if sound_manager != null:
            sound_manager.play_attack_sound()
        
        yield(get_tree().create_timer(attack_active_time), "timeout")
        attack_area.monitoring = false
        attack_cancelable = false
    
    is_attacking = false

func _perform_dash() -> void:
    is_dashing = true
    dash_cooldown_timer = dash_cooldown_time
    velocity.y = 0.0
    
    if input_buffer_ref != null:
        input_buffer_ref.clear_buffer()
    
    yield(get_tree().create_timer(dash_duration), "timeout")
    is_dashing = false

func _shoot_arrow() -> void:
    var arrow = preload("res://scripts/ArrowProjectile.gd").new()
    arrow.damage = current_attack_damage
    arrow.speed = 450.0
    arrow.pixel_size = pixel_size if has_node("Sprite") and get_node("Sprite").has_method("get_pixel_size") else 3
    
    # 箭矢生成位置
    var spawn_pos = global_position + Vector2(20 * face_dir, -10)
    arrow.global_position = spawn_pos
    
    # 设置方向（略微向上）
    var direction = Vector2(face_dir, -0.15).normalized()
    arrow.set_direction(direction)
    
    get_parent().add_child(arrow)
    
    # 播放射击音效（使用攻击音效替代）
    if sound_manager != null:
        sound_manager.play_attack_sound()
    
    # 弓箭攻击特效
    if attack_effect != null:
        attack_effect.play(spawn_pos, face_dir)

func take_damage(amount: int, source_position := Vector2.ZERO, knockback := 230.0) -> void:
    if amount <= 0 or invincible_timer > 0.0:
        return

    # 格挡判定
    if block_active:
        var angle_to_enemy = atan2(source_position.y - global_position.y, source_position.x - global_position.x)
        var face_angle = 0.0 if face_dir > 0 else PI
        var angle_diff = abs(fposmod(angle_to_enemy - face_angle + PI, TAU * 2) - PI)
        
        # 完美格挡：完全免疫 + 弹反
        if perfect_block_timer > 0 and angle_diff < block_angle:
            amount = 0
            knockback = 0
            invincible_timer = 0.2
            was_parried = true
            
            # 弹反特效
            if hit_effects != null:
                hit_effects.spawn_shockwave(global_position, 50, Color(0.2, 0.8, 1.0, 0.8))
            
            if hit_stop_manager != null:
                hit_stop_manager.trigger_hit_stop(0.12)
            
            # 弹反音效
            if sound_manager != null:
                sound_manager.play_attack_sound()  # 用攻击音效替代
            
            return
        
        # 普通格挡：减伤
        if angle_diff < block_angle:
            amount = int(amount * 0.25)
            knockback = knockback * 0.3
    
    perfect_block_timer = 0  # 重置完美格挡窗口
    hp -= amount
    invincible_timer = INVINCIBLE_TIME
    hit_stun_timer = HIT_STUN_TIME
    emit_signal("damaged")

    if source_position != Vector2.ZERO:
        var kb_dir = sign(global_position.x - source_position.x)
        if kb_dir == 0:
            kb_dir = 1
        velocity.x = kb_dir * knockback

    # 播放受击音效
    if sound_manager != null:
        sound_manager.play_hit_sound()
    
    # 精灵闪烁
    if sprite != null:
        sprite.flash_hit()
    
    # 生成伤害数字
    _spawn_damage_number(amount, false)

    emit_signal("hp_changed", max(hp, 0), _effective_max_hp())

    if hp <= 0:
        emit_signal("died")
        queue_free()

func _spawn_damage_number(amount: int, is_crit: bool) -> void:
    var damage_text = preload("res://scripts/DamageNumber.gd").new()
    get_parent().add_child(damage_text)
    damage_text.global_position = global_position + Vector2(0, -30)
    damage_text.set_damage(amount, is_crit)

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
    current_weapon_type = profile.get("type", "melee")
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
