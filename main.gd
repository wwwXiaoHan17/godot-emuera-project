extends Node
## 项目入口：只负责启动第一个事件。

func _ready() -> void:
	Era.start(preload("res://scripts/content/events/type_system_title.gd"))
