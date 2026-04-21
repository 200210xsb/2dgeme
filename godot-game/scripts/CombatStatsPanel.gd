extends CanvasLayer

# 战斗数据面板 - 显示连击、DPS 等信息
onready var combo_label := $ComboLabel
onready var combo_count_label := $ComboCountLabel
onready var damage_label := $DamageLabel
onready var dps_label := $DPSLabel
onready var time_label := $TimeLabel

var combo_system = null
var fight_start_time := 0
var total_damage := 0
var fight_time := 0.0

func _ready() -> void:
    visible = false
    fight_start_time = 0

func start_combat() -> void:
    fight_start_time = OS.get_ticks_msec()
    fight_time = 0
    total_damage = 0
    visible = true
    
    if combo_system == null:
        combo_system = preload("res://scripts/ComboSystem.gd").new()
        add_child(combo_system)
        combo_system.connect("combo_updated", self, "_on_combo_updated")
        combo_system.connect("combo_milestone", self, "_on_combo_milestone")

func end_combat() -> void:
    visible = false
    
    if combo_system != null:
        combo_system.reset_on_death()

func add_damage(amount: int) -> void:
    total_damage += amount
    
    if combo_system != null:
        combo_system.add_hit()
    
    _update_damage_display()

func _on_combo_updated(count: int, multiplier: float) -> void:
    if count <= 0:
        combo_label.text = ""
        combo_count_label.text = ""
    else:
        combo_label.text = "COMBO"
        combo_count_label.text = "x%d" % count
        
        # 连击奖励显示
        if multiplier > 1.0:
            combo_label.text += " +%d%%" % int((multiplier - 1.0) * 100)

func _on_combo_milestone(milestone: int) -> void:
    # 连击里程碑特效
    _show_milestone_effect(milestone)

func _show_milestone_effect(count: int) -> void:
    var tween = create_tween()
    combo_label.modulate = Color(1, 1, 0.5, 1)
    combo_label.scale = Vector2(1.5, 1.5)
    tween.tween_property(combo_label, "modulate", Color(1, 1, 1, 1), 0.5)
    tween.tween_property(combo_label, "scale", Vector2(1, 1), 0.5)

func _update_damage_display() -> void:
    damage_label.text = "DMG: %d" % total_damage
    
    # 计算 DPS
    if fight_start_time > 0:
        fight_time = (OS.get_ticks_msec() - fight_start_time) / 1000.0
        var dps = int(float(total_damage) / max(fight_time, 1.0))
        dps_label.text = "DPS: %d" % dps
        time_label.text = "TIME: %.1fs" % fight_time

func get_combat_stats() -> Dictionary:
    var stats = {
        "total_damage": total_damage,
        "fight_time": fight_time,
        "dps": int(float(total_damage) / max(fight_time, 1.0)),
        "total_kills": 0
    }
    
    if combo_system:
        var combo_stats = combo_system.get_stats()
        stats["max_combo"] = combo_stats["max_combo"]
        stats["total_hits"] = combo_stats["total_hits"]
    
    return stats
