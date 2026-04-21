extends Node2D

# 打击特效系统 - 火花、血迹、冲击波
export var effect_type := 0  # 0=火花，2=血迹，3=冲击波
export var pixel_size := 3

# 统一入口 - 按类型生成特效
func spawn_hit_effect(type: String, position: Vector2, direction: float = 0.0, intensity: float = 1.0) -> void:
    match type:
        "spark":
            spawn_spark(position, Vector2(cos(direction), sin(direction)), intensity)
        "blood":
            spawn_blood(position, Vector2(cos(direction), sin(direction)), 1)
        "impact":
            spawn_shockwave(position, 50, Color(1.0, 0.8, 0.2, 0.6))
        "slash":
            spawn_slash(position, direction, intensity)
        "heavy":
            spawn_heavy_hit(position, Vector2(cos(direction), sin(direction)), intensity > 1.5)
        _:
            spawn_spark(position, Vector2(cos(direction), sin(direction)), intensity)

# 火花特效
func spawn_spark(position: Vector2, direction: Vector2, intensity: float = 1.0) -> void:
    var spark = _create_spark_particle()
    add_child(spark)
    spark.global_position = position
    
    var count = int(8 * intensity)
    for i in range(count):
        var angle = rand_range(-PI/4, PI/4)
        var dir = direction.rotated(angle)
        var speed = rand_range(80, 150) * intensity
        var particle = {
            "pos": position,
            "vel": dir * speed,
            "life": rand_range(0.2, 0.4),
            "max_life": 0.4,
            "size": rand_range(2, 5) * pixel_size * intensity,
            "color": _get_spark_color()
        }
        spark.add_particle(particle)

func _create_spark_particle() -> Node2D:
    return _ParticleEffect.new()

func _get_spark_color() -> Color:
    var colors = [
        Color(1.0, 0.9, 0.5, 1.0),  # 金黄
        Color(1.0, 0.7, 0.3, 1.0),  # 橙色
        Color(1.0, 1.0, 0.8, 1.0),  # 亮黄
        Color(0.9, 0.9, 0.9, 1.0)   # 白色
    ]
    return colors[randi() % colors.size()]

# 血迹特效
func spawn_blood(position: Vector2, direction: Vector2, amount: int = 1) -> void:
    var blood = _create_blood_splatter()
    add_child(blood)
    blood.global_position = position
    
    var count = 12 * amount
    for i in range(count):
        var angle = rand_range(-PI/2, PI/2)
        var dir = direction.rotated(angle)
        var speed = rand_range(60, 120)
        var particle = {
            "pos": position,
            "vel": dir * speed + Vector2(0, -30),  # 向上喷
            "life": rand_range(0.8, 1.5),
            "max_life": 1.5,
            "size": rand_range(3, 8),
            "color": Color(0.8, 0.1, 0.1, 0.9)
        }
        blood.add_particle(particle)

func _create_blood_splatter() -> Node2D:
    return _BloodEffect.new()

# 冲击波特效
func spawn_shockwave(position: Vector2, radius: float, color: Color) -> void:
    var shockwave = _ShockwaveEffect.new()
    shockwave.position = position
    shockwave.radius = radius
    shockwave.color = color
    add_child(shockwave)

# 斩击特效
func spawn_slash(position: Vector2, direction: float, length: float = 40.0) -> void:
    var slash = _SlashEffect.new()
    slash.position = position
    slash.direction = direction
    slash.length = length
    slash.color = Color(1.0, 1.0, 1.0, 0.9)
    add_child(slash)

# 重击特效（组合）
func spawn_heavy_hit(position: Vector2, direction: Vector2, is_crit: bool = false) -> void:
    spawn_spark(position, direction, 1.5)
    spawn_shockwave(position, 40, Color(1, 0.8, 0.2, 0.6))
    if is_crit:
        spawn_shockwave(position, 60, Color(1, 0.5, 0.0, 0.4))

# 粒子效果基类
class _ParticleEffect:
    extends Node2D
    var particles = []
    
    func add_particle(data: Dictionary) -> void:
        particles.append(data)
    
    func _process(delta: float) -> void:
        var all_dead = true
        for p in particles:
            if p["life"] > 0:
                all_dead = false
                p["life"] -= delta
                p["pos"] += p["vel"] * delta
                p["vel"].y += 100 * delta  # 重力
        if all_dead:
            queue_free()
    
    func _draw() -> void:
        for p in particles:
            if p["life"] > 0:
                var alpha = p["life"] / p["max_life"]
                var color = Color(p["color"].r, p["color"].g, p["color"].b, alpha)
                draw_circle(p["pos"], p["size"] * alpha, color)

# 血迹效果
class _BloodEffect:
    extends Node2D
    var particles = []
    var stains = []
    
    func add_particle(data: Dictionary) -> void:
        particles.append(data)
    
    func _process(delta: float) -> void:
        var active_count = 0
        for p in particles:
            if p["life"] > 0:
                active_count += 1
                p["life"] -= delta
                p["pos"] += p["vel"] * delta
                p["vel"].y += 150 * delta  # 重力
                
                # 落地形成血渍
                if p["vel"].y > 0 and p["pos"].y > 20:
                    if randf() < 0.1:
                        stains.append({
                            "pos": p["pos"].duplicate(),
                            "size": p["size"] * rand_range(0.8, 1.5),
                            "color": p["color"]
                        })
        
        if active_count == 0 and particles.size() > 0:
            # 保留血渍一段时间后清理
            yield(get_tree().create_timer(3.0), "timeout")
            queue_free()
    
    func _draw() -> void:
        # 绘制血渍
        for stain in stains:
            draw_circle(stain["pos"], stain["size"], stain["color"])
        
        # 绘制粒子
        for p in particles:
            if p["life"] > 0:
                var alpha = p["life"] / p["max_life"]
                var color = Color(p["color"].r, p["color"].g, p["color"].b, alpha)
                draw_circle(p["pos"], p["size"] * alpha, color)

# 冲击波特效
class _ShockwaveEffect:
    extends Node2D
    var radius := 40.0
    var max_radius := 80.0
    var expand_speed := 200.0
    var color := Color(1, 0.8, 0.2, 0.6)
    
    func _process(delta: float) -> void:
        radius += expand_speed * delta
        if radius > max_radius:
            queue_free()
    
    func _draw() -> void:
        var alpha = 1.0 - (radius / max_radius)
        var c = Color(color.r, color.g, color.b, alpha)
        draw_circle(Vector2.ZERO, radius, c)
        draw_arc(Vector2.ZERO, radius * 0.7, 0, TAU, 32, c, 3 * alpha, true)

# 斩击特效
class _SlashEffect:
    extends Node2D
    var direction := 0.0
    var length := 40.0
    var width := 20.0
    var duration := 0.1
    var timer := 0.1
    var color := Color(1, 1, 1, 0.9)
    
    func _process(delta: float) -> void:
        timer -= delta
        if timer <= 0:
            queue_free()
    
    func _draw() -> void:
        var alpha = timer / duration
        var c = Color(color.r, color.g, color.b, alpha * 0.8)
        
        # 绘制弧形斩击轨迹
        var start_angle = direction - PI / 4
        var end_angle = direction + PI / 4
        draw_arc(Vector2.ZERO, length, start_angle, end_angle, 16, c, 3.0 * alpha, true)
