extends Node2D

onready var player := $Player
onready var enemy := $Enemy
onready var boss := $Boss
onready var boss_collision := $Boss/CollisionShape2D
onready var camera := $MainCamera
onready var hp_fill := $UI/HpBarBg/HpBarFill
onready var hp_text := $UI/HpText
onready var score_text := $UI/ScoreText
onready var gold_text := $UI/GoldText
onready var weapon_text := $UI/WeaponText
onready var level_text := $UI/LevelText
onready var info_text := $UI/InfoText
onready var story_text := $UI/StoryText
onready var start_panel := $UI/StartPanel
onready var start_text := $UI/StartPanel/StartText
onready var result_panel := $UI/ResultPanel
onready var result_text := $UI/ResultPanel/ResultText
onready var shop_panel := $UI/ShopPanel
onready var shop_text := $UI/ShopPanel/ShopText
onready var combo_label := $UI/ComboLabel
onready var combo_count_label := $UI/ComboCountLabel

const KeybindManager = preload("res://scripts/KeybindManager.gd")
const CampaignData = preload("res://scripts/CampaignData.gd")
const SaveData = preload("res://scripts/SaveData.gd")
const DropCoin = preload("res://scripts/DropCoin.gd")
const AchievementManager = preload("res://scripts/AchievementManager.gd")
const DifficultyManager = preload("res://scripts/DifficultyManager.gd")
const ComboSystem = preload("res://scripts/ComboSystem.gd")

var combo_system = null

var achievement_manager = null
var difficulty_manager = null
var combo_system = null
var level_start_time := 0
var combo_tracker := 0

var game_started := false
var game_over := false
var stage_cleared := false
var shop_open := false
var enemies_alive := 0
var score := 0
var gold := 0
var boss_active := true

var upgrades := {"hp": 0, "attack": 0, "speed": 0, "crit": 0}

var current_stage_index := 1
var max_unlocked_stage_index := 1
var max_cleared_stage_index := 0
var stage_cfg := {}

var trap_spawn_timer := 0.0
var trap_spawn_interval := 8.0  # 每 8 秒生成一个陷阱

var selected_chapter := 1
var selected_stage := 1

func _ready() -> void:
    randomize()
    _write_startup_log()

func _write_startup_log() -> void:
    var log_text = ""
    log_text += "=====================================\n"
    log_text += "像素斗士 Pixel Fighter v1.0 - 启动日志\n"
    log_text += "=====================================\n\n"
    log_text += "启动时间：" + str(Time.get_datetime_string_from_system()) + "\n"
    log_text += "Godot 版本：" + str(Engine.godot_version_string()) + "\n\n"
    
    log_text += "文件检查:\n"
    var exe_path = OS.get_executable_path()
    log_text += "- exe 路径：" + exe_path + "\n"
    log_text += "- 运行目录：" + exe_path.get_base_dir() + "\n\n"
    
    var pck_path = exe_path.get_base_dir() + "/PixelFighter_v1.0.pck"
    if FileAccess.file_exists(pck_path):
        log_text += "✓ PCK 文件存在：" + pck_path + " (" + str(FileAccess.get_file_as_bytes(pck_path).size() / 1024) + " KB)\n"
    else:
        log_text += "✗ PCK 文件不存在：" + pck_path + "\n"
        log_text += "  错误：请确保 .exe 和 .pck 文件在同一文件夹内！\n"
    log_text += "\n"
    
    log_text += "系统信息:\n"
    log_text += "- 系统：" + str(OS.get_name()) + " " + str(OS.get_version()) + "\n"
    log_text += "- 屏幕：" + str(DisplayServer.screen_get_size()) + "\n"
    log_text += "- 显卡：" + str(RenderingServer.get_video_adapter_name()) + "\n\n"
    
    log_text += "=====================================\n"
    
    var log_file = exe_path.get_base_dir() + "/game_log.txt"
    var file = FileAccess.open(log_file, FileAccess.WRITE)
    if file:
        file.store_string(log_text)
        file.close()
        print("游戏日志已写入：", log_file)
    else:
        print("无法写入日志：", log_file)
        print("日志内容：\n", log_text)


    pause_mode = Node.PAUSE_MODE_PROCESS
    KeybindManager.apply_from_file("res://keybinds.cfg")
    
    # 初始化成就和难度系统
    achievement_manager = AchievementManager.new()
    add_child(achievement_manager)
    achievement_manager.connect("achievement_unlocked", self, "_on_achievement_unlocked")
    
    difficulty_manager = DifficultyManager.new()
    add_child(difficulty_manager)
    var diff = difficulty_manager.load_difficulty()
    difficulty_manager.set_difficulty(diff)
    
    # 初始化 InputBuffer 并连接到 Player
    var input_buffer = get_node_or_null("InputBuffer")
    if input_buffer != null and player != null:
        player.input_buffer_ref = input_buffer
    
    # 初始化 ComboSystem
    combo_system = ComboSystem.new()
    add_child(combo_system)
    if combo_label != null and combo_count_label != null:
        combo_system.ui_combo_label = combo_label
        combo_system.ui_combo_count_label = combo_count_label
    player.connect("damaged", self, "_on_player_damaged_combo")

    var save = SaveData.load_progress()
    current_stage_index = int(save["current_stage_index"])
    max_unlocked_stage_index = int(save["max_unlocked_stage_index"])
    max_cleared_stage_index = int(save["max_cleared_stage_index"])
    gold = int(save["gold"])
    upgrades = save["upgrades"]

    if not upgrades.has("hp"):
        upgrades["hp"] = 0
    if not upgrades.has("attack"):
        upgrades["attack"] = 0
    if not upgrades.has("speed"):
        upgrades["speed"] = 0
    if not upgrades.has("crit"):
        upgrades["crit"] = 0

    stage_cfg = CampaignData.get_stage(current_stage_index)
    selected_chapter = int(stage_cfg["chapter_id"])
    selected_stage = int(stage_cfg["stage_id"])

    _apply_stage_config(stage_cfg)
    _wire_signals()

    player.set_upgrade_levels(
        int(upgrades["hp"]),
        int(upgrades["attack"]),
        int(upgrades["speed"]),
        int(upgrades["crit"])
    )
    player.heal_full()

    _spawn_stage_minions()
    _refresh_enemy_count()
    _on_weapon_changed(player.current_weapon)
    _set_score(0)
    _set_gold(gold)

    _refresh_stage_ui()
    info_text.text = "Enter Start  Arrow Select  Q Weapon  K Block  SPACE Dash  1-5 Shop  N Next  R Restart"
    story_text.text = CampaignData.story_background() + "\n" + CampaignData.stage_intro_text(stage_cfg)

    _set_combat_enabled(false)
    start_panel.visible = true
    result_panel.visible = false
    shop_panel.visible = false
    _refresh_start_panel_text()

func _process(_delta: float) -> void:
    if not game_started:
        _handle_stage_selection_input()

    if not game_started and Input.is_action_just_pressed("ui_accept"):
        var selected_index = CampaignData.stage_index_from_chapter_stage(selected_chapter, selected_stage)
        if selected_index > max_unlocked_stage_index:
            info_text.text = "Stage Locked - Clear previous stages first"
            return

        if selected_index != current_stage_index:
            current_stage_index = selected_index
            _save_progress()
            get_tree().reload_current_scene()
            return

        game_started = true
        start_panel.visible = false
        info_text.text = "Fight  J Attack  Q Switch Weapon  K Block  SPACE Dash  N Next  R Restart"
        _set_combat_enabled(true)
        level_start_time = OS.get_ticks_msec()

    if shop_open:
        _handle_shop_input()

    if stage_cleared and not shop_open and Input.is_action_just_pressed("next_level"):
        _goto_next_stage()

    if Input.is_action_just_pressed("restart"):
        get_tree().reload_current_scene()
    
    # 生成陷阱
    if game_started and not game_over and not stage_cleared:
        _update_trap_spawning(_delta)

func _wire_signals() -> void:
    player.get_node("AttackArea").connect("body_entered", self, "_on_player_attack_area_body_entered")
    player.connect("hp_changed", self, "_on_player_hp_changed")
    player.connect("died", self, "_on_player_died")
    player.connect("damaged", self, "_on_any_damage", [0.22])
    player.connect("weapon_changed", self, "_on_weapon_changed")

    if enemy.has_signal("died"):
        enemy.connect("died", self, "_on_enemy_died")
    if enemy.has_signal("damaged"):
        enemy.connect("damaged", self, "_on_any_damage", [0.1])

    if boss.has_signal("died"):
        boss.connect("died", self, "_on_enemy_died")
    if boss.has_signal("damaged"):
        boss.connect("damaged", self, "_on_any_damage", [0.14])
    if boss.has_signal("phase_changed"):
        boss.connect("phase_changed", self, "_on_boss_phase_changed")
    if boss.has_signal("request_spawn_minion"):
        boss.connect("request_spawn_minion", self, "_spawn_minion_at")
    if boss.has_signal("aoe_cast"):
        boss.connect("aoe_cast", self, "_on_any_damage", [0.28])

func _handle_stage_selection_input() -> void:
    var changed = false

    if Input.is_action_just_pressed("ui_left"):
        selected_chapter = max(1, selected_chapter - 1)
        selected_stage = min(selected_stage, CampaignData.chapter_stage_count(selected_chapter))
        changed = true
    elif Input.is_action_just_pressed("ui_right"):
        selected_chapter = min(CampaignData.chapter_count(), selected_chapter + 1)
        selected_stage = min(selected_stage, CampaignData.chapter_stage_count(selected_chapter))
        changed = true

    if Input.is_action_just_pressed("ui_up"):
        selected_stage = max(1, selected_stage - 1)
        changed = true
    elif Input.is_action_just_pressed("ui_down"):
        selected_stage = min(CampaignData.chapter_stage_count(selected_chapter), selected_stage + 1)
        changed = true

    if changed:
        _refresh_start_panel_text()

func _handle_shop_input() -> void:
    if Input.is_action_just_pressed("shop_buy_hp"):
        _buy_upgrade("hp")
    elif Input.is_action_just_pressed("shop_buy_attack"):
        _buy_upgrade("attack")
    elif Input.is_action_just_pressed("shop_buy_heal"):
        _buy_heal()
    elif Input.is_action_just_pressed("shop_buy_speed"):
        _buy_upgrade("speed")
    elif Input.is_action_just_pressed("shop_buy_crit"):
        _buy_upgrade("crit")

    if Input.is_action_just_pressed("next_level"):
        shop_open = false
        shop_panel.visible = false
        _goto_next_stage()

func _on_player_attack_area_body_entered(body: Node) -> void:
    if not game_started or game_over:
        return

    if body.has_method("take_damage") and body != player:
        var hit_position = body.global_position
        body.take_damage(player.current_attack_damage, player.global_position, 250.0)
        
        # 暴击或连击时触发状态效果（20% 概率）
        if randf() < 0.2 and body.has_node("StatusEffects"):
            var effect_types = [1, 2, 4]  # BURN, FREEZE, BLEED
            var effect = effect_types[randi() % effect_types.size()]
            body.status_effects.apply_effect(effect, 2.0)
        
        # Combo 计数
        if combo_system != null:
            combo_system.add_hit()
        
        # 命中停顿
        var hit_stop_manager = get_node_or_null("HitStopManager")
        if hit_stop_manager != null and hit_stop_manager.has_method("trigger_hit_stop"):
            hit_stop_manager.trigger_hit_stop(0.08)
        
        # 打击特效
        var hit_effects = get_node_or_null("HitEffects")
        if hit_effects != null and hit_effects.has_method("spawn_hit_effect"):
            var effect_type = ["spark", "spark", "spark", "slash"].pick_random()
            var direction = 0.0 if player.global_position.x <= body.global_position.x else PI
            hit_effects.spawn_hit_effect(effect_type, hit_position, direction)
        
        _on_any_damage(0.12)
    
    # 更新玩家攻击特效（按武器类型）
    if player != null and player.attack_effect != null and player.attack_area.monitoring:
        player.attack_effect.play(player.global_position + Vector2(36 * player.face_dir, 0), player.face_dir, player.current_weapon)

func _on_player_damaged_combo() -> void:
    if combo_system != null:
        combo_system.reset_combo()

func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
    var ratio := float(current_hp) / float(max_hp)
    hp_fill.rect_size.x = 240.0 * clamp(ratio, 0.0, 1.0)
    hp_text.text = "HP: %d/%d" % [max(current_hp, 0), max_hp]

func _on_player_died() -> void:
    game_over = true
    stage_cleared = false
    result_panel.visible = true
    result_text.text = "Defeat"
    info_text.text = "You Died - Press R to Restart"
    _set_combat_enabled(false)

func _on_enemy_died(drop_position := Vector2.ZERO, score_value := 0) -> void:
    # 成就追踪
    if score_value == 10 and achievement_manager != null:  # 普通敌人
        achievement_manager.unlock_first_blood()
    if score_value >= 60:  # Boss
        achievement_manager.increment_boss_kill()
    
    _spawn_drop(drop_position, score_value)
    enemies_alive = max(enemies_alive - 1, 0)
    if not game_over and enemies_alive == 0:
        game_over = true
        stage_cleared = true
        result_panel.visible = true

        var clear_text = CampaignData.stage_clear_text(stage_cfg)
        var chapter_stage_count = CampaignData.chapter_stage_count(int(stage_cfg["chapter_id"]))
        if int(stage_cfg["stage_id"]) >= chapter_stage_count:
            clear_text += "\n" + CampaignData.chapter_clear_text(int(stage_cfg["chapter_id"]))
            # 成就：章节完成
            if achievement_manager != null:
                achievement_manager.unlock_chapter(int(stage_cfg["chapter_id"]))

        var stage_reward = _stage_reward_gold()
        _set_gold(gold + stage_reward)

        result_text.text = "Stage Cleared  Score: %d" % score
        
        # 速通检测
        var level_time = 0
        if level_start_time > 0:
            level_time = int((OS.get_ticks_msec() - level_start_time) / 1000.0)
            clear_text += "\nTime: %d.%ds" % [level_time / 1000, (level_time % 1000) / 100]
            if achievement_manager != null:
                achievement_manager.check_speed_run(level_time)
        
        info_text.text = clear_text + "\nReward Gold: %d" % stage_reward
        _set_combat_enabled(false)

        var total = CampaignData.total_stages()
        var next_idx = min(current_stage_index + 1, total)
        max_cleared_stage_index = max(max_cleared_stage_index, current_stage_index)
        max_unlocked_stage_index = max(max_unlocked_stage_index, next_idx)
        _save_progress()

        _open_shop_panel()

func _set_combat_enabled(enabled: bool) -> void:
    if player != null:
        player.set_physics_process(enabled)
    if enemy != null and enemy.is_inside_tree():
        enemy.set_physics_process(enabled)
    if boss != null and boss.is_inside_tree():
        boss.set_physics_process(enabled and boss_active)

    for child in get_children():
        if child != null and child.name.begins_with("Minion"):
            child.set_physics_process(enabled)

func _on_any_damage(amount: float) -> void:
    if camera != null:
        camera.add_trauma(amount)

func _spawn_drop(world_position: Vector2, value: int) -> void:
    if value <= 0:
        return

    var drop = DropCoin.new()
    add_child(drop)
    drop.global_position = world_position + Vector2(0, -8)
    drop.score_value = value
    drop.connect("collected", self, "_on_drop_collected")

func _on_drop_collected(value: int) -> void:
    _set_score(score + value)
    _set_gold(gold + value)

func _set_score(value: int) -> void:
    score = max(value, 0)
    score_text.text = "Score: %d" % score

func _set_gold(value: int) -> void:
    gold = max(0, value)
    gold_text.text = "Gold: %d" % gold

func _on_weapon_changed(weapon_name: String) -> void:
    weapon_text.text = "Weapon: %s" % weapon_name.capitalize()

func _on_boss_phase_changed(phase: int) -> void:
    if phase >= 2:
        info_text.text = "Boss Enraged - Keep Distance"

func _spawn_minion_at(world_position: Vector2) -> void:
    var minion = KinematicBody2D.new()
    minion.name = "Minion_%d" % randi()
    minion.set_script(preload("res://scripts/Enemy.gd"))
    minion.position = world_position
    minion.max_hp = int(stage_cfg["enemy_hp"])
    minion.move_speed = int(stage_cfg["enemy_speed"]) + 8
    minion.detect_range = 220
    minion.attack_damage = max(1, int(stage_cfg["boss_attack"]) - 1)
    minion.attack_cooldown = 0.9
    minion.patrol_left_x = world_position.x - 90
    minion.patrol_right_x = world_position.x + 90
    minion.player_path = NodePath("../Player")
    
    # 设置精英类型（30% 概率）
    var is_elite = randf() < 0.3
    var enemy_type = 0
    
    if is_elite:
        # 随机精英类型
        enemy_type = [1, 2, 3].pick_random()
        minion.move_speed += 20 if enemy_type == 1 else 0  # 快速型
        minion.max_hp += 3 if enemy_type == 2 else 0  # 坦克型
    
    var col = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.extents = Vector2(16, 24)
    col.shape = rect
    minion.add_child(col)
    
    # 添加精灵
    var sprite = Sprite.new()
    var sprite_script = preload("res://scripts/EnemySprite.gd")
    sprite.set_script(sprite_script)
    sprite.enemy_type = enemy_type
    sprite.color = _get_enemy_color_by_type(enemy_type)
    sprite.pixel_size = 4
    minion.add_child(sprite)
    
    add_child(minion)
    enemies_alive += 1
    if minion.has_signal("died"):
        minion.connect("died", self, "_on_enemy_died")
    if minion.has_signal("damaged"):
        minion.connect("damaged", self, "_on_any_damage", [0.08])
    minion.set_physics_process(game_started and not game_over)

func _get_enemy_color_by_type(type: int) -> Color:
    match type:
        1: return Color(0.3, 0.7, 0.9, 1.0)  # 快速型 - 蓝色
        2: return Color(0.7, 0.6, 0.3, 1.0)  # 坦克型 - 土黄
        3: return Color(0.7, 0.3, 0.8, 1.0)  # 法师型 - 紫色
        _: return Color(0.8, 0.3, 0.2, 1.0)  # 普通型 - 红色

func _spawn_stage_minions() -> void:
    var extra_count = max(0, int(stage_cfg["enemy_count"]) - 1)
    for i in range(extra_count):
        var spawn_x = 320 + i * 72
        _spawn_minion_at(Vector2(spawn_x, 500))

func _refresh_enemy_count() -> void:
    enemies_alive = 0
    if enemy != null and enemy.is_inside_tree():
        enemies_alive += 1
    if boss_active and boss != null and boss.is_inside_tree():
        enemies_alive += 1
    for child in get_children():
        if child != null and child.name.begins_with("Minion") and child.is_inside_tree():
            enemies_alive += 1

func _apply_stage_config(cfg: Dictionary) -> void:
    var diff_data = {} if difficulty_manager == null else difficulty_manager.get_difficulty_data()
    var hp_scale = diff_data.get("enemy_hp_scale", 1.0) if difficulty_manager != null else 1.0
    
    # 设置敌人类型（根据关卡变化）
    var chapter_id = int(cfg["chapter_id"])
    var stage_id = int(cfg["stage_id"])
    
    # 设置敌人类型：根据章节决定
    if enemy.has_node("EnemySprite"):
        var enemy_sprite = enemy.get_node("EnemySprite")
        if chapter_id <= 2:
            enemy_sprite.enemy_type = 0  # 普通型
        elif chapter_id <= 4:
            enemy_sprite.enemy_type = 1 if randf() > 0.5 else 2  # 快速或坦克
        elif chapter_id <= 6:
            enemy_sprite.enemy_type = [1, 2, 3].pick_random()  # 多种类型
        else:
            enemy_sprite.enemy_type = [0, 1, 2, 3].pick_random()  # 混合
    
    enemy.max_hp = difficulty_manager.apply_to_enemy_hp(int(cfg["enemy_hp"])) if difficulty_manager != null else int(cfg["enemy_hp"])
    enemy.hp = enemy.max_hp
    enemy.move_speed = int(cfg["enemy_speed"])
    enemy.attack_damage = difficulty_manager.apply_to_enemy_damage(max(1, int(cfg["boss_attack"]) - 1)) if difficulty_manager != null else max(1, int(cfg["boss_attack"]) - 1)

    # 设置 Boss 类型（根据章节）
    if boss.has_node("BossSprite"):
        var boss_sprite = boss.get_node("BossSprite")
        boss_sprite.boss_id = chapter_id  # 章节对应 Boss ID
        
        # 根据章节设置 Boss 颜色
        match chapter_id:
            1: boss_sprite.color = Color(0.9, 0.3, 0.1, 1.0)  # 熔铁 - 橙红
            2: boss_sprite.color = Color(0.6, 0.5, 0.3, 1.0)  # 岩脊 - 土黄
            3: boss_sprite.color = Color(0.4, 0.7, 0.9, 1.0)  # 裂风 - 青蓝
            4: boss_sprite.color = Color(0.3, 0.7, 0.3, 1.0)  # 疫藤 - 绿色
            5: boss_sprite.color = Color(0.7, 0.7, 0.8, 1.0)  # 镜像 - 银灰
            6: boss_sprite.color = Color(0.9, 0.9, 0.2, 1.0)  # 雷核 - 金黄
            7: boss_sprite.color = Color(0.5, 0.8, 1.0, 1.0)  # 白霜 - 冰蓝
            8: boss_sprite.color = Color(0.6, 0.4, 0.7, 1.0)  # 幕影 - 紫色
            9: boss_sprite.color = Color(0.8, 0.5, 0.2, 1.0)  # 天陨 - 橙褐
            10: boss_sprite.color = Color(0.9, 0.1, 0.2, 1.0)  # 终焉 - 深红
    
    boss.max_hp = difficulty_manager.apply_to_boss_hp(int(cfg["boss_hp"])) if difficulty_manager != null else int(cfg["boss_hp"])
    boss.hp = boss.max_hp
    boss.move_speed = int(cfg["boss_move"])
    boss.dash_speed = int(cfg["boss_dash"])
    boss.attack_damage = difficulty_manager.apply_to_boss_damage(int(cfg["boss_attack"])) if difficulty_manager != null else int(cfg["boss_attack"])
    boss.phase2_hp_ratio = float(cfg["boss_phase_ratio"])
    boss.summon_cooldown = float(cfg["boss_summon_cd"])
    boss.aoe_cooldown = float(cfg["boss_aoe_cd"])

    _set_boss_active(bool(cfg["boss_enabled"]))

func _goto_next_stage() -> void:
    var total = CampaignData.total_stages()
    if current_stage_index >= total:
        info_text.text = "Campaign Completed - Press R to Restart"
        result_text.text = "All Chapters Cleared"
        result_panel.visible = true
        # 检查完全体成就
        if achievement_manager != null:
            achievement_manager.check_full_upgrade(upgrades)
        return

    current_stage_index += 1
    _save_progress()
    get_tree().reload_current_scene()

func _refresh_stage_ui() -> void:
    level_text.text = "Chapter %d-%d  %s" % [int(stage_cfg["chapter_id"]), int(stage_cfg["stage_id"]), str(stage_cfg["stage_name"])]

func _refresh_start_panel_text() -> void:
    var picked = CampaignData.get_stage_by_chapter_stage(selected_chapter, selected_stage)
    var picked_index = CampaignData.stage_index_from_chapter_stage(selected_chapter, selected_stage)
    var locked = picked_index > max_unlocked_stage_index
    var lock_text = "Locked" if locked else "Unlocked"
    var boss_name = "None"
    if bool(picked["boss_enabled"]):
        boss_name = str(picked["boss"])

    start_text.text = "Select Chapter/Stage\nChapter %d - Stage %d (%s)\n%s\nTheme: %s\nBoss: %s\n%s\nArrow Select, Enter Confirm" % [
        selected_chapter,
        selected_stage,
        lock_text,
        str(picked["stage_name"]),
        str(picked["theme"]),
        boss_name,
        _build_campaign_overview_text()
    ]

func _build_campaign_overview_text() -> String:
    var lines = []
    lines.append("Map C:Cleared U:Unlocked L:Locked")

    for chapter_id in range(1, CampaignData.chapter_count() + 1):
        var stage_total = CampaignData.chapter_stage_count(chapter_id)
        var line = "Ch%02d " % chapter_id
        for stage_id in range(1, stage_total + 1):
            var idx = CampaignData.stage_index_from_chapter_stage(chapter_id, stage_id)
            var marker = "L"
            if idx <= max_cleared_stage_index:
                marker = "C"
            elif idx <= max_unlocked_stage_index:
                marker = "U"

            if chapter_id == selected_chapter and stage_id == selected_stage:
                line += "(%s)" % marker
            else:
                line += "[%s]" % marker
        lines.append(line)

    return PoolStringArray(lines).join("\n")

func _open_shop_panel() -> void:
    shop_open = true
    shop_panel.visible = true
    info_text.text = "Shop Open - Press 1/2/3/4/5, N Next Stage"
    _refresh_shop_text()

func _refresh_shop_text() -> void:
    var hp_cost = _upgrade_cost("hp")
    var atk_cost = _upgrade_cost("attack")
    var spd_cost = _upgrade_cost("speed")
    var crit_cost = _upgrade_cost("crit")
    var heal_cost = 25

    shop_text.text = "Shop\nGold: %d\n1 HP Upgrade Lv.%d (Cost %d)\n2 Attack Upgrade Lv.%d (Cost %d)\n3 Full Heal (Cost %d)\n4 Speed Upgrade Lv.%d (Cost %d)\n5 Crit Upgrade Lv.%d (Cost %d)\nN Next Stage" % [
        gold,
        int(upgrades["hp"]),
        hp_cost,
        int(upgrades["attack"]),
        atk_cost,
        heal_cost,
        int(upgrades["speed"]),
        spd_cost,
        int(upgrades["crit"]),
        crit_cost
    ]

func _buy_upgrade(kind: String) -> void:
    var cost = _upgrade_cost(kind)
    if gold < cost:
        info_text.text = "Not enough gold"
        return

    gold -= cost
    upgrades[kind] = int(upgrades[kind]) + 1
    player.set_upgrade_levels(
        int(upgrades["hp"]),
        int(upgrades["attack"]),
        int(upgrades["speed"]),
        int(upgrades["crit"])
    )
    _set_gold(gold)
    _refresh_shop_text()
    _save_progress()

func _buy_heal() -> void:
    var heal_cost = 25
    if gold < heal_cost:
        info_text.text = "Not enough gold"
        return

    gold -= heal_cost
    player.heal_full()
    _set_gold(gold)
    _refresh_shop_text()
    _save_progress()

func _upgrade_cost(kind: String) -> int:
    var lv = int(upgrades[kind])
    if kind == "hp":
        return 40 + lv * 20
    if kind == "attack":
        return 50 + lv * 25
    if kind == "speed":
        return 60 + lv * 28
    if kind == "crit":
        return 70 + lv * 34
    return 999

func _stage_reward_gold() -> int:
    var base = int(stage_cfg["enemy_count"]) * 10
    if bool(stage_cfg["boss_enabled"]):
        base += 30
    base += int(stage_cfg["chapter_id"]) * 3
    return base

func _save_progress() -> void:
    SaveData.save_progress({
        "current_stage_index": current_stage_index,
        "max_unlocked_stage_index": max_unlocked_stage_index,
        "max_cleared_stage_index": max_cleared_stage_index,
        "gold": gold,
        "upgrades": upgrades
    })

func _on_achievement_unlocked(achievement_id: String) -> void:
    var ach = achievement_manager.achievements[achievement_id]
    info_text.text = "🏆 Achievement Unlocked: %s" % ach["name"]
    yield(get_tree().create_timer(3.0), "timeout")
    info_text.text = "Fight  Q Weapon  N Next  R Restart"

func _on_drop_collected(value: int) -> void:
    _set_score(score + value)
    _set_gold(gold + value)
    if achievement_manager != null:
        achievement_manager.increment_gold(value)

func _update_trap_spawning(delta: float) -> void:
    trap_spawn_timer += delta
    if trap_spawn_timer >= trap_spawn_interval:
        trap_spawn_timer = 0
        _spawn_random_trap()

func _spawn_random_trap() -> void:
    var trap_types = [0, 1, 2]  # 尖刺/落石/岩浆
    var trap_type = trap_types[randi() % trap_types.size()]
    
    # 根据章节选择陷阱类型
    var chapter_id = int(stage_cfg["chapter_id"])
    if chapter_id <= 2:
        trap_type = 0  # 早期只有尖刺
    elif chapter_id <= 4:
        trap_type = [0, 1].pick_random()  # 加入落石
    else:
        trap_type = [0, 1, 2].pick_random()  # 全部类型
    
    var trap = preload("res://scripts/TrapSystem.gd").new()
    trap.trap_type = trap_type
    trap.damage = max(1, int(stage_cfg["enemy_speed"]) / 30)  # 伤害随关卡增加
    trap.name = "Trap_%d" % randi()
    
    # 随机生成位置
    var trap_x = rand_range(200, 1000)
    var trap_y = 580 if trap_type == 0 else 30 if trap_type == 1 else 600
    
    trap.position = Vector2(trap_x, trap_y)
    
    # 添加碰撞体
    var area = Area2D.new()
    var col = CollisionShape2D.new()
    
    if trap_type == 0:  # 尖刺
        var rect = RectangleShape2D.new()
        rect.extents = Vector2(100, 15)
        col.shape = rect
        trap.add_child(area)
        area.add_child(col)
        area.connect("body_entered", trap, "_on_body_entered")
        area.connect("body_exited", trap, "_on_body_exited")
    elif trap_type == 1:  # 落石
        var circle = CircleShape2D.new()
        circle.radius = 40
        col.shape = circle
        trap.add_child(area)
        area.add_child(col)
        area.connect("body_entered", trap, "_on_body_entered")
        area.connect("body_exited", trap, "_on_body_exited")
    elif trap_type == 2:  # 岩浆
        var rect = RectangleShape2D.new()
        rect.extents = Vector2(400, 20)
        col.shape = rect
        trap.add_child(area)
        area.add_child(col)
        area.connect("body_entered", trap, "_on_body_entered")
        area.connect("body_exited", trap, "_on_body_exited")
    
    add_child(trap)
    
    # 20 秒后清理陷阱
    yield(get_tree().create_timer(20.0), "timeout")
    if trap.is_inside_tree():
        trap.queue_free()
