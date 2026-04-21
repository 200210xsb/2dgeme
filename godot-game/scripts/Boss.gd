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

    if player != null and player.is_inside_tree() and hit_stun_timer <= 0.0:
        var to_player = player.global_position - global_position
        var distance = to_player.length()
        dir = -1 if to_player.x < 0.0 else 1
        var speed_scale = phase2_speed_scale if enraged else 1.0
        var current_dash_cooldown = dash_cooldown * 0.72 if enraged else dash_cooldown
        var current_attack_damage = attack_damage + phase2_damage_bonus if enraged else attack_damage

        if dash_time_left > 0.0:
            velocity.x = dash_speed * speed_scale * dir
        elif distance <= detect_range:
            if enraged and aoe_timer <= 0.0 and distance <= aoe_range and player.has_method("take_damage"):
                player.take_damage(aoe_damage, global_position, 340.0)
                aoe_timer = aoe_cooldown
                emit_signal("aoe_cast")

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

    modulate = Color(1.0, 0.45, 0.45, 1.0)
    yield(get_tree().create_timer(FLASH_TIME), "timeout")
    if is_inside_tree():
        modulate = Color(1, 1, 1, 1)

    if hp <= 0:
        emit_signal("died", global_position, 60)
        queue_free()
