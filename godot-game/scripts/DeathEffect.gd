extends Node2D

# 像素风格死亡爆炸效果
export var particle_count := 16
export var spread := 100.0
export var min_speed := 60.0
export var max_speed := 140.0
export var lifetime := 0.6
export var color := Color(0.8, 0.3, 0.2, 0.9)
export var pixel_size := 5

var particles = []

func _ready() -> void:
    _spawn_particles()

func _spawn_particles() -> void:
    for i in range(particle_count):
        var angle = rand_range(-PI, PI)
        var speed = rand_range(min_speed, max_speed)
        var velocity = Vector2(cos(angle), sin(angle)) * speed
        var size = rand_range(pixel_size, pixel_size * 2)
        var shape = randi() % 3  # 0=方形，1=长方形，2=小点
        particles.append({
            "pos": Vector2.ZERO,
            "vel": velocity,
            "size": size,
            "life": lifetime,
            "max_life": lifetime,
            "shape": shape
        })

func _process(delta: float) -> void:
    var all_dead = true
    for p in particles:
        if p.life > 0:
            all_dead = false
            p.life -= delta
            p.pos += p.vel * delta
            p.vel.y += 150 * delta  # 重力
    
    if all_dead:
        queue_free()

func _draw() -> void:
    for p in particles:
        if p.life > 0:
            var alpha = p.life / p.max_life
            var c = Color(color.r, color.g, color.b, alpha)
            
            if p.shape == 0:  # 方形像素
                draw_rect(Rect2(p.pos - Vector2(p.size/2, p.size/2), Vector2(p.size, p.size)), c)
            elif p.shape == 1:  # 长方形像素
                draw_rect(Rect2(p.pos - Vector2(p.size/2, p.size/4), Vector2(p.size, p.size/2)), c)
            else:  # 小点
                draw_rect(Rect2(p.pos - Vector2(p.size/4, p.size/4), Vector2(p.size/2, p.size/2)), c)
