extends Node2D

# 地形陷阱系统 - 尖刺/落石/岩浆等
export var trap_type := 0  # 0=尖刺，1=落石，2=岩浆，3=移动平台
export var damage := 1
export var active := true
export var damage_interval := 0.5  # 秒

var trap_timer := 0.0
var affected_entities = []

signal trap_triggered(entity, damage)

func _ready() -> void:
    if trap_type == 1:  # 落石需要下落动画
        visible = false

func _process(delta: float) -> void:
    if not active:
        return
    
    trap_timer += delta
    
    # 检测接触
    if trap_timer >= damage_interval:
        trap_timer = 0
        _trigger_trap()

func _trigger_trap() -> void:
    for entity in affected_entities:
        if entity and entity.has_method("take_damage"):
            entity.take_damage(damage, global_position, 100)
            emit_signal("trap_triggered", entity, damage)

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("combatant"):
        affected_entities.append(body)
        if trap_type == 1:  # 落石立即触发
            _trigger_trap()

func _on_body_exited(body: Node) -> void:
    if body in affected_entities:
        affected_entities.erase(body)

func activate_trap() -> void:
    active = true
    if trap_type == 1:
        # 落石从上方落下
        position.y = -200
        var tween = create_tween()
        tween.tween_property(self, "position:y", global_position.y, 0.8)
        tween.tween_callback(func(): active = true)

func deactivate_trap() -> void:
    active = false

func _draw() -> void:
    if not active and trap_type != 1:
        return
    
    match trap_type:
        0: _draw_spikes()
        1: _draw_falling_rock()
        2: _draw_lava()
        3: _draw_moving_platform()

func _draw_spikes() -> void:
    var spike_color = Color(0.6, 0.6, 0.6, 1.0)
    var spike_count = 5
    var spike_width = 40
    var spike_height = 30
    
    for i in range(spike_count):
        var x = i * spike_width - spike_count * spike_width / 2
        var points = PoolVector2Array([
            Vector2(x, 0),
            Vector2(x + spike_width/2, -spike_height),
            Vector2(x + spike_width, 0)
        ])
        draw_colored_polygon(points, spike_color)
        
        # 高光
        var highlight = PoolVector2Array([
            Vector2(x + spike_width/4, -spike_height/2),
            Vector2(x + spike_width/2, -spike_height),
            Vector2(x + spike_width/2, 0)
        ])
        draw_colored_polygon(highlight, Color(0.8, 0.8, 0.8, 0.5))

func _draw_falling_rock() -> void:
    var rock_color = Color(0.5, 0.4, 0.3, 1.0)
    draw_circle(Vector2.ZERO, 40, rock_color)
    
    # 岩石纹理
    for i in range(5):
        var offset = Vector2(rand_range(-20, 20), rand_range(-20, 20))
        draw_circle(offset, 8, Color(0.4, 0.3, 0.2, 0.8))

func _draw_lava() -> void:
    var lava_color = Color(1.0, 0.3, 0.0, 0.9)
    var width = get_viewport_rect().size.x
    
    # 岩浆表面
    var points = PoolVector2Array()
    var amplitude = 5
    var frequency = 0.1
    for x in range(-50, int(width) + 50, 20):
        var y = sin(x * frequency + Time.get_ticks_msec() / 200.0) * amplitude
        points.append(Vector2(x, y))
    
    for i in range(points.size() - 1):
        draw_line(points[i], points[i+1], lava_color, 15)
    
    # 气泡
    var time = Time.get_ticks_msec() / 1000.0
    for i in range(20):
        var bx = (i * 73 + int(time * 100)) % int(width) - width/2
        var by = sin(time + i) * 10
        draw_circle(Vector2(bx, by - 5), 4, Color(1.0, 0.5, 0.0, 0.6))

func _draw_moving_platform() -> void:
    var platform_color = Color(0.4, 0.35, 0.3, 1.0)
    var width = 120
    var height = 20
    
    # 平台主体
    draw_rect(Rect2(-width/2, -height/2, width, height), platform_color)
    
    # 金属边框
    draw_rect(Rect2(-width/2, -height/2, width, 4), Color(0.6, 0.55, 0.5, 1.0))
    draw_rect(Rect2(-width/2, height/2 - 4, width, 4), Color(0.3, 0.25, 0.2, 1.0))
    
    # 纹理
    for i in range(int(width / 15)):
        var x = -width/2 + i * 15 + 5
        draw_line(Vector2(x, -height/2 + 2), Vector2(x, height/2 - 2), Color(0.5, 0.45, 0.4, 0.5), 2)
