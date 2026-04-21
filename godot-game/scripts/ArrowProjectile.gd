extends Node2D

# 弓箭投射物
export var damage := 2
export var speed := 450.0
export var gravity := 400.0
export var max_distance := 500.0
export var pixel_size := 3

var velocity := Vector2.RIGHT
var distance_traveled := 0.0
var start_position := Vector2.ZERO

var hit_enemy = null

signal hit_target(enemy)

func _ready() -> void:
    start_position = global_position

func _physics_process(delta: float) -> void:
    # 应用重力
    velocity.y += gravity * delta
    
    # 移动
    var movement = velocity * delta
    global_position += movement
    distance_traveled += movement.length()
    
    # 检测碰撞
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()
    query.set_shape(RectangleShape2D.new())
    query.shape.extents = Vector2(10, 3)
    query.transform = global_transform
    query.exclude = [self]
    
    var result = space_state.intersect_shape(query, 1)
    if not result.empty():
        var collider = result[0].collider
        _on_hit(collider)
        return
    
    # 超出距离或出屏幕
    if distance_traveled > max_distance or global_position.y > 700 or global_position.x > 1200 or global_position.x < 0:
        queue_free()

func _on_hit(collider: Node) -> void:
    if collider.has_method("take_damage") and collider != get_parent().get_parent():
        var source = get_parent().get_parent() if get_parent().get_parent() else self
        var source_pos = source.global_position if source else global_position
        
        collider.take_damage(damage, source_pos, 150.0)
        emit_signal("hit_target", collider)
        
        # 命中特效
        var game = get_tree().current_scene
        if game != null:
            var hit_effects = game.get_node_or_null("HitEffects")
            if hit_effects != null:
                hit_effects.spawn_hit_effect("spark", global_position, atan2(velocity.y, velocity.x))
            
            var hit_stop = game.get_node_or_null("HitStopManager")
            if hit_stop != null:
                hit_stop.trigger_hit_stop(0.05)
    
    queue_free()

func set_direction(dir: Vector2) -> void:
    velocity = dir.normalized() * speed

func _draw() -> void:
    # 绘制箭矢
    var arrow_color = Color(0.7, 0.6, 0.5, 1.0)
    var tip_color = Color(0.3, 0.3, 0.3, 1.0)
    
    var angle = atan2(velocity.y, velocity.x)
    rotate(angle)
    
    # 箭杆
    draw_line(Vector2(-15, 0), Vector2(15, 0), arrow_color, 2.0 * pixel_size)
    
    # 箭头
    var tip_points = PoolVector2Array([
        Vector2(15, 0),
        Vector2(5, -5),
        Vector2(5, 5)
    ])
    draw_colored_polygon(tip_points, tip_color)
    
    # 箭羽
    draw_line(Vector2(-15, 0), Vector2(-20, -4), Color(0.8, 0.2, 0.2, 0.8), 2.0)
    draw_line(Vector2(-15, 0), Vector2(-20, 4), Color(0.8, 0.2, 0.2, 0.8), 2.0)
    
    rotate(-angle)
