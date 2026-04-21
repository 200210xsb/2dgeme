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

const KeybindManager = preload("res://scripts/KeybindManager.gd")
const CampaignData = preload("res://scripts/CampaignData.gd")
const SaveData = preload("res://scripts/SaveData.gd")
const DropCoin = preload("res://scripts/DropCoin.gd")

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

var selected_chapter := 1
var selected_stage := 1

func _ready() -> void:
    randomize()
    pause_mode = Node.PAUSE_MODE_PROCESS
    KeybindManager.apply_from_file("res://keybinds.cfg")

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
    info_text.text = "Enter Start  Arrow Select  Q Weapon  1-5 Shop  N Next  R Restart"
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
        info_text.text = "Fight  Q Weapon  N Next  R Restart"
        _set_combat_enabled(true)

    if shop_open:
        _handle_shop_input()

    if stage_cleared and not shop_open and Input.is_action_just_pressed("next_level"):
        _goto_next_stage()

    if Input.is_action_just_pressed("restart"):
        get_tree().reload_current_scene()

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
        body.take_damage(player.current_attack_damage, player.global_position, 250.0)
        _on_any_damage(0.12)

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

        var stage_reward = _stage_reward_gold()
        _set_gold(gold + stage_reward)

        result_text.text = "Stage Cleared  Score: %d" % score
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

    var col = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.extents = Vector2(16, 24)
    col.shape = rect
    minion.add_child(col)

    add_child(minion)
    enemies_alive += 1
    if minion.has_signal("died"):
        minion.connect("died", self, "_on_enemy_died")
    if minion.has_signal("damaged"):
        minion.connect("damaged", self, "_on_any_damage", [0.08])
    minion.set_physics_process(game_started and not game_over)

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
    enemy.max_hp = int(cfg["enemy_hp"])
    enemy.hp = enemy.max_hp
    enemy.move_speed = int(cfg["enemy_speed"])
    enemy.attack_damage = max(1, int(cfg["boss_attack"]) - 1)

    boss.max_hp = int(cfg["boss_hp"])
    boss.hp = boss.max_hp
    boss.move_speed = int(cfg["boss_move"])
    boss.dash_speed = int(cfg["boss_dash"])
    boss.attack_damage = int(cfg["boss_attack"])
    boss.phase2_hp_ratio = float(cfg["boss_phase_ratio"])
    boss.summon_cooldown = float(cfg["boss_summon_cd"])
    boss.aoe_cooldown = float(cfg["boss_aoe_cd"])

    _set_boss_active(bool(cfg["boss_enabled"]))

func _set_boss_active(active: bool) -> void:
    boss_active = active
    boss.visible = active
    boss.set_physics_process(active and game_started and not game_over)
    if boss_collision != null:
        boss_collision.disabled = not active

func _goto_next_stage() -> void:
    var total = CampaignData.total_stages()
    if current_stage_index >= total:
        info_text.text = "Campaign Completed - Press R to Restart"
        result_text.text = "All Chapters Cleared"
        result_panel.visible = true
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
