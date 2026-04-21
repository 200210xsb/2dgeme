extends Reference

const ACTIONS := [
    "ui_left",
    "ui_right",
    "ui_up",
    "ui_down",
    "attack",
    "switch_weapon",
    "block",
    "dash",
    "next_level",
    "restart",
    "shop_buy_hp",
    "shop_buy_attack",
    "shop_buy_heal",
    "shop_buy_speed",
    "shop_buy_crit"
]

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

        if not InputMap.has_action(action):
            InputMap.add_action(action)

        InputMap.action_erase_events(action)
        var ev := InputEventKey.new()
        ev.scancode = scancode
        InputMap.action_add_event(action, ev)
