extends Node

# 状态效果系统
enum EffectType { NONE, POISON, BURN, FREEZE, STUN, BLEED }

const EFFECT_DATA = {
    EffectType.POISON: {"name": "中毒", "color": Color(0.4, 0.8, 0.2), "damage_per_tick": 1, "duration": 3.0},
    EffectType.BURN: {"name": "燃烧", "color": Color(1.0, 0.4, 0.0), "damage_per_tick": 2, "duration": 2.0},
    EffectType.FREEZE: {"name": "冰冻", "color": Color(0.2, 0.6, 1.0), "damage_per_tick": 0, "duration": 1.5, "slow": 0.5},
    EffectType.STUN: {"name": "眩晕", "color": Color(1.0, 1.0, 0.2), "damage_per_tick": 0, "duration": 1.0},
    EffectType.BLEED: {"name": "流血", "color": Color(1.0, 0.2, 0.2), "damage_per_tick": 1, "duration": 4.0}
}

var active_effects := {}  # {effect_type: {time_left, stack}}

signal effect_applied(effect_type, stack)
signal effect_removed(effect_type)
signal effect_tick(effect_type, damage)

func apply_effect(effect_type: int, duration_override: float = 0) -> void:
    if not EFFECT_DATA.has(effect_type):
        return
    
    var effect_name = effect_type
    var duration = duration_override if duration_override > 0 else EFFECT_DATA[effect_type]["duration"]
    
    if active_effects.has(effect_name):
        # 叠加效果
        active_effects[effect_name]["time_left"] += duration
        active_effects[effect_name]["stack"] += 1
    else:
        active_effects[effect_name] = {
            "time_left": duration,
            "stack": 1
        }
    
    emit_signal("effect_applied", effect_type, active_effects[effect_name]["stack"])

func remove_effect(effect_type: int) -> void:
    if active_effects.has(effect_type):
        active_effects.erase(effect_type)
        emit_signal("effect_removed", effect_type)

func clear_all_effects() -> void:
    active_effects.clear()

func has_effect(effect_type: int) -> bool:
    return active_effects.has(effect_type)

func is_stunned() -> bool:
    return has_effect(EffectType.STUN)

func is_frozen() -> bool:
    return has_effect(EffectType.FREEZE)

func get_slow_factor() -> float:
    var factor = 1.0
    if has_effect(EffectType.FREEZE):
        factor = min(factor, EFFECT_DATA[EffectType.FREEZE]["slow"])
    return factor

func process_effects(delta: float) -> int:
    var total_damage = 0
    
    for effect_type in active_effects.keys():
        if not EFFECT_DATA.has(effect_type):
            continue
        
        active_effects[effect_type]["time_left"] -= delta
        
        # 每秒跳一次伤害
        if active_effects[effect_type]["time_left"] <= 0:
            remove_effect(effect_type)
        else:
            # 每 0.5 秒触发一次效果
            if randf() < delta * 2:
                var damage = EFFECT_DATA[effect_type]["damage_per_tick"] * active_effects[effect_type]["stack"]
                total_damage += damage
                emit_signal("effect_tick", effect_type, damage)
    
    return total_damage

func get_active_effect_names() -> Array:
    var names = []
    for key in active_effects.keys():
        names.append(EFFECT_DATA[key]["name"])
    return names

func get_effect_icon(effect_type: int) -> String:
    match effect_type:
        EffectType.POISON: return "☠"
        EffectType.BURN: return "🔥"
        EffectType.FREEZE: return "❄"
        EffectType.STUN: return "💫"
        EffectType.BLEED: return "🩸"
        _: return ""
