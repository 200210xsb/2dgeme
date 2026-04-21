extends KinematicBody2D

const GRAVITY := 1200.0
const HIT_STUN_TIME := 0.12
const FLASH_TIME := 0.08

export var move_speed := 120.0
export var max_hp := 3
export var patrol_left_x := -200.0
export var patrol_right_x := 200.0
export var detect_range := 260.0
export var attack_range := 48.0
export var attack_damage := 1
export var attack_cooldown := 1.0
export(NodePath) var player_path

var hp := 3
var velocity := Vector2.ZERO
var dir := -1
var hit_stun_timer := 0.0
var attack_timer := 0.0

onready var player := get_node_or_null(player_path)

signal died(drop_position, score_value)
signal damaged

var status_effects = null

func _ready() -> void:
    hp = max_hp
    if player == null:
        player = get_parent().get_node_or_null("Player")
    
    # 初始化状态效果
    status_effects = preload("res://scripts/StatusEffects.gd").new()
    add_child(status_effects)

func _physics_process(delta: float) -> void:
    if hit_stun_timer > 0.0:
        hit_stun_timer -= delta
    
    # 处理状态效果
    if status_effects != null:
        var effect_damage = status_effects.process_effects(delta)
        if effect_damage > 0:
            hp -= effect_damage
            if hp <= 0:
                emit_signal("died", global_position, 10)
                queue_free()
                return
    
    if attack_timer > 0.0:
        attack_timer -= delta

    var chasing = false
    if player != null and player.is_inside_tree() and hit_stun_timer <= 0.0:
        var to_player = player.global_position - global_position
        var distance = to_player.length()

        if distance <= detect_range:
            chasing = true
            if distance <= attack_range:
                velocity.x = 0.0
                if attack_timer <= 0.0 and player.has_method("take_damage"):
                    player.take_damage(attack_damage, global_position, 220.0)
                    attack_timer = attack_cooldown
            else:
                dir = -1 if to_player.x < 0.0 else 1
                velocity.x = move_speed * dir

    if not chasing:
        velocity.x = move_speed * dir
        if global_position.x < patrol_left_x:
            dir = 1
        elif global_position.x > patrol_right_x:
            dir = -1

    velocity.y += GRAVITY * delta
    velocity = move_and_slide(velocity, Vector2.UP)

func take_damage(amount: int, source_position := Vector2.ZERO, knockback := 220.0) -> void:
    if amount <= 0:
        return

    hp -= amount
    emit_signal("damaged")
    hit_stun_timer = HIT_STUN_TIME

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
            hit_effects.spawn_hit_effect("blood", global_position, hit_dir)
        
        var hit_stop_manager = game.get_node_or_null("HitStopManager")
        if hit_stop_manager != null and hit_stop_manager.has_method("trigger_hit_stop"):
            hit_stop_manager.trigger_hit_stop(0.04)

    modulate = Color(1.0, 0.55, 0.55, 1.0)
    yield(get_tree().create_timer(FLASH_TIME), "timeout")
    if is_inside_tree():
        modulate = Color(1, 1, 1, 1)

    if hp <= 0:
        emit_signal("died", global_position, 10)
        queue_free()
