extends EraScreenPage
## CharacterCreate, 角色创建（名字 + 年龄）
##
## 挂载式页面：普通 [code].tscn[/code]，引擎用 [code]Era.show_screen(scene, data)[/code]
## 在入树前调用 [method configure] 传入初始数据；页面不读取或修改全局状态。
## 完成后通过 [signal EraScreenPage.finished] 把英文键结果交回去。
## [br][br]
## 天赋不在这里选：选天赋是文本流里的 [code]talent_select[/code]（多列格子）。
## 本页也可以自己 F6 单独运行、单独调布局（此时没有输入，只能预览控件）。

@onready var _name_edit: LineEdit = %NameEdit
@onready var _age_value: Label = %AgeValue
@onready var _minus: Button = %Minus
@onready var _plus: Button = %Plus
@onready var _start: Button = %StartButton

var _age := 18
var _configured := false
var _input_name := ""
var _input_age := 18


## 由 [method Era.show_screen] 在入树前调用；验证并保存输入。
func configure(data: Dictionary) -> void:
	_configured = false
	if not data.has("display_name") or not data.has("age"):
		push_warning("CharacterCreate：缺少 display_name 或 age 输入，页面不能完成")
		return
	var name_value: Variant = data["display_name"]
	var age_value: Variant = data["age"]
	if typeof(name_value) != TYPE_STRING:
		push_warning("CharacterCreate：display_name 必须是 String")
		return
	if typeof(age_value) != TYPE_INT or int(age_value) < 1 or int(age_value) > 99:
		push_warning("CharacterCreate：age 必须是 1–99 的整数")
		return
	_input_name = name_value
	_input_age = int(age_value)
	_age = _input_age
	_configured = true
	if is_node_ready():
		_apply_input()


func _ready() -> void:
	_minus.pressed.connect(_change_age.bind(-1))
	_plus.pressed.connect(_change_age.bind(1))
	_start.pressed.connect(_on_start)
	_apply_input()


func _apply_input() -> void:
	if not _configured:
		return
	_name_edit.text = _input_name
	_age = _input_age
	_refresh_age()


func _change_age(delta: int) -> void:
	_age = clampi(_age + delta, 1, 99)
	_refresh_age()


func _refresh_age() -> void:
	_age_value.text = str(_age)


func _on_start() -> void:
	if not _configured:
		push_warning("CharacterCreate：页面还没有 configure 输入，不能完成")
		return
	var display_name := _name_edit.text.strip_edges()
	if display_name.is_empty():
		display_name = "无名"
	finished.emit({"display_name": display_name, "age": _age})
