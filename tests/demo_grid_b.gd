extends Node
## 演示 B 的入口场景：按 F6 直接跑。

func _ready() -> void:
	Era.start(preload("res://tests/_demo_grid_b_event.gd"))
