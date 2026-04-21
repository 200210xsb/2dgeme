extends Node2D

# 像素风格伤害数字
export var pixel_size := 3
export var rise_speed := 60.0
export var lifetime := 0.6

var damage_value := 0
var is_crit := false
var timer := 0.0

# 像素数字字体 (5x7)
var digit_pixels = {
    "0": ["11110", "10010", "10010", "10010", "10010", "10010", "11110"],
    "1": ["00100", "01100", "00100", "00100", "00100", "00100", "01110"],
    "2": ["11110", "10010", "00010", "00100", "01000", "10000", "11110"],
    "3": ["11110", "10010", "00010", "00110", "00010", "10010", "11110"],
    "4": ["10010", "10010", "10010", "11110", "00010", "00010", "00010"],
    "5": ["11110", "10000", "11110", "00010", "00010", "10010", "11110"],
    "6": ["11110", "10000", "11110", "10010", "10010", "10010", "11110"],
    "7": ["11110", "10010", "00010", "00100", "01000", "01000", "01000"],
    "8": ["11110", "10010", "10010", "11110", "10010", "10010", "11110"],
    "9": ["11110", "10010", "10010", "11110", "00010", "00010", "11110"]
}

func _ready() -> void:
    timer = lifetime

func set_damage(value: int, crit: bool = false) -> void:
    damage_value = value
    is_crit = crit

func _process(delta: float) -> void:
    timer -= delta
    position.y -= rise_speed * delta
    
    if timer <= 0.0:
        queue_free()

func _draw() -> void:
    if damage_value <= 0:
        return
    
    var alpha = min(1.0, timer / (lifetime * 0.3))
    alpha = max(alpha, timer / lifetime)
    
    var color = Color(1.0, 0.2, 0.2, alpha)
    var text = str(damage_value)
    
    if is_crit:
        color = Color(1.0, 0.5, 0.0, alpha)
        # 绘制 CRIT 文字
        _draw_pixel_text("CRIT!", Vector2(0, -10), color, pixel_size * 1.2)
    
    # 绘制数字
    _draw_pixel_text(text, Vector2.ZERO, color, pixel_size * 1.5 if is_crit else pixel_size * 1.2)

func _draw_pixel_text(text: String, pos: Vector2, color: Color, size: float) -> void:
    var char_width = 6
    var start_x = -len(text) * char_width * size / 2
    
    for i in range(text.length()):
        var char = text[i]
        if digit_pixels.has(char):
            var pattern = digit_pixels[char]
            for row in range(pattern.size()):
                for col in range(pattern[row].length()):
                    if pattern[row][col] == "1":
                        var x = start_x + i * char_width * size + col * size
                        var y = pos.y + row * size
                        # 描边
                        for ox in [-1, 0, 1]:
                            for oy in [-1, 0, 1]:
                                if ox != 0 or oy != 0:
                                    draw_rect(
                                        Rect2(Vector2(x + ox, y + oy), Vector2(size, size)),
                                        Color(0, 0, 0, alpha * 0.5)
                                    )
                        draw_rect(
                            Rect2(Vector2(x, y), Vector2(size, size)),
                            color
                        )
