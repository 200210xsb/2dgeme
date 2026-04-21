extends Node

# 输入缓冲系统 - 提升操作流畅度
const BUFFER_TIME := 0.15  # 输入缓冲时间（秒）

var input_buffer := {}  # {action_name: {time, pressed, just_pressed}}

signal action_triggered(action_name)

func _ready() -> void:
    set_process(true)

func _process(delta: float) -> void:
    # 清理过期输入
    var actions_to_remove = []
    for action in input_buffer.keys():
        input_buffer[action]["time"] -= delta
        if input_buffer[action]["time"] <= 0:
            actions_to_remove.append(action)
    
    for action in actions_to_remove:
        input_buffer.erase(action)

# 记录输入
func buffer_input(action_name: String) -> void:
    if action_name == "":
        return
    
    input_buffer[action_name] = {
        "time": BUFFER_TIME,
        "pressed": Input.is_action_pressed(action_name),
        "just_pressed": Input.is_action_just_pressed(action_name)
    }

# 检查缓冲输入
func is_action_buffered(action_name: String) -> bool:
    return input_buffer.has(action_name) and input_buffer[action_name]["time"] > 0

func is_action_just_pressed_buffered(action_name: String) -> bool:
    if not input_buffer.has(action_name):
        return false
    
    var data = input_buffer[action_name]
    return data["time"] > 0 and data["just_pressed"]

# 尝试使用缓冲输入
func consume_action(action_name: String) -> bool:
    if is_action_just_pressed_buffered(action_name):
        emit_signal("action_triggered", action_name)
        input_buffer.erase(action_name)
        return true
    return false

# 获取移动输入（带缓冲）
func get_move_direction() -> float:
    var left_buffered = is_action_buffered("ui_left")
    var right_buffered = is_action_buffered("ui_right")
    
    var left = Input.get_action_strength("ui_left")
    var right = Input.get_action_strength("ui_right")
    
    # 优先使用缓冲输入
    if left_buffered and not right_buffered:
        return -1.0
    elif right_buffered and not left_buffered:
        return 1.0
    
    # 否则使用实时输入
    return right - left

# 检查跳跃（带缓冲）
func is_jump_pressed_buffered() -> bool:
    return consume_action("ui_up") or Input.is_action_just_pressed("ui_up")

# 检查攻击（带缓冲）
func is_attack_pressed_buffered() -> bool:
    return consume_action("attack") or Input.is_action_just_pressed("attack")
