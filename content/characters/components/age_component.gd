class_name AgeComponent
extends CharacterComponent
## AgeComponent, 年龄组件（可选）
##
## 只有需要成长/年龄概念的角色才安装；没有年龄概念的角色不携带默认年龄。
## value 越过 died_age 时发 [signal died]（从没死跨进死了，只发一次）。

signal died

## 当前年龄。
@export var value: int = 18
## 死亡年龄：_init 里随机一次，保底当前年龄 + 10。
@export var died_age: int = 0
## 死过就不再发（死了就是死了）。
var _dead := false


func _init() -> void:
	display_name = "年龄"
	died_age = maxi(value + 10, randi_range(value, 100))


func component_type() -> Script:
	return AgeComponent


func increase(amount: int) -> void:
	if amount <= 0:
		return
	var previous := value
	value += amount
	_mark_changed(&"value")
	_after_change(previous)


## 直接设定当前年龄（角色创建页写回用）。
## [br][br]
## 设定不触发死亡：目标值不小于 died_age 且未死时，先把 died_age 抬到 v + 1 再落值
## （根因：_init 按默认 18 随机 died_age，而真实年龄要到 new_game 才写入——
## set_value 是“创建年龄”的落点，不该一次性把人写死；增长路径 increase 才判死）。
func set_value(v: int) -> void:
	if not _dead and v >= died_age:
		died_age = v + 1
	var previous := value
	value = v
	_mark_changed(&"value")
	_after_change(previous)


## increase / set_value 共用的越死判定：从“没到”跨进“到了/超过”才发一次 [signal died]。
func _after_change(previous: int) -> void:
	# _dead 保证只发一次。
	if not _dead and previous < died_age and value >= died_age:
		_dead = true
		died.emit()


func decrease(amount: int) -> void:
	if amount <= 0:
		return
	value = maxi(value - amount, 1)
	_mark_changed(&"value")
