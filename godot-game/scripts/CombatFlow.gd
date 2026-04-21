extends Reference
class_name CombatFlow

# 战斗流畅度工具类
static func can_cancel_animation(state: String, cancel_type: String) -> bool:
    # 定义哪些动作可以被取消
    var cancel_rules = {
        "attack_light": ["move", "jump", "dash"],
        "attack_heavy": ["move"],  # 重攻击只能被移动取消
        "hit_stun": [],  # 受击硬直不能取消
        "dash": ["attack", "jump"],
        "jump": ["attack"],
        "idle": ["move", "attack", "jump", "dash"],
        "move": ["attack", "jump", "dash"]
    }
    
    if not cancel_rules.has(state):
        return false
    
    return cancel_type in cancel_rules[state]

static func lerp_vector2(from: Vector2, to: Vector2, t: float) -> Vector2:
    return from.linear_interpolate(to, t)

static func smooth_step(edge0: float, edge1: float, x: float) -> float:
    var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

static func calculate_knockback(base_knockback: float, damage: int, is_heavy: bool = false) -> float:
    var knockback = base_knockback
    knockback += float(damage) * 2.0
    
    if is_heavy:
        knockback *= 1.5
    
    return knockback

static func should_grant_invincibility(state: String) -> bool:
    # 哪些状态应该给予无敌时间
    var invincible_states = ["dash", "hit_stun", "respawn"]
    return state in invincible_states
