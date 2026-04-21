extends Node2D

# 精英敌人系统
extends KinematicBody2D

const GRAVITY := 1200.0
const HIT_STUN_TIME := 0.14
const FLASH_TIME := 0.08

export var move_speed := 140.0
export var max_hp := 5
export var patrol_left_x := -200.0
export var patrol_right_x := 200.0
export var detect_range := 300.0
export var attack_range := 52.0
export var attack_damage := 2
export var attack_cooldown := 0.8
export var charge_cooldown := 3.5
export var elite_type := 0  # 0: 普通精英，1: 快速型，2: 坦克型

var hp := 5
var velocity := Vector2.ZERO
var dir := -1
var hit_stun_timer := 0.0
var attack_timer := 0.0
var charge_timer := 0.0
var is_charging := false
var charge_speed := 0.0

onready var player = get_parent().get_node_or_null("Player")

signal died(drop_position, score_value)
signal damaged

func _ready() -> void:
    hp = max_hp
    _apply_elite_type()

func _apply_elite_type() -> void:
    if elite_type == 1:  # 快速型
        move_speed = int(move_speed * 1.4)
        max_hp = int(max_hp * 0.7)
        charge_speed = 420.0
    elif elite_type == 2:  # 坦克型
        move_speed = int(move_speed * 0.7)
        max_hp = int(max_hp * 1.8)
        attack_damage = int(attack_damage * 1.5)
        charge_speed = 280.0
    else:
        charge_speed = 350.0
    
    hp = max_hp

func _physics_process(delta: float) -> void:
    if hit_stun_timer > 0.0:
        hit_stun_timer -= delta
    if attack_timer > 0.0:
        attack_timer -= delta
    if charge_timer > 0.0:
        charge_timer -= delta
    
    if is_charging:
        velocity.x = dir * charge_speed
        is_charging = false  # 只冲刺一次
    
    var chasing = false
    if player != null and player.is_inside_tree() and hit_stun_timer <= 0.0:
        var to_player = player.global_position - global_position
        var distance = to_player.length()
        
        if distance <= detect_range:
            chasing = true
            dir = -1 if to_player.x < 0.0 else 1
            
            if distance <= attack_range:
                velocity.x = 0.0
                if attack_timer <= 0.0 and player.has_method("take_damage"):
                    player.take_damage(attack_damage, global_position, 240.0)
                    attack_timer = attack_cooldown
            else:
                velocity.x = move_speed * dir
                if charge_timer <= 0.0 and distance > attack_range * 1.5:
                    _perform_charge()
    
    if not chasing:
        velocity.x = move_speed * dir
        if global_position.x < patrol_left_x:
            dir = 1
        elif global_position.x > patrol_right_x:
            dir = -1
    
    velocity.y += GRAVITY * delta
    velocity = move_and_slide(velocity, Vector2.UP)

func _perform_charge() -> void:
    is_charging = true
    charge_timer = charge_cooldown

func take_damage(amount: int, source_position := Vector2.ZERO, knockback := 240.0) -> void:
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
    
    modulate = Color(1.0, 0.6, 0.3, 1.0)
    yield(get_tree().create_timer(FLASH_TIME), "timeout")
    if is_inside_tree():
        modulate = Color(1, 1, 1, 1)
    
    if hp <= 0:
        emit_signal("died", global_position, 25)  # 精英敌人更多分数
        queue_free()
