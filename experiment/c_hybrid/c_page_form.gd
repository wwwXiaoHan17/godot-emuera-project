extends Control
## 实验 C 的特殊页面：角色创建。
##
## 它是一块普通的 .tscn，可以被引擎插进壳里，也可以自己 F6 单独跑。
## 做完时发 finished(result)，引擎把数据拿回去。

signal finished(result: Dictionary)

@onready var _name_edit: LineEdit = %NameEdit
@onready var _age_value: Label = %AgeValue
@onready var _minus: Button = %Minus
@onready var _plus: Button = %Plus
@onready var _talent_a: CheckBox = %TalentA
@onready var _talent_b: CheckBox = %TalentB
@onready var _start: Button = %StartButton

var _age := 18


func _ready() -> void:
	_minus.pressed.connect(_change_age.bind(-1))
	_plus.pressed.connect(_change_age.bind(1))
	_start.pressed.connect(_on_start)
	_refresh()


func _change_age(delta: int) -> void:
	_age = clampi(_age + delta, 1, 99)
	_refresh()


func _refresh() -> void:
	_age_value.text = str(_age)


func _on_start() -> void:
	var name_text := _name_edit.text.strip_edges()
	if name_text.is_empty():
		name_text = "无名"
	var talents: Array[String] = []
	if _talent_a.button_pressed:
		talents.append("childish")
	if _talent_b.button_pressed:
		talents.append("precocious")
	var data := {
		"display_name": name_text,
		"age": _age,
		"talents": talents,
	}
	print("[表单页] 交出数据：", data)
	finished.emit(data)
