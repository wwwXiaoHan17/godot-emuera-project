extends Node
## 混合格子演示的入口场景：按 F6 直接跑。

func _ready() -> void:
	Era.start(preload("res://tests/_demo_mixed_grid_event.gd"))
