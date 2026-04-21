extends Reference

static func story_background() -> String:
    return "在裂界战争后，十位领主割据十域。守誓者必须穿越十章战线，逐步修复核心并终结裂隙。"

static func chapters() -> Array:
    return [
        {
            "id": 1,
            "chapter_name": "灰烬序章",
            "summary": "重新握住武器，夺回第一枚核心碎片。",
            "levels": [
                {"stage_id": 1, "stage_name": "荒烟哨站", "boss_enabled": false, "boss": "无", "theme": "基础移动教学", "enemy_count": 1, "enemy_hp": 3, "enemy_speed": 108, "boss_hp": 8, "boss_attack": 2, "boss_move": 90, "boss_dash": 310, "boss_phase_ratio": 0.5, "boss_summon_cd": 7.2, "boss_aoe_cd": 4.2},
                {"stage_id": 2, "stage_name": "铁渣工坊", "boss_enabled": true, "boss": "熔铁监工", "theme": "首个章节 Boss", "enemy_count": 2, "enemy_hp": 3, "enemy_speed": 116, "boss_hp": 9, "boss_attack": 2, "boss_move": 98, "boss_dash": 330, "boss_phase_ratio": 0.5, "boss_summon_cd": 6.9, "boss_aoe_cd": 4.0}
            ]
        },
        {
            "id": 2,
            "chapter_name": "矿井回声",
            "summary": "深入遗忘矿脉，面对高压追击。",
            "levels": [
                {"stage_id": 1, "stage_name": "斜井入口", "boss_enabled": false, "boss": "无", "theme": "窄地形缠斗", "enemy_count": 2, "enemy_hp": 3, "enemy_speed": 124, "boss_hp": 10, "boss_attack": 2, "boss_move": 102, "boss_dash": 345, "boss_phase_ratio": 0.5, "boss_summon_cd": 6.8, "boss_aoe_cd": 3.9},
                {"stage_id": 2, "stage_name": "矿压回廊", "boss_enabled": false, "boss": "无", "theme": "连续敌潮", "enemy_count": 3, "enemy_hp": 3, "enemy_speed": 130, "boss_hp": 10, "boss_attack": 2, "boss_move": 106, "boss_dash": 350, "boss_phase_ratio": 0.5, "boss_summon_cd": 6.6, "boss_aoe_cd": 3.8},
                {"stage_id": 3, "stage_name": "岩核深坑", "boss_enabled": true, "boss": "岩脊吞噬者", "theme": "追击型 Boss", "enemy_count": 3, "enemy_hp": 4, "enemy_speed": 136, "boss_hp": 12, "boss_attack": 2, "boss_move": 112, "boss_dash": 380, "boss_phase_ratio": 0.5, "boss_summon_cd": 6.3, "boss_aoe_cd": 3.7}
            ]
        },
        {
            "id": 3,
            "chapter_name": "峡谷疾风",
            "summary": "在高速位移战中学会反击窗口。",
            "levels": [
                {"stage_id": 1, "stage_name": "风刃崖壁", "boss_enabled": false, "boss": "无", "theme": "位移压制", "enemy_count": 3, "enemy_hp": 4, "enemy_speed": 142, "boss_hp": 12, "boss_attack": 2, "boss_move": 116, "boss_dash": 390, "boss_phase_ratio": 0.5, "boss_summon_cd": 6.0, "boss_aoe_cd": 3.6},
                {"stage_id": 2, "stage_name": "裂风祭坛", "boss_enabled": true, "boss": "裂风双刃", "theme": "快节奏 Boss", "enemy_count": 3, "enemy_hp": 4, "enemy_speed": 148, "boss_hp": 13, "boss_attack": 3, "boss_move": 122, "boss_dash": 410, "boss_phase_ratio": 0.52, "boss_summon_cd": 5.8, "boss_aoe_cd": 3.4}
            ]
        },
        {
            "id": 4,
            "chapter_name": "神殿瘴雾",
            "summary": "进入区域控制与召唤机制章节。",
            "levels": [
                {"stage_id": 1, "stage_name": "枯藤门庭", "boss_enabled": false, "boss": "无", "theme": "范围规避", "enemy_count": 3, "enemy_hp": 4, "enemy_speed": 152, "boss_hp": 14, "boss_attack": 3, "boss_move": 126, "boss_dash": 420, "boss_phase_ratio": 0.52, "boss_summon_cd": 5.6, "boss_aoe_cd": 3.2},
                {"stage_id": 2, "stage_name": "祭司内殿", "boss_enabled": true, "boss": "疫藤祭司", "theme": "召唤与压场", "enemy_count": 4, "enemy_hp": 4, "enemy_speed": 156, "boss_hp": 15, "boss_attack": 3, "boss_move": 130, "boss_dash": 430, "boss_phase_ratio": 0.53, "boss_summon_cd": 5.4, "boss_aoe_cd": 3.0}
            ]
        },
        {
            "id": 5,
            "chapter_name": "镜海迷局",
            "summary": "战斗节奏被打乱，需要快速判断。",
            "levels": [
                {"stage_id": 1, "stage_name": "镜纹走廊", "boss_enabled": false, "boss": "无", "theme": "节奏扰动", "enemy_count": 4, "enemy_hp": 4, "enemy_speed": 160, "boss_hp": 15, "boss_attack": 3, "boss_move": 134, "boss_dash": 440, "boss_phase_ratio": 0.53, "boss_summon_cd": 5.2, "boss_aoe_cd": 2.9},
                {"stage_id": 2, "stage_name": "倒影大厅", "boss_enabled": false, "boss": "无", "theme": "连续判定", "enemy_count": 4, "enemy_hp": 5, "enemy_speed": 164, "boss_hp": 16, "boss_attack": 3, "boss_move": 138, "boss_dash": 450, "boss_phase_ratio": 0.54, "boss_summon_cd": 5.0, "boss_aoe_cd": 2.8},
                {"stage_id": 3, "stage_name": "镜海王座", "boss_enabled": true, "boss": "镜像执刑官", "theme": "高压多段 Boss", "enemy_count": 5, "enemy_hp": 5, "enemy_speed": 168, "boss_hp": 17, "boss_attack": 4, "boss_move": 142, "boss_dash": 460, "boss_phase_ratio": 0.55, "boss_summon_cd": 4.8, "boss_aoe_cd": 2.7}
            ]
        },
        {
            "id": 6,
            "chapter_name": "雷塔轰鸣",
            "summary": "进入硬直与爆发管理章节。",
            "levels": [
                {"stage_id": 1, "stage_name": "雷梯平台", "boss_enabled": false, "boss": "无", "theme": "爆发敌潮", "enemy_count": 4, "enemy_hp": 5, "enemy_speed": 170, "boss_hp": 18, "boss_attack": 4, "boss_move": 146, "boss_dash": 470, "boss_phase_ratio": 0.55, "boss_summon_cd": 4.7, "boss_aoe_cd": 2.6},
                {"stage_id": 2, "stage_name": "雷核中庭", "boss_enabled": true, "boss": "雷核骑士", "theme": "强硬直 Boss", "enemy_count": 5, "enemy_hp": 5, "enemy_speed": 172, "boss_hp": 19, "boss_attack": 4, "boss_move": 148, "boss_dash": 480, "boss_phase_ratio": 0.56, "boss_summon_cd": 4.5, "boss_aoe_cd": 2.5}
            ]
        },
        {
            "id": 7,
            "chapter_name": "霜渡追猎",
            "summary": "强调减速环境下的精准操作。",
            "levels": [
                {"stage_id": 1, "stage_name": "冰桥驿道", "boss_enabled": false, "boss": "无", "theme": "节奏压缩", "enemy_count": 5, "enemy_hp": 5, "enemy_speed": 174, "boss_hp": 20, "boss_attack": 4, "boss_move": 150, "boss_dash": 490, "boss_phase_ratio": 0.56, "boss_summon_cd": 4.4, "boss_aoe_cd": 2.4},
                {"stage_id": 2, "stage_name": "冻港码头", "boss_enabled": false, "boss": "无", "theme": "中距离牵制", "enemy_count": 5, "enemy_hp": 6, "enemy_speed": 176, "boss_hp": 20, "boss_attack": 4, "boss_move": 152, "boss_dash": 495, "boss_phase_ratio": 0.56, "boss_summon_cd": 4.3, "boss_aoe_cd": 2.4},
                {"stage_id": 3, "stage_name": "白霜船坞", "boss_enabled": true, "boss": "白霜猎团长", "theme": "精准惩罚 Boss", "enemy_count": 6, "enemy_hp": 6, "enemy_speed": 178, "boss_hp": 21, "boss_attack": 4, "boss_move": 154, "boss_dash": 500, "boss_phase_ratio": 0.57, "boss_summon_cd": 4.1, "boss_aoe_cd": 2.3}
            ]
        },
        {
            "id": 8,
            "chapter_name": "永夜幕场",
            "summary": "多机制叠加与反应决策章节。",
            "levels": [
                {"stage_id": 1, "stage_name": "暗幕前厅", "boss_enabled": false, "boss": "无", "theme": "节拍切换", "enemy_count": 6, "enemy_hp": 6, "enemy_speed": 180, "boss_hp": 22, "boss_attack": 4, "boss_move": 156, "boss_dash": 505, "boss_phase_ratio": 0.57, "boss_summon_cd": 4.0, "boss_aoe_cd": 2.2},
                {"stage_id": 2, "stage_name": "提线舞台", "boss_enabled": true, "boss": "幕影指挥家", "theme": "多段节奏 Boss", "enemy_count": 6, "enemy_hp": 6, "enemy_speed": 182, "boss_hp": 23, "boss_attack": 5, "boss_move": 158, "boss_dash": 510, "boss_phase_ratio": 0.57, "boss_summon_cd": 3.9, "boss_aoe_cd": 2.2}
            ]
        },
        {
            "id": 9,
            "chapter_name": "星陨边界",
            "summary": "高密度压迫，准备终章。",
            "levels": [
                {"stage_id": 1, "stage_name": "坠星裂带", "boss_enabled": false, "boss": "无", "theme": "高压连续战", "enemy_count": 6, "enemy_hp": 6, "enemy_speed": 184, "boss_hp": 24, "boss_attack": 5, "boss_move": 160, "boss_dash": 515, "boss_phase_ratio": 0.58, "boss_summon_cd": 3.8, "boss_aoe_cd": 2.1},
                {"stage_id": 2, "stage_name": "天陨门扉", "boss_enabled": true, "boss": "天陨守门者", "theme": "终章前哨 Boss", "enemy_count": 7, "enemy_hp": 6, "enemy_speed": 186, "boss_hp": 25, "boss_attack": 5, "boss_move": 162, "boss_dash": 520, "boss_phase_ratio": 0.58, "boss_summon_cd": 3.7, "boss_aoe_cd": 2.0}
            ]
        },
        {
            "id": 10,
            "chapter_name": "裂隙终焉",
            "summary": "最终战章节，完成秩序修复。",
            "levels": [
                {"stage_id": 1, "stage_name": "王座外环", "boss_enabled": false, "boss": "无", "theme": "最终热身", "enemy_count": 7, "enemy_hp": 7, "enemy_speed": 188, "boss_hp": 26, "boss_attack": 5, "boss_move": 164, "boss_dash": 525, "boss_phase_ratio": 0.58, "boss_summon_cd": 3.6, "boss_aoe_cd": 2.0},
                {"stage_id": 2, "stage_name": "裂隙王座", "boss_enabled": true, "boss": "终焉领主", "theme": "双阶段最终 Boss", "enemy_count": 8, "enemy_hp": 7, "enemy_speed": 190, "boss_hp": 28, "boss_attack": 6, "boss_move": 168, "boss_dash": 540, "boss_phase_ratio": 0.6, "boss_summon_cd": 3.4, "boss_aoe_cd": 1.9}
            ]
        }
    ]

static func stages() -> Array:
    var out = []
    for chapter in chapters():
        var idx = 1
        for lv in chapter.levels:
            var entry = {}
            for k in lv.keys():
                entry[k] = lv[k]
            entry.chapter_id = chapter.id
            entry.chapter_name = chapter.chapter_name
            entry.chapter_summary = chapter.summary
            entry.stage_id = idx
            entry.global_stage = out.size() + 1
            out.append(entry)
            idx += 1
    return out

static func total_stages() -> int:
    return stages().size()

static func get_stage(stage_index: int) -> Dictionary:
    var all_stages = stages()
    var idx = clamp(stage_index - 1, 0, all_stages.size() - 1)
    return all_stages[idx]

static func chapter_count() -> int:
    return chapters().size()

static func get_chapter(chapter_id: int) -> Dictionary:
    var all = chapters()
    var idx = clamp(chapter_id - 1, 0, all.size() - 1)
    return all[idx]

static func chapter_stage_count(chapter_id: int) -> int:
    return int(get_chapter(chapter_id).levels.size())

static func stage_index_from_chapter_stage(chapter_id: int, stage_id: int) -> int:
    var index = 1
    var all_chapters = chapters()
    for ch in all_chapters:
        if int(ch.id) == chapter_id:
            return index + clamp(stage_id - 1, 0, ch.levels.size() - 1)
        index += int(ch.levels.size())
    return 1

static func get_stage_by_chapter_stage(chapter_id: int, stage_id: int) -> Dictionary:
    var idx = stage_index_from_chapter_stage(chapter_id, stage_id)
    return get_stage(idx)

static func stage_intro_text(stage_cfg: Dictionary) -> String:
    return "%s 第%d关：%s。目标：%s" % [str(stage_cfg["chapter_name"]), int(stage_cfg["stage_id"]), str(stage_cfg["stage_name"]), str(stage_cfg["theme"])]

static func stage_clear_text(stage_cfg: Dictionary) -> String:
    return "%s 第%d关完成。" % [str(stage_cfg["chapter_name"]), int(stage_cfg["stage_id"])]

static func chapter_clear_text(chapter_id: int) -> String:
    var ch = get_chapter(chapter_id)
    return "章节完成：%s" % str(ch.chapter_name)
