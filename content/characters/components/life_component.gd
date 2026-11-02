class_name LifeComponent
extends CharacterComponent
## LifeComponent, 生命组件（示例模板）
##
## 只负责“生命值/上限”的存储和增减；改完发 [signal CharacterComponent.component_changed]。
## 口上条件里可以用 [code]生命.value[/code] 访问（显示名“生命”）。

@export var value: int = 100
@export var max_value: int = 100


func _init() -> void:
	display_name = "生命"


## 生命是基础类型：子类继承这个身份，仍按 LifeComponent 查找/替换。
func component_type() -> Script:
	return LifeComponent


## 扣血；不会低于 0。
func hurt(amount: int) -> void:
	if amount <= 0:
		return
	value = clampi(value - amount, 0, max_value)
	_mark_changed(&"value")


## 回血；不会超过上限。
func heal(amount: int) -> void:
	if amount <= 0:
		return
	value = clampi(value + amount, 0, max_value)
	_mark_changed(&"value")


func ratio() -> float:
	return float(value) / float(maxi(max_value, 1))
