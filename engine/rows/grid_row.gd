extends GridContainer
## GridRow, 常驻多列选项块
##
## 选择项（toggle）：点击只切换自己，不打断内容流程。
## [br][br]
## 选中＝青色、未选＝白色、禁用＝灰色（灰色点击无效）。
## [br][br]
## 动作项（action）：点击后交给引擎，让 [code]await Era.input()[/code] 返回编号。
## [br][br]
## 整块只构建一次；之后切换/禁用只改颜色和状态，不重建节点。
## 内容通过 [method Era.end_grid] 拿到本节点当句柄使用。

## 动作项被点击，按钮的编号交给引擎处理。
signal picked(id: int)

## 选择项被点击；内容可以接这个信号处理互斥、上限等业务规则。
signal toggled(id: int, selected: bool)

const FontGuard := preload("res://engine/font_guard.gd")

var _palette: EraPalette
var _buttons: Dictionary = {}   # id -> Button
var _states: Dictionary = {}    # id -> {text, kind, selected, disabled}
var _column_width := 200


func _ready() -> void:
	_palette = load("res://engine/era_palette.tres") as EraPalette


## 一次性建好整块按钮池。
## [br][br]
## [param items] 每项：[code]{id: int, text: String, kind: "toggle"/"action", selected: bool, disabled: bool}[/code]
func setup(items: Array, columns: int, available_width: float) -> void:
	columns = maxi(1, columns)
	self.columns = columns
	var separation: int = get_theme_constant("h_separation")
	_column_width = maxi(int((available_width - separation * (columns - 1)) / columns), 60)

	for item in items:
		if not (item is Dictionary):
			continue
		FontGuard.check(self, str(item.get("text", "")))
		var kind := str(item.get("kind", "action"))
		if kind == "text":
			_add_text_cell(item)
			continue
		var id: int = int(item.get("id", -1))
		if _states.has(id):
			continue
		_states[id] = {
			"text": str(item.get("text", "")),
			"kind": kind,
			"selected": bool(item.get("selected", false)),
			"disabled": bool(item.get("disabled", false)),
		}
		var button := Button.new()
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.x = _column_width
		button.pressed.connect(_on_pressed.bind(id))
		add_child(button)
		_buttons[id] = button
		_refresh(id)


# ---------- 给内容脚本 / 校验场景用的句柄 API ----------

## 当前所有被选中的选择项编号（升序）。
func get_selected() -> Array[int]:
	var result: Array[int] = []
	for id in _states:
		if _states[id]["kind"] == "toggle" and bool(_states[id]["selected"]):
			result.append(int(id))
	result.sort()
	return result


func is_selected(id: int) -> bool:
	return _states.has(id) and bool(_states[id]["selected"])


func is_disabled(id: int) -> bool:
	return _states.has(id) and bool(_states[id]["disabled"])


## 代码里直接改选中状态（不会发 toggled 信号）。
func set_selected(id: int, selected: bool) -> void:
	if not _states.has(id):
		return
	_states[id]["selected"] = selected
	_refresh(id)


## 灰显 / 恢复；禁用期间点击无效。
func set_disabled(id: int, disabled: bool) -> void:
	if not _states.has(id):
		return
	_states[id]["disabled"] = disabled
	_refresh(id)


## 整块失效（进下一屏时由引擎调用）。
func make_inert() -> void:
	for id in _buttons:
		var button: Button = _buttons[id]
		button.disabled = true
		button.modulate = Color(1, 1, 1, 0.45)


## 校验场景用：拿到某个编号的按钮，模拟点击。
func get_button(id: int) -> Button:
	return _buttons.get(id, null)


# ---------- 内部 ----------

## 纯文字格：不可点、不带编号；颜色和对齐由引擎传进来。
func _add_text_cell(item: Dictionary) -> void:
	var label := Label.new()
	label.text = str(item.get("text", ""))
	label.horizontal_alignment = int(item.get("align", HORIZONTAL_ALIGNMENT_LEFT))
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size.x = _column_width
	label.add_theme_color_override("font_color", item.get("color", _palette.normal))
	add_child(label)


func _on_pressed(id: int) -> void:
	if not _states.has(id):
		return
	if bool(_states[id]["disabled"]):
		return
	if _states[id]["kind"] == "toggle":
		var selected := not bool(_states[id]["selected"])
		_states[id]["selected"] = selected
		_refresh(id)
		toggled.emit(id, selected)
	else:
		picked.emit(id)


func _refresh(id: int) -> void:
	var button: Button = _buttons[id]
	var state: Dictionary = _states[id]
	button.text = "[%2d] %s" % [id, str(state["text"])]
	button.disabled = bool(state["disabled"])
	if bool(state["disabled"]):
		button.add_theme_color_override("font_color", _palette.dim)
	elif state["kind"] == "toggle" and bool(state["selected"]):
		button.add_theme_color_override("font_color", _palette.accent)
	else:
		button.add_theme_color_override("font_color", _palette.normal)
