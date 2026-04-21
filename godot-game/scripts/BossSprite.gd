extends Sprite

# Boss 专用精灵 - 每个 Boss 有独特外观
export var boss_id := 1  # 1-10 对应 10 个章节 Boss
export var color := Color(0.9, 0.1, 0.15, 1.0)
export var pixel_size := 5

var flash_timer := 0.0
var is_hit := false
var enraged := false

# Boss 1: 熔铁监工 (Chapter 1) - 基础型，有角
var boss_1_pixels = [
    "000011110000",
    "000111111000",
    "001101101100",
    "001111111100",
    "001111111100",
    "000111111000",
    "000111111000",
    "001111111100",
    "001111111100",
    "011111111110",
    "011111111110",
    "011100001110",
    "011000000110",
    "000000000000",
]

# Boss 2: 岩脊吞噬者 (Chapter 2) - 有尖刺
var boss_2_pixels = [
    "001100110011",
    "011110110111",
    "011111111111",
    "011111111111",
    "011011111011",
    "011111111111",
    "001111111111",
    "001111111111",
    "011111111111",
    "011111111111",
    "011111111111",
    "011111111111",
    "011100001110",
    "010000000010",
    "000000000000",
]

# Boss 3: 裂风双刃 (Chapter 3) - 有翅膀
var boss_3_pixels = [
    "01000011000010",
    "01100111100110",
    "00111111111100",
    "00110111101100",
    "00111111111100",
    "00111111111100",
    "00011111111000",
    "00111111111100",
    "00111111111100",
    "00111111111100",
    "00111111111100",
    "00011000111000",
    "00000000000000",
]

# Boss 4: 疫藤祭司 (Chapter 4) - 有法冠
var boss_4_pixels = [
    "000011110000",
    "000111111000",
    "000110110000",
    "000111111000",
    "000100001000",
    "001111111100",
    "001111111100",
    "001111111100",
    "001111111100",
    "000111111000",
    "001111111100",
    "001111111100",
    "000110011000",
    "000000000000",
]

# Boss 5: 镜像执刑官 (Chapter 5) - 对称面具
var boss_5_pixels = [
    "000111111100",
    "001111111110",
    "001110011110",
    "001111111110",
    "001111111110",
    "001111111110",
    "001111111110",
    "000111111100",
    "001111111110",
    "001111111110",
    "001111111110",
    "000110001100",
    "000000000000",
]

# Boss 6: 雷核骑士 (Chapter 6) - 雷电盔甲
var boss_6_pixels = [
    "000111111000",
    "001111111100",
    "001101101100",
    "001111111100",
    "001111111100",
    "011111111110",
    "011111111110",
    "011111111110",
    "011111111110",
    "011100001110",
    "011000000110",
    "010000000010",
    "000000000000",
]

# Boss 7: 白霜猎团长 (Chapter 7) - 冰晶装饰
var boss_7_pixels = [
    "010000000010",
    "011000000110",
    "001100001100",
    "001111111100",
    "001101101100",
    "001111111100",
    "001111111100",
    "001111111100",
    "001111111100",
    "001111111100",
    "000110011000",
    "000000000000",
]

# Boss 8: 幕影指挥家 (Chapter 8) - 礼帽和披风
var boss_8_pixels = [
    "000111111000",
    "000111111000",
    "000100001000",
    "001111111100",
    "001111111100",
    "001111111100",
    "001111111100",
    "001111111100",
    "001111111100",
    "011110011110",
    "011100001110",
    "000000000000",
]

# Boss 9: 天陨守门者 (Chapter 9) - 巨大头盔
var boss_9_pixels = [
    "000111111100",
    "001111111110",
    "001110000110",
    "001111111110",
    "001111111110",
    "001111111110",
    "001111111110",
    "001111111110",
    "001111111110",
    "001110001110",
    "000000000000",
]

# Boss 10: 终焉领主 (Chapter 10) - 最终 Boss，王冠
var boss_10_pixels = [
    "010010010010",
    "011010010110",
    "001110011100",
    "000111111000",
    "000111111000",
    "001101101100",
    "001111111100",
    "011111111110",
    "011111111110",
    "011111111110",
    "011111111110",
    "011100001110",
    "010000000010",
    "000000000000",
]

func get_boss_pixels() -> Array:
    match boss_id:
        1: return boss_1_pixels
        2: return boss_2_pixels
        3: return boss_3_pixels
        4: return boss_4_pixels
        5: return boss_5_pixels
        6: return boss_6_pixels
        7: return boss_7_pixels
        8: return boss_8_pixels
        9: return boss_9_pixels
        10: return boss_10_pixels
        _: return boss_1_pixels

func _process(delta: float) -> void:
    if flash_timer > 0.0:
        flash_timer -= delta
        if flash_timer <= 0.0:
            is_hit = false

func flash_hit() -> void:
    is_hit = true
    flash_timer = 0.15

func set_enraged(state: bool) -> void:
    enraged = state

func _draw() -> void:
    var base_color = color
    if enraged:
        base_color = Color(1.0, 0.2, 0.1, 1.0)
    
    if is_hit:
        base_color = Color(1.0, 0.6, 0.4, 1.0)
    
    var pixels = get_boss_pixels()
    var size = pixel_size * 1.5
    
    # 绘制 Boss 主体
    for row in range(pixels.size()):
        for col in range(pixels[row].length()):
            if pixels[row][col] == "1":
                var x = (col - pixels[0].length() / 2.0) * size
                var y = (row - pixels.size() / 2.0) * size
                draw_rect(
                    Rect2(Vector2(x, y), Vector2(size, size)),
                    base_color
                )
    
    # 绘制 Boss 特有特征
    _draw_boss_features(pixels, size)

func _draw_boss_features(pixels: Array, size: float) -> void:
    # Boss 光环/装饰效果
    var halo_color = Color(1.0, 0.8, 0.0, 0.3)
    
    # 根据 Boss ID 绘制不同特征
    match boss_id:
        1: # 熔铁监工 - 熔岩纹
            _draw_lava_patterns(size)
        2: # 岩脊吞噬者 - 尖刺
            _draw_spikes(size)
        3: # 裂风双刃 - 风刃
            _draw_wind_blades(size)
        4: # 疫藤祭司 - 藤蔓
            _draw_vines(size)
        5: # 镜像执刑官 - 镜像碎片
            _draw_mirror_fragments(size)
        6: # 雷核骑士 - 雷电
            _draw_lightning(size)
        7: # 白霜猎团长 - 冰晶
            _draw_ice_crystals(size)
        8: # 幕影指挥家 - 音符
            _draw_music_notes(size)
        9: # 天陨守门者 - 陨石
            _draw_meteors(size)
        10: # 终焉领主 - 王冠光芒
            _draw_crown_aura(size)
    
    # 狂暴光环
    if enraged:
        var rage_color = Color(1.0, 0.0, 0.0, 0.2)
        for i in range(-4, 5):
            for j in range(-4, 5):
                if abs(i) + abs(j) > 3:
                    draw_rect(
                        Rect2(Vector2(i * size, j * size - pixels.size() * size/2), Vector2(size, size)),
                        rage_color
                    )

func _draw_lava_patterns(size: float) -> void:
    var lava_color = Color(1.0, 0.4, 0.0, 0.6)
    for i in range(-3, 4):
        var y = (i % 3) * size
        draw_rect(Rect2(Vector2(i * size, y), Vector2(size, size)), lava_color)

func _draw_spikes(size: float) -> void:
    var spike_color = Color(0.7, 0.5, 0.3, 0.8)
    for i in range(-4, 5, 2):
        draw_rect(Rect2(Vector2(i * size, -5 * size), Vector2(size, size * 2)), spike_color)

func _draw_wind_blades(size: float) -> void:
    var wind_color = Color(0.6, 0.8, 1.0, 0.5)
    for i in range(-5, 6):
        var offset = sin(i * 0.5) * size * 2
        draw_rect(Rect2(Vector2(i * size + offset, -4 * size), Vector2(size, size)), wind_color)

func _draw_vines(size: float) -> void:
    var vine_color = Color(0.2, 0.6, 0.2, 0.7)
    for i in range(-3, 4):
        draw_rect(Rect2(Vector2(i * size, (i % 4) * size), Vector2(size, size)), vine_color)

func _draw_mirror_fragments(size: float) -> void:
    var mirror_color = Color(0.8, 0.9, 1.0, 0.4)
    for i in range(-4, 5):
        if i % 2 == 0:
            draw_rect(Rect2(Vector2(i * size, 0), Vector2(size, size)), mirror_color)

func _draw_lightning(size: float) -> void:
    var lightning_color = Color(1.0, 1.0, 0.2, 0.6)
    for i in range(-3, 4, 2):
        draw_rect(Rect2(Vector2(i * size, -i * size), Vector2(size, size * 2)), lightning_color)

func _draw_ice_crystals(size: float) -> void:
    var ice_color = Color(0.5, 0.8, 1.0, 0.6)
    for i in range(-4, 5):
        draw_rect(Rect2(Vector2(i * size, -6 * size), Vector2(size, size * 3)), ice_color)

func _draw_music_notes(size: float) -> void:
    var note_color = Color(0.9, 0.7, 0.2, 0.5)
    for i in range(-3, 4):
        draw_circle(Vector2(i * size, -5 * size), size * 0.6, note_color)

func _draw_meteors(size: float) -> void:
    var meteor_color = Color(0.8, 0.4, 0.0, 0.5)
    for i in range(-4, 5):
        draw_rect(Rect2(Vector2(i * size, -7 * size), Vector2(size * 1.5, size)), meteor_color)

func _draw_crown_aura(size: float) -> void:
    var crown_color = Color(1.0, 0.9, 0.2, 0.4)
    for i in range(-5, 6):
        draw_rect(Rect2(Vector2(i * size, -7 * size + abs(i) * size * 0.5), Vector2(size, size)), crown_color)
