extends Node2D

# Boss 血条脚本
onready var boss := get_parent().get_node_or_null("Boss")
onready var hp_fill := $BossHpBarBg/BossHpBarFill
onready var boss_hp_text := $BossHpText

var max_hp := 10
var current_hp := 10

func _ready() -> void:
    visible = false
    if boss != null and boss.has_signal("damaged"):
        boss.connect("damaged", self, "_on_boss_damaged")
        max_hp = boss.max_hp
        current_hp = boss.hp
        _update_hp_bar()

func _on_boss_damaged() -> void:
    if boss != null:
        current_hp = boss.hp
        max_hp = boss.max_hp
        _update_hp_bar()
        
        # Boss 血量 > 0 时显示血条
        if current_hp > 0 and not visible:
            visible = true

func _update_hp_bar() -> void:
    if max_hp <= 0:
        return
    
    var ratio = float(current_hp) / float(max_hp)
    hp_fill.rect_size.x = 300.0 * clamp(ratio, 0.0, 1.0)
    boss_hp_text.text = "BOSS HP: %d/%d" % [current_hp, max_hp]
    
    # 低血量时变色
    if ratio < 0.3:
        boss_hp_text.modulate = Color(1.0, 0.2, 0.2, 1.0)
    elif ratio < 0.6:
        boss_hp_text.modulate = Color(1.0, 0.8, 0.2, 1.0)
    else:
        boss_hp_text.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _process(_delta: float) -> void:
    # Boss 死亡后隐藏血条
    if boss == null or not boss.is_inside_tree() or current_hp <= 0:
        visible = false
