extends Node2D

# 像素风格背景
export var sky_color_top := Color(0.1, 0.12, 0.18, 1.0)
export var sky_color_bottom := Color(0.15, 0.18, 0.28, 1.0)
export var pixel_size := 8

var scroll_offset := 0.0

func _process(delta: float) -> void:
    scroll_offset += 5 * delta

func _draw() -> void:
    var viewport_size = get_viewport_rect().size
    
    # 绘制像素化天空渐变
    var rows = int(viewport_size.y / pixel_size)
    for row in range(rows):
        var t = float(row) / float(rows)
        var color = sky_color_top.linear_interpolate(sky_color_bottom, t)
        var y = row * pixel_size
        draw_rect(
            Rect2(0, y, viewport_size.x, pixel_size + 1),
            color
        )
    
    # 绘制远处像素山
    _draw_pixel_mountains(viewport_size)
    
    # 绘制像素地面
    _draw_pixel_ground(viewport_size)

func _draw_pixel_mountains(viewport_size: Vector2) -> void:
    var mountain_color = Color(0.08, 0.1, 0.15, 1.0)
    var block_size = pixel_size * 3
    
    # 第一层山
    for x in range(0, int(viewport_size.x / block_size) + 2):
        var height = int(rand_range(3, 8))
        var offset = sin(x * 137.0 + scroll_offset * 0.1) * 2
        for y in range(height):
            var draw_x = x * block_size - int(scroll_offset * 0.3) % block_size
            var draw_y = viewport_size.y - 100 - (y + int(offset)) * block_size
            if draw_y < viewport_size.y - 150:
                draw_rect(
                    Rect2(Vector2(draw_x, draw_y), Vector2(block_size, block_size)),
                    mountain_color
                )

func _draw_pixel_ground(viewport_size: Vector2) -> void:
    var ground_color = Color(0.12, 0.14, 0.18, 1.0)
    var block_size = pixel_size * 2
    
    # 地面
    var ground_y = viewport_size.y - 100
    draw_rect(Rect2(0, ground_y, viewport_size.x, 100), ground_color)
    
    # 地面纹理
    var texture_color = Color(0.15, 0.17, 0.21, 1.0)
    for x in range(0, int(viewport_size.x / block_size) + 1):
        var draw_x = x * block_size - int(scroll_offset) % block_size
        for y in range(3):
            var draw_y = ground_y + y * block_size + 10
            if randf() > 0.3:
                draw_rect(
                    Rect2(Vector2(draw_x, draw_y), Vector2(block_size - 1, block_size - 1)),
                    texture_color
                )
