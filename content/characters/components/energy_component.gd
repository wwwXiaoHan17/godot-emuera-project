class_name EnergyComponent
extends CharacterComponent
## EnergyComponent, 精力组件（示例模板）
##
## 精力值/上限 + 消耗/恢复；和逻辑脚本一样，改完发 component_changed。

@export var value: int = 100 ## 当前的精力值
@export var max_value: int = 100 ## 精力组件的最大值


func _init() -> void:
	display_name = "精力"


func spend(amount: int) -> void:
	if amount <= 0:
		return
	self.value = clampi(value - amount, 0, max_value)
	_mark_changed(&"value")


func rest(amount: int) -> void:
	if amount <= 0:
		return
	value = clampi(value + amount, 0, max_value)
	_mark_changed(&"value")
