extends Camera2D

export var trauma_decay := 1.8
export var max_offset := Vector2(18, 10)

var trauma := 0.0

func _process(delta: float) -> void:
    trauma = max(0.0, trauma - trauma_decay * delta)
    if trauma <= 0.0:
        offset = Vector2.ZERO
        return

    var amt = trauma * trauma
    offset.x = rand_range(-max_offset.x, max_offset.x) * amt
    offset.y = rand_range(-max_offset.y, max_offset.y) * amt

func add_trauma(amount: float) -> void:
    trauma = clamp(trauma + amount, 0.0, 1.0)
