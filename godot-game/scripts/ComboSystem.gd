extends Node

# 连击计数和奖励系统
var combo_count := 0
var max_combo := 0
var combo_timer := 0.0
var combo_timeout := 2.0
var total_hits := 0
var total_kills := 0

# 连击奖励倍率
var combo_multipliers = {
    10: 1.1,
    20: 1.2,
    30: 1.3,
    50: 1.5,
    100: 2.0
}

signal combo_updated(count, multiplier)
signal new_max_combo(count)
signal combo_milestone(milestone)

var last_milestone := 0
var ui_combo_label = null
var ui_combo_count_label = null

func _process(delta: float) -> void:
    if combo_count > 0:
        combo_timer -= delta
        if combo_timer <= 0:
            reset_combo()
    
    # 更新 UI
    if ui_combo_label != null:
        if combo_count > 1:
            ui_combo_label.text = "COMBO x%d (%d%%)" % [combo_count, get_current_multiplier_percent()]
            ui_combo_label.visible = true
        else:
            ui_combo_label.visible = false
    
    if ui_combo_count_label != null:
        if combo_count > 5:
            ui_combo_count_label.text = "%d" % combo_count
            ui_combo_count_label.visible = true
        else:
            ui_combo_count_label.visible = false

func add_hit() -> void:
    combo_count += 1
    total_hits += 1
    combo_timer = combo_timeout
    
    if combo_count > max_combo:
        max_combo = combo_count
        emit_signal("new_max_combo", max_combo)
    
    # 检查连击里程碑
    check_milestones()
    
    var multiplier = get_current_multiplier()
    emit_signal("combo_updated", combo_count, multiplier)

func reset_combo() -> void:
    if combo_count > 0:
        combo_count = 0
        emit_signal("combo_updated", 0, 1.0)

func add_kill() -> void:
    total_kills += 1

func check_milestones() -> void:
    var milestones = [10, 20, 30, 50, 100]
    for ms in milestones:
        if combo_count >= ms and last_milestone < ms:
            last_milestone = ms
            emit_signal("combo_milestone", ms)
            break

func get_current_multiplier() -> float:
    var multiplier = 1.0
    for threshold in combo_multipliers.keys():
        if combo_count >= threshold:
            multiplier = combo_multipliers[threshold]
    return multiplier

func get_current_multiplier_percent() -> int:
    return int((get_current_multiplier() - 1.0) * 100)

func reset_on_death() -> void:
    if combo_count > 5:
        # 死亡时保留连击记录（成就感）
        pass
    combo_count = 0
    combo_timer = 0

func get_stats() -> Dictionary:
    return {
        "current_combo": combo_count,
        "max_combo": max_combo,
        "total_hits": total_hits,
        "total_kills": total_kills,
        "current_multiplier": get_current_multiplier()
    }
