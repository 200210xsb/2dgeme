extends Node2D

# 程序化生成像素风格游戏图标（16x16 像素）
# 保存为 PNG 用于 exe 图标

const ICON_SIZE = 64  # 图标尺寸（导出为 64x64）
const PIXEL_SIZE = 4  # 每个"像素"的大小

# 16x16 像素图案 (1=true/彩色，0=透明)
# 像素战士头部设计
var pixel_pattern = [
    "0000011111000000",
    "0000111111100000",
    "0001111111110000",
    "0001101111011000",
    "0001111111110000",
    "0000111111100000",
    "0000011001100000",
    "0000111111110000",
    "0001111111111000",
    "0011100110011100",
    "0011111111111100",
    "0011111111111100",
    "0001111111111000",
    "0000111111110000",
    "0000011111100000",
    "0000001111000000",
]

var pixel_colors = [
    Color(0.2, 0.5, 0.9, 1.0),  # 主色 - 蓝色战士
    Color(0.3, 0.6, 1.0, 1.0),  # 亮色
    Color(0.1, 0.4, 0.8, 1.0),  # 暗色
    Color(1.0, 0.8, 0.2, 1.0),  # 眼睛 - 黄色
]

func _ready():
    # 等待一帧后保存
    yield(get_tree(), "idle_frame")
    _save_icon()

func _save_icon():
    var img = Image.new()
    img.create(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))  # 透明背景
    
    # 绘制像素图案
    for row in range(pixel_pattern.size()):
        for col in range(pixel_pattern[row].length()):
            if pixel_pattern[row][col] == "1":
                # 计算颜色（添加渐变效果）
                var center_x = 7.5
                var center_y = 7.5
                var dist = sqrt(pow(row - center_y, 2) + pow(col - center_x, 2))
                
                var color = pixel_colors[0]
                if dist < 3:
                    color = pixel_colors[1]  # 中心亮
                elif dist > 6:
                    color = pixel_colors[2]  # 边缘暗
                
                # 绘制像素块
                var x_start = int((float(col) / 16.0) * ICON_SIZE)
                var y_start = int((float(row) / 16.0) * ICON_SIZE)
                var size = int(ICON_SIZE / 16.0)
                
                for px in range(size):
                    for py in range(size):
                        img.set_pixel(x_start + px, y_start + py, color)
    
    # 添加眼睛
    var eye_y = int(7.0 / 16.0 * ICON_SIZE)
    var eye_left_x = int(5.0 / 16.0 * ICON_SIZE)
    var eye_right_x = int(10.0 / 16.0 * ICON_SIZE)
    var eye_size = int(ICON_SIZE / 16.0)
    
    for ex in [eye_left_x, eye_right_x]:
        for px in range(eye_size):
            for py in range(eye_size):
                img.set_pixel(ex + px, eye_y + py, pixel_colors[3])
    
    # 保存为 PNG
    img.save_png("res://icon.png")
    
    # 也保存为 ico 需要的大小（256x256, 64x64, 32x32, 16x16）
    _save_icon_size(img, 256, "res://icon_256.png")
    _save_icon_size(img, 64, "res://icon_64.png")
    _save_icon_size(img, 32, "res://icon_32.png")
    _save_icon_size(img, 16, "res://icon_16.png")
    
    print("图标已保存到项目根目录")
    get_tree().quit()

func _save_icon_size(source: Image, size: int, path: String):
    var img = Image.new()
    img.create(size, size, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    
    # 缩放绘制
    var scale = float(size) / float(ICON_SIZE)
    for y in range(size):
        for x in range(size):
            var src_x = int(float(x) / scale)
            var src_y = int(float(y) / scale)
            if src_x >= 0 and src_x < ICON_SIZE and src_y >= 0 and src_y < ICON_SIZE:
                img.set_pixel(x, y, source.get_pixel(src_x, src_y))
    
    img.save_png(path)
