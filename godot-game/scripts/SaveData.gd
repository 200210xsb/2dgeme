extends Reference

const SAVE_PATH := "user://campaign_save.json"

static func _default_data() -> Dictionary:
    return {
        "current_stage_index": 1,
        "max_unlocked_stage_index": 1,
        "gold": 0,
        "upgrades": {
            "hp": 0,
            "attack": 0
        }
    }

static func load_progress() -> Dictionary:
    var result = _default_data()
    var file = File.new()
    if not file.file_exists(SAVE_PATH):
        return result

    var err = file.open(SAVE_PATH, File.READ)
    if err != OK:
        return result

    var text = file.get_as_text()
    file.close()
    var parsed = JSON.parse(text)
    if parsed.error != OK or typeof(parsed.result) != TYPE_DICTIONARY:
        return result

    var data = parsed.result

    if data.has("current_stage_index"):
        result.current_stage_index = int(data.current_stage_index)
    elif data.has("current_level"):
        result.current_stage_index = int(data.current_level)

    if data.has("max_unlocked_stage_index"):
        result.max_unlocked_stage_index = int(data.max_unlocked_stage_index)
    elif data.has("max_unlocked"):
        result.max_unlocked_stage_index = int(data.max_unlocked)

    if data.has("gold"):
        result.gold = int(data.gold)

    if data.has("upgrades") and typeof(data.upgrades) == TYPE_DICTIONARY:
        var up = data.upgrades
        if up.has("hp"):
            result.upgrades.hp = int(up.hp)
        if up.has("attack"):
            result.upgrades.attack = int(up.attack)

    result.current_stage_index = max(1, result.current_stage_index)
    result.max_unlocked_stage_index = max(1, result.max_unlocked_stage_index)
    result.gold = max(0, result.gold)
    result.upgrades.hp = max(0, result.upgrades.hp)
    result.upgrades.attack = max(0, result.upgrades.attack)
    return result

static func save_progress(data: Dictionary) -> void:
    var content = _default_data()

    if data.has("current_stage_index"):
        content.current_stage_index = max(1, int(data.current_stage_index))
    if data.has("max_unlocked_stage_index"):
        content.max_unlocked_stage_index = max(1, int(data.max_unlocked_stage_index))
    if data.has("gold"):
        content.gold = max(0, int(data.gold))

    if data.has("upgrades") and typeof(data.upgrades) == TYPE_DICTIONARY:
        var up = data.upgrades
        if up.has("hp"):
            content.upgrades.hp = max(0, int(up.hp))
        if up.has("attack"):
            content.upgrades.attack = max(0, int(up.attack))

    var file = File.new()
    var err = file.open(SAVE_PATH, File.WRITE)
    if err != OK:
        return
    file.store_string(JSON.print(content))
    file.close()
