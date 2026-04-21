# 武器配置扩展

var weapon_order = ["sword", "spear", "hammer", "dagger", "axe", "bow"]

var weapon_profiles = {
    # 基础武器
    "sword": {
        "attack_cooldown": 0.16,
        "combo_reset_time": 0.55,
        "attack_active_time": 0.1,
        "combo_damage": [1, 2, 3],
        "range": 36,
        "color": Color(0.7, 0.7, 0.7),
        "special": "none"
    },
    "spear": {
        "attack_cooldown": 0.2,
        "combo_reset_time": 0.65,
        "attack_active_time": 0.12,
        "combo_damage": [1, 2, 2],
        "range": 52,
        "color": Color(0.5, 0.4, 0.3),
        "special": "piercing"  # 穿透攻击
    },
    "hammer": {
        "attack_cooldown": 0.32,
        "combo_reset_time": 0.75,
        "attack_active_time": 0.14,
        "combo_damage": [2, 3, 4],
        "range": 30,
        "color": Color(0.6, 0.5, 0.4),
        "special": "knockback"  # 强击退
    },
    
    # 扩展武器
    "dagger": {
        "attack_cooldown": 0.12,
        "combo_reset_time": 0.45,
        "attack_active_time": 0.08,
        "combo_damage": [1, 1, 1, 2, 3],  # 5 段连击
        "range": 28,
        "color": Color(0.8, 0.85, 0.9),
        "special": "crit_boost"  # 暴击率提升
    },
    "axe": {
        "attack_cooldown": 0.28,
        "combo_reset_time": 0.7,
        "attack_active_time": 0.16,
        "combo_damage": [2, 2, 5],
        "range": 34,
        "color": Color(0.5, 0.35, 0.25),
        "special": "bleed"  # 流血效果
    },
    "bow": {
        "attack_cooldown": 0.35,
        "combo_reset_time": 0.6,
        "attack_active_time": 0.2,
        "combo_damage": [2, 3, 4],
        "range": 120,  # 远程
        "color": Color(0.6, 0.45, 0.25),
        "special": "ranged"  # 远程攻击
    }
}

# 武器解锁等级
var weapon_unlocks = {
    "sword": 0,    # 初始
    "spear": 1,    # 通关第 1 章解锁
    "hammer": 2,   # 通关第 2 章解锁
    "dagger": 3,   # 通关第 4 章解锁
    "axe": 5,      # 通关第 6 章解锁
    "bow": 8       # 通关第 9 章解锁
}

# 武器特殊效果数据
var special_effects = {
    "piercing": {
        "description": "穿透攻击，可同时命中多个敌人",
        "hit_count": 3
    },
    "knockback": {
        "description": "强力击退，将敌人击飞更远",
        "knockback_multi": 2.0
    },
    "crit_boost": {
        "description": "暴击率提升 20%",
        "crit_bonus": 0.2
    },
    "bleed": {
        "description": "攻击造成流血效果",
        "bleed_chance": 0.3,
        "bleed_damage": 1
    },
    "ranged": {
        "description": "远程攻击，安全距离输出",
        "projectile_speed": 400
    }
}
