extends Node

# 成就系统
var achievements = {
    "first_blood": {"name": "首战告捷", "desc": "击败第一个敌人", "unlocked": false},
    "boss_slayer": {"name": "Boss 杀手", "desc": "击败 10 个 Boss", "count": 0, "required": 10, "unlocked": false},
    "gold_collector": {"name": "金币收集者", "desc": "累计获得 500 金币", "count": 0, "required": 500, "unlocked": false},
    "combo_master": {"name": "连击大师", "desc": "使用剑武器完成 50 次连击", "count": 0, "required": 50, "unlocked": false},
    "speed_runner": {"name": "速通达人", "desc": 在 30 秒内通关一个 Boss 关卡", "unlocked": false, "start_time": 0},
    "full_upgrade": {"name": "完全体", "desc": "将所有升级升到满级", "unlocked": false},
    "chapter_hero": {"name": "章节英雄", "desc": "通关第 5 章", "unlocked": false},
    "legend": {"name": "传奇", "desc": "通关所有 10 章", "unlocked": false}
}

var save_path = "user://achievements.json"
var combo_count := 0

signal achievement_unlocked(achievement_id)

func _ready() -> void:
    load_achievements()

func unlock_first_blood() -> void:
    if not achievements["first_blood"]["unlocked"]:
        unlock_achievement("first_blood")

func increment_boss_kill() -> void:
    var data = achievements["boss_slayer"]
    if data["unlocked"]:
        return
    data["count"] += 1
    if data["count"] >= data["required"]:
        unlock_achievement("boss_slayer")

func increment_gold(amount: int) -> void:
    var data = achievements["gold_collector"]
    if data["unlocked"]:
        return
    data["count"] += amount
    if data["count"] >= data["required"]:
        unlock_achievement("gold_collector")

func increment_combo(combo_step: int, weapon: String) -> void:
    if weapon != "sword" or combo_step < 3:
        return
    var data = achievements["combo_master"]
    if data["unlocked"]:
        return
    data["count"] += 1
    if data["count"] >= data["required"]:
        unlock_achievement("combo_master")

func start_speed_run_timer() -> void:
    achievements["speed_runner"]["start_time"] = OS.get_ticks_msec()

func check_speed_run(level_time_ms: int) -> void:
    var data = achievements["speed_runner"]
    if data["unlocked"]:
        return
    if level_time_ms < 30000:  # 30 秒
        unlock_achievement("speed_runner")

func unlock_chapter(chapter_id: int) -> void:
    if chapter_id >= 5 and not achievements["chapter_hero"]["unlocked"]:
        unlock_achievement("chapter_hero")
    
    if chapter_id >= 10 and not achievements["legend"]["unlocked"]:
        unlock_achievement("legend")

func check_full_upgrade(upgrades: Dictionary) -> void:
    if upgrades.get("hp", 0) >= 10 and \
       upgrades.get("attack", 0) >= 10 and \
       upgrades.get("speed", 0) >= 10 and \
       upgrades.get("crit", 0) >= 10:
        unlock_achievement("full_upgrade")

func unlock_achievement(id: String) -> void:
    if achievements[id]["unlocked"]:
        return
    
    achievements[id]["unlocked"] = true
    emit_signal("achievement_unlocked", id)
    save_achievements()

func save_achievements() -> void:
    var file = File.new()
    file.open(save_path, File.WRITE)
    file.store_string(to_json(achievements))
    file.close()

func load_achievements() -> void:
    var file = File.new()
    if not file.file_exists(save_path):
        return
    file.open(save_path, File.READ)
    var json_text = file.get_as_text()
    file.close()
    
    if json_text != "":
        var result = parse_json(json_text)
        if result is Dictionary:
            for key in result.keys():
                if achievements.has(key):
                    achievements[key] = result[key]

func get_unlocked_count() -> int:
    var count = 0
    for key in achievements.keys():
        if achievements[key]["unlocked"]:
            count += 1
    return count

func get_total_count() -> int:
    return achievements.size()

func get_achievement_list() -> Array:
    var list = []
    for key in achievements.keys():
        list.append(achievements[key])
    return list
