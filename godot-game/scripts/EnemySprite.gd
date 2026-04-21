extends Sprite

# 像素风格敌人精灵 - 支持多种类型
export var enemy_type := 0  # 0=普通，1=快速型，2=坦克型，3=飞行型，4=法师型
export var color := Color(0.8, 0.3, 0.2, 1.0)
export var pixel_size := 4
export var is_boss := false
export var boss_type := 0  # 0=熔铁监工，1=岩脊吞噬者，2=裂风双刃，3=疫藤祭司，4=镜像执刑官

var flash_timer := 0.0
var is_hit := false
var enraged := false

# 普通敌人像素画 8x12 - 基础战士
var basic_enemy_pixels = [
    "00111100",
    "01111110",
    "01011101",
    "01111111",
    "00111100",
    "01111110",
    "01111110",
    "01111110",
    "01000010",
    "00000000",
]

# 快速型敌人 8x12 - 更细长
var speed_enemy_pixels = [
    "00011000",
    "00111100",
    "01011010",
    "00111100",
    "00011000",
    "00111100",
    "01111110",
    "00111100",
    "00100100",
    "00000000",
]

# 坦克型敌人 10x14 - 更宽大
var tank_enemy_pixels = [
    "0011111100",
    "0111111110",
    "0111111110",
    "0101111010",
    "0111111110",
    "0111111110",
    "0111111110",
    "0111111110",
    "0111111110",
    "0110000110",
    "0100000010",
    "0000000000",
]

# 法师型敌人 8x12 - 带帽子
var mage_enemy_pixels = [
    "00111100",
    "01111110",
    "01111110",
    "00100100",  # 帽檐
    "01011010",
    "00111100",
    "00011000",
    "00111100",
    "01000010",
    "00000000",
]

# Boss 像素画 - 熔铁监工 (16x20)
var boss_molten_pixels = [
    "00001111110000",
    "00011111111000",
    "00111111111100",
    "00110111101100",
    "00111111111100",
    "00111111111100",
    "00011111111000",
    "00011111111000",
    "00111111111100",
    "00111111111100",
    "01111111111110",
    "01111111111110",
    "01110000001110",
    "01100000000110",
    "01000000000010",
    "00000000000000",
]

# Boss - 岩脊吞噬者 (16x22) - 有尖刺
var boss_rock_pixels = [
    "00011000001100",
    "00111100011110",
    "00111111111110",
    "01111111111111",
    "01101111110110",
    "01111111111111",
    "01111111111111",
    "00111111111110",
    "00111111111110",
    "01111111111111",
    "01111111111111",
    "01111111111111",
    "01111111111111",
    "01111001111110",
    "01100000000110",
    "00000000000000",
]

# Boss - 裂风双刃 (14x20) - 有翅膀
var boss_wind_pixels = [
    "01000011000010",
    "01100111100110",
    "01111111111110",
    "00111111111100",
    "00110111101100",
    "00111111111100",
    "00111111111100",
    "00011111111000",
    "00111111111100",
    "00111111111100",
    "00111111111100",
    "00111111111100",
    "00011001111000",
    "00000000000000",
]

# Boss - 疫藤祭司 (14x22) - 有法杖
var boss_priest_pixels = [
    "00011111110000",
    "00111111111000",
    "00111111111000",
    "00110000001000",
    "00111111111000",
    "00111111111000",
    "00111111111000",
    "00011111111000",
    "00111111111100",
    "00111111111100",
    "00111111111100",
    "00011000011000",
    "00000000000000",
]

# Boss - 镜像执刑官 (16x22) - 对称设计
var boss_mirror_pixels = [
    "00011111111100",
    "00111111111110",
    "00111000001110",
    "00111111111110",
    "00111111111110",
    "00111111111110",
    "00111111111110",
    "00011111111100",
    "00111111111110",
    "00111111111110",
    "00111111111110",
    "00111000011110",
    "00000000000000",
]

func get_pixels() -> Array:
    if is_boss:
        match boss_type:
            0: return boss_molten_pixels
            1: return boss_rock_pixels
            2: return boss_wind_pixels
            3: return boss_priest_pixels
            4: return boss_mirror_pixels
            _: return boss_molten_pixels
    else:
        match enemy_type:
            1: return speed_enemy_pixels  # 快速型
            2: return tank_enemy_pixels   # 坦克型
            3: return mage_enemy_pixels   # 法师型
            _: return basic_enemy_pixels  # 普通型

func _process(delta: float) -> void:
    if flash_timer > 0.0:
        flash_timer -= delta
        if flash_timer <= 0.0:
            is_hit = false

func flash_hit() -> void:
    is_hit = true
    flash_timer = 0.12

func set_enraged(state: bool) -> void:
    enraged = state

func _draw() -> void:
    var base_color = color
    if enraged:
        base_color = Color(1.0, 0.2, 0.1, 1.0)
    
    if is_hit:
        base_color = Color(1.0, 0.6, 0.4, 1.0)
    
    var pixels = get_pixels()
    var size = pixel_size * (1.5 if is_boss else 1.0)
    
    # 绘制像素画
    for row in range(pixels.size()):
        for col in range(pixels[row].length()):
            if pixels[row][col] == "1":
                var x = (col - pixels[0].length() / 2.0) * size
                var y = (row - pixels.size() / 2.0) * size
                draw_rect(
                    Rect2(Vector2(x, y), Vector2(size, size)),
                    base_color
                )
    
    # 绘制特殊特征
    _draw_special_features(pixels, size)

func _draw_special_features(pixels: Array, size: float) -> void:
    # Boss 特殊效果
    if is_boss:
        # Boss 光环
        var halo_color = Color(1.0, 0.8, 0.0, 0.3)
        for i in range(-3, 4):
            draw_rect(
                Rect2(Vector2(i * size, -pixels.size() * size / 2 - size), Vector2(size, size)),
                halo_color
            )
    
    # 眼睛颜色根据类型变化
    var eye_color = Color(1, 0.8, 0.2, 1)  # 普通黄色
    if enemy_type == 3:  # 法师型 - 紫色眼睛
        eye_color = Color(0.8, 0.4, 1.0, 1)
    elif enraged:
        eye_color = Color(1.0, 0.0, 0.0, 1)  # 狂暴红色
    
    # 画眼睛
    var eye_y = (-2 if is_boss else -2) * size
    var eye_offset = size * 2
    var eye_size = size * 0.8
    
    # 根据类型决定眼睛位置
    if is_boss:
        eye_offset = size * 3
    elif enemy_type == 1:  # 快速型 - 眼睛更大
        eye_size = size * 1.2
    
    draw_rect(Rect2(Vector2(-eye_offset/2, eye_y - eye_size/2), Vector2(eye_size, eye_size)), eye_color)
    draw_rect(Rect2(Vector2(eye_offset/2, eye_y - eye_size/2), Vector2(eye_size, eye_size)), eye_color)
