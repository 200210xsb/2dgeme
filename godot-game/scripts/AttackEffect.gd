extends Node2D

# 像素风格攻击特效 - 支持不同武器
export var effect_color := Color(1.0, 0.8, 0.2, 0.9)
export var pixel_size := 3
export var duration := 0.15
export var weapon_type := "sword"  # sword/spear/hammer/dagger/axe/bow

var timer := 0.0
var active := false
var face_dir := 1

# 武器特效配置
var weapon_configs = {
    "sword": {"color": Color(1.0, 0.8, 0.2, 0.9), "size": 3, "duration": 0.15},
    "spear": {"color": Color(0.6, 0.8, 1.0, 0.9), "size": 4, "duration": 0.18},
    "hammer": {"color": Color(0.8, 0.6, 0.4, 0.9), "size": 5, "duration": 0.2},
    "dagger": {"color": Color(0.9, 0.9, 0.9, 0.9), "size": 2, "duration": 0.1},
    "axe": {"color": Color(1.0, 0.4, 0.2, 0.9), "size": 5, "duration": 0.22},
    "bow": {"color": Color(0.8, 1.0, 0.6, 0.9), "size": 2, "duration": 0.12}
}

# 像素刀刃形状
var blade_pixels = [
    "0000000000",
    "0000110000",
    "0001111000",
    "0011111100",
    "0111111110",
    "0011111100",
    "0001111000",
    "0000110000",
]

func _process(delta: float) -> void:
    if active:
        timer -= delta
        if timer <= 0.0:
            active = false
            visible = false

func play(position: Vector2, dir: int, w_type: String = "sword") -> void:
    global_position = position
    face_dir = dir
    weapon_type = w_type
    
    # 应用武器配置
    var config = weapon_configs.get(weapon_type, weapon_configs["sword"])
    effect_color = config["color"]
    pixel_size = config["size"]
    duration = config["duration"]
    
    timer = duration
    active = true
    visible = true

func _draw() -> void:
    if not active:
        return
    
    var progress = timer / duration
    var alpha = progress
    
    for row in range(blade_pixels.size()):
        for col in range(blade_pixels[row].length()):
            if blade_pixels[row][col] == "1":
                var x = (col - 5) * pixel_size * face_dir
                var y = (row - 4) * pixel_size
                var color = Color(effect_color.r, effect_color.g, effect_color.b, alpha)
                draw_rect(
                    Rect2(Vector2(x, y), Vector2(pixel_size, pixel_size)),
                    color
                )
    
    # 像素闪光
    if progress > 0.5:
        var flash_x = 2 * pixel_size * face_dir
        for i in range(3):
            var flash_y = (i - 1) * pixel_size
            draw_rect(
                Rect2(Vector2(flash_x, flash_y), Vector2(pixel_size, pixel_size)),
                Color(1, 1, 1, alpha * 0.8)
            )
