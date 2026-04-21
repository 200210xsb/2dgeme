extends Node

# 难度系统
enum Difficulty { EASY, NORMAL, HARD }

const DIFFICULTY_DATA = {
    Difficulty.EASY: {
        "name": "简单",
        "enemy_hp_scale": 0.7,
        "enemy_damage_scale": 0.7,
        "boss_hp_scale": 0.8,
        "boss_damage_scale": 0.75,
        "player_hp_bonus": 2,
        "gold_bonus": 1.0
    },
    Difficulty.NORMAL: {
        "name": "普通",
        "enemy_hp_scale": 1.0,
        "enemy_damage_scale": 1.0,
        "boss_hp_scale": 1.0,
        "boss_damage_scale": 1.0,
        "player_hp_bonus": 0,
        "gold_bonus": 1.0
    },
    Difficulty.HARD: {
        "name": "困难",
        "enemy_hp_scale": 1.4,
        "enemy_damage_scale": 1.5,
        "boss_hp_scale": 1.5,
        "boss_damage_scale": 1.6,
        "player_hp_bonus": 0,
        "gold_bonus": 1.5
    }
}

var current_difficulty := Difficulty.NORMAL
var save_path = "user://difficulty.json"

func set_difficulty(diff: int) -> void:
    current_difficulty = clamp(diff, 0, 2)
    save_difficulty()

func get_difficulty_data() -> Dictionary:
    return DIFFICULTY_DATA[current_difficulty]

func apply_to_enemy_hp(base_hp: int) -> int:
    return int(float(base_hp) * get_difficulty_data()["enemy_hp_scale"])

func apply_to_enemy_damage(base_damage: int) -> int:
    return int(float(base_damage) * get_difficulty_data()["enemy_damage_scale"])

func apply_to_boss_hp(base_hp: int) -> int:
    return int(float(base_hp) * get_difficulty_data()["boss_hp_scale"])

func apply_to_boss_damage(base_damage: int) -> int:
    return int(float(base_damage) * get_difficulty_data()["boss_damage_scale"])

func apply_to_player_hp(base_hp: int) -> int:
    return base_hp + get_difficulty_data()["player_hp_bonus"]

func apply_to_gold(base_gold: int) -> int:
    return int(float(base_gold) * get_difficulty_data()["gold_bonus"])

func get_difficulty_name() -> String:
    return get_difficulty_data()["name"]

func save_difficulty() -> void:
    var file = File.new()
    file.open(save_path, File.WRITE)
    file.store_string(to_json({"difficulty": current_difficulty}))
    file.close()

func load_difficulty() -> int:
    var file = File.new()
    if not file.file_exists(save_path):
        return Difficulty.NORMAL
    file.open(save_path, File.READ)
    var json_text = file.get_as_text()
    file.close()
    
    if json_text != "":
        var result = parse_json(json_text)
        if result is Dictionary and result.has("difficulty"):
            return result["difficulty"]
    
    return Difficulty.NORMAL
