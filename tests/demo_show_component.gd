extends Node
## 组件一览演示入口：按 F6 直接跑。

func _ready() -> void:
	Era.start(preload("res://scripts/content/events/show_component.gd"))
