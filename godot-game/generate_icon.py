from PIL import Image, ImageDraw

img = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

pixel_size = 16
offset = 32

main_color = (51, 128, 230, 255)
bright_color = (77, 153, 255, 255)
dark_color = (26, 102, 204, 255)
eye_color = (255, 204, 51, 255)

pattern = [
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

for row in range(16):
    for col in range(16):
        if pattern[row][col] == "1":
            cx, cy = 7.5, 7.5
            dist = (((row - cy)**2) + ((col - cx)**2))**0.5
            if dist < 3:
                color = bright_color
            elif dist > 6:
                color = dark_color
            else:
                color = main_color
            x1, y1 = offset + col * pixel_size, offset + row * pixel_size
            draw.rectangle([x1, y1, x1 + pixel_size, y1 + pixel_size], fill=color)

eye_y = offset + 7 * pixel_size
for ex in [offset + 5 * pixel_size, offset + 10 * pixel_size]:
    draw.rectangle([ex, eye_y, ex + pixel_size, eye_y + pixel_size], fill=eye_color)

img.save('/workspace/godot-game/icon.png')
for size in [256, 128, 64, 48, 32, 16]:
    img.resize((size, size), Image.Resampling.LANCZOS).save(f'/workspace/godot-game/icon_{size}.png')

print("图标已生成!")
