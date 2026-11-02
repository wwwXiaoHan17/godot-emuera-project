extends Node
## 角色系统演示入口：按 F6 直接跑。

func _ready() -> void:
	Era.start(preload("res://tests/_demo_character_event.gd"))
