class_name FlagTableComponent
extends CharacterComponent
## FlagTableComponent, 角色标记表（可选组件）
##
## 角色侧的整数标记容器（对标 Emuera 的角色变量口径）：CSV 导入的
## [code]flag[/code] 行、事件里的开关/计数类数据都存在这里。
## 只存整数；值实际变化时发 [signal CharacterComponent.component_changed]
## （[param what] 为 [code]&"values"[/code]）。

## 标记表：键为英文标记 id，值为整数。
@export var values: Dictionary[StringName, int] = {}


func _init() -> void:
	display_name = "标记"


## 设置标记；值实际变化时才发 [code]component_changed(&"values")[/code]。
## [codeblock]
## 标记.set_flag(&"trust", 10)
## [/codeblock]
func set_flag(flag: StringName, value: int) -> void:
	var old := int(values.get(flag, 0))
	if old == value:
		return
	values[flag] = value
	_mark_changed(&"values")


## 读标记；未设置时返回 [param default]。
## [codeblock]
## 标记.get_flag(&"trust")      # 未设过 → 0
## 标记.get_flag(&"trust", 5)   # 未设过 → 5
## [/codeblock]
func get_flag(flag: StringName, default: int = 0) -> int:
	return int(values.get(flag, default))


## 增减标记并返回新值。
## [codeblock]
## 标记.add_flag(&"trust", 5)   # trust +5，返回加完后的值
## [/codeblock]
func add_flag(flag: StringName, delta: int) -> int:
	set_flag(flag, get_flag(flag) + delta)
	return get_flag(flag)
