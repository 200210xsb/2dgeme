extends Area2D

export var score_value := 10
var life_time := 10.0
var pulse := 0.0

signal collected(value)

func _ready() -> void:
    var shape = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 10.0
    shape.shape = circle
    add_child(shape)

    monitoring = true
    set_process(true)
    connect("body_entered", self, "_on_body_entered")

func _process(delta: float) -> void:
    pulse += delta * 6.0
    life_time -= delta
    update()
    if life_time <= 0.0:
        queue_free()

func _draw() -> void:
    var radius = 8.0 + sin(pulse) * 1.2
    draw_circle(Vector2.ZERO, radius, Color(1.0, 0.85, 0.25, 1.0))

func _on_body_entered(body: Node) -> void:
    if body.name != "Player":
        return

    emit_signal("collected", score_value)
    queue_free()
