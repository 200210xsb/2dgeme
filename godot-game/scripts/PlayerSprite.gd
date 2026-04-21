extends Sprite

# 像素风格玩家精灵
export var color := Color(0.2, 0.6, 1.0, 1.0)
export var pixel_size := 4  # 每个像素的大小

var flash_timer := 0.0
var is_hit := false
var face_dir := 1

# 像素画数据 (1 = 填充，0 = 透明)
# 9x14 像素角色
var sprite_pixels = [
    "000011000",  # 头顶
    "000011000",
    "000111100",  # 头发
    "001111110",
    "011011011",  # 脸
    "011111111",
    "011111111",
    "001111110",  # 身体
    "001111110",
    "011111111",
    "011111111",  # 腿
    "011000011",
    "010000001",
    "000000000"
]

func _process(delta: float) -> void:
    if flash_timer > 0.0:
        flash_timer -= delta
        if flash_timer <= 0.0:
            is_hit = false
    
    # 获取面向方向
    var parent = get_parent()
    if parent and parent.has_method('_get_face_dir'):
        face_dir = parent._get_face_dir()
        scale.x = abs(scale.x) * face_dir

func flash_hit() -> void:
    is_hit = true
    flash_timer = 0.15

func _draw() -> void:
    var draw_color = color
    if is_hit:
        draw_color = Color(1.0, 0.5, 0.5, 1.0)
    
    # 绘制像素画
    for row in range(sprite_pixels.size()):
        for col in range(sprite_pixels[row].length()):
            if sprite_pixels[row][col] == "1":
                var x = (col - 4.5) * pixel_size
                var y = (row - 7) * pixel_size
                draw_rect(
                    Rect2(Vector2(x, y), Vector2(pixel_size, pixel_size)),
                    draw_color
                )
    
    # 画眼睛（白色像素）
    var eye_y = -3 * pixel_size
    var eye_x = (1 if face_dir == 1 else -1) * 2 * pixel_size
    draw_rect(Rect2(Vector2(eye_x - pixel_size/2, eye_y - pixel_size/2), Vector2(pixel_size, pixel_size)), Color(1, 1, 1, 1))
