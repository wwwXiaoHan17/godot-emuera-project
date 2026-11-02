extends Node
## 多角色关系矩阵演示入口：按 F6 直接跑。

func _ready() -> void:
	Era.start(preload("res://tests/_demo_relations_event.gd"))
