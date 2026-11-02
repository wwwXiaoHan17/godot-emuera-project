extends Node
## 项目入口：只负责启动第一个事件。

func _ready() -> void:
	Era.start(preload("res://content/events/type_a_title.gd"))
