extends Node

# 命中停顿系统 - 增强打击感的核心
var is_hitting := false
var hit_stop_duration := 0.12  # 基础停顿时间
var shake_intensity := 0.0

signal hit_stop_started(duration)
signal hit_stop_ended

var affected_nodes = []

func _ready() -> void:
    # 添加到 process 组
    set_process(true)

func register_node(node: Node) -> void:
    if node not in affected_nodes:
        affected_nodes.append(node)

func unregister_node(node: Node) -> void:
    if node in affected_nodes:
        affected_nodes.erase(node)

# 触发命中停顿
func trigger_hit_stop(duration: float = -1, intensity: float = 1.0) -> void:
    if duration < 0:
        duration = hit_stop_duration
    
    if is_hitting:
        return  # 避免重叠
    
    is_hitting = true
    hit_stop_duration = duration
    shake_intensity = intensity
    
    emit_signal("hit_stop_started", duration)
    
    # 冻结所有受影响的节点
    for node in affected_nodes:
        if node and is_instance_valid(node):
            if node.has_method("set_physics_process"):
                node.set_physics_process(false)
    
    # 延迟恢复
    yield(get_tree().create_timer(duration), "timeout")
    
    # 恢复所有节点
    for node in affected_nodes:
        if node and is_instance_valid(node):
            if node.has_method("set_physics_process"):
                node.set_physics_process(true)
    
    is_hitting = false
    emit_signal("hit_stop_ended")

# 根据攻击类型调整停顿
func get_hit_stop_duration(attack_type: String) -> float:
    match attack_type:
        "light":
            return 0.08  # 轻攻击
        "normal":
            return 0.12  # 普通攻击
        "heavy":
            return 0.18  # 重攻击
        "crit":
            return 0.25  # 暴击
        "smash":
            return 0.30  # 击碎
        _:
            return hit_stop_duration

# 根据伤害调整震动
func get_shake_intensity(damage: int, is_crit: bool = false) -> float:
    var base = float(damage) / 10.0
    base = clamp(base, 0.1, 1.0)
    if is_crit:
        base *= 1.5
    return base

# 简化调用接口
func quick_hit_stop(attack_type: String = "normal", damage: int = 1, is_crit: bool = false) -> void:
    var duration = get_hit_stop_duration(attack_type)
    var intensity = get_shake_intensity(damage, is_crit)
    trigger_hit_stop(duration, intensity)
