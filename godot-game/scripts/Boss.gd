extends KinematicBody2D

const GRAVITY := 1200.0
const HIT_STUN_TIME := 0.16
const FLASH_TIME := 0.08

export var move_speed := 100.0
export var dash_speed := 380.0
export var max_hp := 10
export var detect_range := 420.0
export var attack_range := 72.0
export var attack_damage := 2
export var attack_cooldown := 1.2
export var dash_cooldown := 2.2
export var phase2_hp_ratio := 0.5
export var phase2_speed_scale := 1.35
export var phase2_damage_bonus := 1
export var summon_cooldown := 5.0
export var aoe_cooldown := 3.4
export var aoe_range := 150.0
export var aoe_damage := 2

# 新技能参数
export var projectile_cooldown := 4.0  # 远程弹幕
export var projectile_damage := 1
export var projectile_speed := 320.0
export var charge_cooldown := 6.0  # 蓄力冲撞
export var charge_damage := 3
export var charge_speed := 520.0
export var heal_cooldown := 15.0  # 自我治疗
export var heal_amount := 3

export(NodePath) var player_path

var hp := 10
var velocity := Vector2.ZERO
var dir := -1
var hit_stun_timer := 0.0
var attack_timer := 0.0
var dash_timer := 0.0
var dash_time_left := 0.0
var enraged := false
var summon_timer := 0.0
var aoe_timer := 0.0
var projectile_timer := 0.0
var charge_timer := 0.0
var heal_timer := 0.0
var is_charging := false

onready var player := get_node_or_null(player_path)

signal died(drop_position, score_value)
signal damaged
signal phase_changed(phase)
signal request_spawn_minion(spawn_position)
signal aoe_cast

func _ready() -> void:
    hp = max_hp
    if player == null:
        player = get_parent().get_node_or_null("Player")

func _physics_process(delta: float) -> void:
    if hit_stun_timer > 0.0:
        hit_stun_timer -= delta
    if attack_timer > 0.0:
        attack_timer -= delta
    if dash_timer > 0.0:
        dash_timer -= delta
    if dash_time_left > 0.0:
        dash_time_left -= delta
    if summon_timer > 0.0:
        summon_timer -= delta
    if aoe_timer > 0.0:
        aoe_timer -= delta
    if projectile_timer > 0.0:
        projectile_timer -= delta
    if charge_timer > 0.0:
        charge_timer -= delta
    if heal_timer > 0.0:
        heal_timer -= delta

    if player != null and player.is_inside_tree() and hit_stun_timer <= 0.0:
        var to_player = player.global_position - global_position
        var distance = to_player.length()
        dir = -1 if to_player.x < 0.0 else 1
        var speed_scale = phase2_speed_scale if enraged else 1.0
        var current_dash_cooldown = dash_cooldown * 0.72 if enraged else dash_cooldown
        var current_attack_damage = attack_damage + phase2_damage_bonus if enraged else attack_damage

        # 蓄力冲撞
        if is_charging:
            velocity.x = dir * charge_speed
            if distance <= attack_range and player.has_method("take_damage"):
                player.take_damage(charge_damage, global_position, 400.0)
                is_charging = false
                charge_timer = charge_cooldown
            return
        
        if dash_time_left > 0.0:
            velocity.x = dash_speed * speed_scale * dir
        elif distance <= detect_range:
            if enraged and aoe_timer <= 0.0 and distance <= aoe_range and player.has_method("take_damage"):
                player.take_damage(aoe_damage, global_position, 340.0)
                aoe_timer = aoe_cooldown
                emit_signal("aoe_cast")

            # 新技能：远程弹幕
            if enraged and projectile_timer <= 0.0 and distance > attack_range * 1.5 and distance < detect_range * 0.8:
                _shoot_projectile()
                projectile_timer = projectile_cooldown * (0.7 if enraged else 1.0)
            
            # 新技能：蓄力冲撞
            if enraged and charge_timer <= 0.0 and distance > attack_range * 2.0:
                is_charging = true
                # 蓄力停顿
                velocity.x = 0.0
                yield(get_tree().create_timer(0.6), "timeout")
                if is_inside_tree() and is_charging:
                    # 冲撞有预警特效
                    var game = get_parent()
                    if game != null:
                        var hit_effects = game.get_node_or_null("HitEffects")
                        if hit_effects != null:
                            hit_effects.spawn_shockwave(global_position, 60, Color(1.0, 0.3, 0.0, 0.5))

            if distance <= attack_range:
                velocity.x = 0.0
                if attack_timer <= 0.0 and player.has_method("take_damage"):
                    player.take_damage(current_attack_damage, global_position, 300.0)
                    attack_timer = attack_cooldown
            else:
                velocity.x = move_speed * speed_scale * dir
                if dash_timer <= 0.0 and distance > attack_range * 1.2:
                    dash_time_left = 0.24
                    dash_timer = current_dash_cooldown

            if enraged and summon_timer <= 0.0:
                var spawn_offset = rand_range(-120.0, 120.0)
                emit_signal("request_spawn_minion", global_position + Vector2(spawn_offset, 0.0))
                summon_timer = summon_cooldown
        else:
            velocity.x = 0.0
    else:
        velocity.x = 0.0

    velocity.y += GRAVITY * delta
    velocity = move_and_slide(velocity, Vector2.UP)

func take_damage(amount: int, source_position := Vector2.ZERO, knockback := 260.0) -> void:
    if amount <= 0:
        return

    hp -= amount
    emit_signal("damaged")
    hit_stun_timer = HIT_STUN_TIME

    if not enraged and hp <= int(max_hp * phase2_hp_ratio):
        enraged = true
        modulate = Color(1.0, 0.35, 0.35, 1.0)
        emit_signal("phase_changed", 2)

    if source_position != Vector2.ZERO:
        var kb_dir = sign(global_position.x - source_position.x)
        if kb_dir == 0:
            kb_dir = 1
        velocity.x = kb_dir * knockback

    # 受击特效
    var game = get_parent()
    if game != null:
        var hit_effects = game.get_node_or_null("HitEffects")
        if hit_effects != null and hit_effects.has_method("spawn_hit_effect"):
            var hit_dir = 0.0
            if source_position != Vector2.ZERO:
                hit_dir = atan2(global_position.y - source_position.y, global_position.x - source_position.x)
            var effect_type = ["spark", "spark", "impact"].pick_random()
            hit_effects.spawn_hit_effect(effect_type, global_position, hit_dir)
        
        var hit_stop_manager = game.get_node_or_null("HitStopManager")
        if hit_stop_manager != null and hit_stop_manager.has_method("trigger_hit_stop"):
            hit_stop_manager.trigger_hit_stop(0.06)

    modulate = Color(1.0, 0.45, 0.45, 1.0)
    yield(get_tree().create_timer(FLASH_TIME), "timeout")
    if is_inside_tree():
        modulate = Color(1, 1, 1, 1)

    if hp <= 0:
        emit_signal("died", global_position, 60)
        queue_free()

func _shoot_projectile() -> void:
    var projectile = _BossProjectile.new()
    projectile.damage = projectile_damage
    projectile.speed = projectile_speed
    projectile.position = global_position + Vector2(30 * dir, -15)
    projectile.direction = dir
    
    var game = get_parent()
    if game != null:
        game.add_child(projectile)
        
        # 射击特效
        var hit_effects = game.get_node_or_null("HitEffects")
        if hit_effects != null:
            hit_effects.spawn_spark(projectile.position, Vector2(dir, 0), 0.8)

class _BossProjectile:
    extends Node2D
    var damage := 1
    var speed := 320.0
    var direction := 1
    var velocity := Vector2.ZERO
    var lifetime := 3.0
    
    func _ready() -> void:
        velocity = Vector2(direction * speed, 0)
    
    func _physics_process(delta: float) -> void:
        lifetime -= delta
        global_position += velocity * delta
        
        # 检测碰撞
        var space_state = get_world_2d().direct_space_state
        var query = PhysicsShapeQueryParameters2D.new()
        query.set_shape(CircleShape2D.new())
        query.shape.radius = 15
        query.transform = global_transform
        query.exclude = [self]
        
        var result = space_state.intersect_shape(query, 1)
        if not result.empty():
            var collider = result[0].collider
            if collider.has_method("take_damage"):
                collider.take_damage(damage, global_position, 200.0)
            queue_free()
            return
        
        if lifetime <= 0 or global_position.x > 1300 or global_position.x < -100:
            queue_free()
    
    func _draw() -> void:
        # 绘制 Boss 弹幕球
        var color = Color(1.0, 0.3, 0.8, 0.9)
        draw_circle(Vector2.ZERO, 12, color)
        draw_circle(Vector2.ZERO, 8, Color(1.0, 0.6, 0.9, 0.7))
        draw_circle(Vector2.ZERO, 4, Color(1.0, 1.0, 1.0, 0.9))
