extends HBoxContainer

# 状态效果 UI 显示
const EFFECT_ICONS = {
    1: "☠",  # POISON
    2: "🔥",  # BURN
    3: "❄",  # FREEZE
    4: "💫",  # STUN
    5: "🩸"   # BLEED
}

const EFFECT_COLORS = {
    1: Color(0.4, 0.8, 0.2),   # POISON - 绿色
    2: Color(1.0, 0.4, 0.0),   # BURN - 橙色
    3: Color(0.2, 0.6, 1.0),   # FREEZE - 蓝色
    4: Color(1.0, 1.0, 0.2),   # STUN - 黄色
    5: Color(1.0, 0.2, 0.2)    # BLEED - 红色
}

var player = null
var icon_nodes = {}

func _ready() -> void:
    player = get_parent().get_node_or_null("../Player")
    
    # 延迟获取，确保玩家节点已初始化
    yield(get_tree().create_timer(0.5), "timeout")
    if player == null:
        player = get_tree().current_scene.get_node_or_null("Player")

func _process(_delta: float) -> void:
    if player == null or not player.is_inside_tree():
        return
    
    if not player.has_node("StatusEffects") or player.status_effects == null:
        return
    
    _update_effect_icons()

func _update_effect_icons() -> void:
    var status = player.status_effects
    var active_effects = status.active_effects
    
    # 清除不存在的图标
    for effect_type in icon_nodes.keys():
        if not active_effects.has(effect_type):
            var node = icon_nodes[effect_type]
            if node and is_instance_valid(node):
                node.queue_free()
            icon_nodes.erase(effect_type)
    
    # 添加新的图标
    for effect_type in active_effects.keys():
        if not icon_nodes.has(effect_type):
            var label = Label.new()
            label.text = EFFECT_ICONS.get(effect_type, "")
            label.modulate = EFFECT_COLORS.get(effect_type, Color.white)
            label.rect_min_size = Vector2(40, 40)
            label.align = HALIGN_CENTER
            label.add_color_override("font_color", EFFECT_COLORS.get(effect_type, Color.white))
            
            # 添加时间显示
            var time_label = Label.new()
            time_label.name = "TimeLabel"
            time_label.rect_min_size = Vector2(40, 15)
            time_label.align = HALIGN_CENTER
            time_label.add_color_override("font_color", Color(0.7, 0.7, 0.7, 0.8))
            
            add_child(label)
            add_child(time_label)
            icon_nodes[effect_type] = label
    
    # 更新时间
    for effect_type in active_effects.keys():
        if icon_nodes.has(effect_type):
            var data = active_effects[effect_type]
            var time_left = ceil(data["time_left"])
            var stack = data["stack"]
            
            var label = icon_nodes[effect_type]
            if label and is_instance_valid(label):
                label.text = "%s x%d" % [EFFECT_ICONS.get(effect_type, ""), stack]
            
            # 查找时间标签
            for child in get_children():
                if child.name == "TimeLabel" and child.get_index() == icon_nodes.keys().find(effect_type) * 2 + 1:
                    child.text = "%.1fs" % time_left
