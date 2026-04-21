extends Reference

const ACTIONS := ["ui_left", "ui_right", "ui_up", "attack", "switch_weapon", "next_level", "restart"]

static func apply_from_file(config_path: String) -> void:
    var cfg := ConfigFile.new()
    if cfg.load(config_path) != OK:
        return

    for action in ACTIONS:
        if not cfg.has_section_key("keys", action):
            continue

        var key_name := str(cfg.get_value("keys", action)).strip_edges()
        var scancode := OS.find_scancode_from_string(key_name)
        if scancode == 0:
            continue

        InputMap.action_erase_events(action)
        var ev := InputEventKey.new()
        ev.scancode = scancode
        InputMap.action_add_event(action, ev)
