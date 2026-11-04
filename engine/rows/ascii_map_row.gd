extends VBoxContainer
## AsciiMapRow，eraTW 风格彩色字符画（方案 A）
##
## 一行 = 一个 [HBoxContainer]（间距 0），按“数字”切段：
## - 非数字段 = [RichTextLabel]：逐字上色，宽度按主题字体的实际字形宽度累加；
## - 数字段 = [Button]：真按钮，点击发 [signal picked]（编号就是数字本身）。
## [br][br]
## 行与行之间留 4px，让行距和文字行一致（22px 行高 + 4px 间距 = 26px 行距）。
## 宽度全部实测，所以全角/半角混排也能拼回原来的格子。

## 地图上的数字按钮被点了，[param id] 是数字本身（例如 06 → 6）。
signal picked(id: int)

const FontGuard := preload("res://engine/font_guard.gd")

## 行与行之间的间距，跟文字行的 VBox 间距一致。
const ROW_SEPARATION := 4
## 没有指定默认色时的文字颜色。
const DEFAULT_COLOR := Color(0.78, 0.78, 0.78)

## eraTW 季节色/名字色的近似值（原型固定表；正式版应由季节系统给）。
const NAMED_COLORS := {
	"white": Color(1, 1, 1),
	"black": Color(0, 0, 0),
	"floran": Color("#66994c"),
	"florad": Color("#33551f"),
	"floras": Color("#99bb66"),
	"floral": Color("#88ccaa"),
	"bambool": Color("#44aa44"),
	"bamboon": Color("#66cc66"),
	"bambood": Color("#116611"),
	"ground": Color("#8b6b3f"),
	"paving": Color("#9a9a8a"),
	"sakuran": Color("#ffb7c5"),
	"sakurad": Color("#ee88aa"),
	"steam": Color("#bbbbbb"),
}

var _default_color := DEFAULT_COLOR
var _current_color := DEFAULT_COLOR
var _line_height := 22.0
var _font: Font
var _font_size := 16
var _char_widths: Dictionary = {}
var _buttons: Array[Button] = []
var _ids: Array[int] = []


## 构建整块地图。
## [br][br]
## [param rows] 每行一个字符串；[param color_rows] 每行一个逗号分隔的颜色标记：
## [code]""[/code] 沿用上一格、[code]"def"[/code] / [code]"0"[/code] 默认色、
## [code]"0xRRGGBB"[/code] 具体颜色、其他名字查 [constant NAMED_COLORS]。
func setup(rows: Array, color_rows: Array, default_color: Color = DEFAULT_COLOR) -> void:
	_default_color = default_color
	_current_color = default_color
	add_theme_constant_override("separation", ROW_SEPARATION)
	_font = get_theme_default_font()
	_font_size = get_theme_default_font_size()
	if _font == null:
		push_warning("AsciiMapRow：拿不到主题字体，地图宽度会不准")
		return
	_line_height = float(_font.get_height(_font_size))
	var count := mini(rows.size(), color_rows.size())
	for i in count:
		_build_row(str(rows[i]), str(color_rows[i]))


## 已经建好的按钮编号（升序）。
func button_ids() -> Array[int]:
	var result := _ids.duplicate()
	result.sort()
	return result


## 校验用：按编号取按钮节点。
func get_button(id: int) -> Variant:
	var index := _ids.find(id)
	if index < 0:
		return null
	return _buttons[index]


## 输入结束后由引擎调用：地图上的按钮全部失效（跟别的行部件一致）。
func make_inert() -> void:
	for button in _buttons:
		button.disabled = true


# ---------- 内部 ----------

## 把一行拆成“数字段 / 非数字段”再分别建控件。
func _build_row(text: String, color_csv: String) -> void:
	FontGuard.check(self, text)
	var tokens := color_csv.split(",")
	var row := HBoxContainer.new()
	row.name = "MapRow%d" % get_child_count()
	row.add_theme_constant_override("separation", 0)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(row)

	var index := 0
	while index < text.length():
		var start := index
		var digit := _is_digit(text[index])
		while index < text.length() and _is_digit(text[index]) == digit:
			index += 1
		var segment := text.substr(start, index - start)
		if digit:
			_add_button(row, segment, tokens, start)
		else:
			_add_text_segment(row, segment, tokens, start)


func _add_text_segment(row: HBoxContainer, segment: String, tokens: PackedStringArray, start_index: int) -> void:
	var bbcode := ""
	var width := 0.0
	var last_color := Color(-1, -1, -1, -1)
	var opened := false
	for k in segment.length():
		var ch := segment[k]
		var color := _resolve_color(tokens, start_index + k)
		if not opened or not color.is_equal_approx(last_color):
			if opened:
				bbcode += "[/color]"
			bbcode += "[color=#%s]" % color.to_html(false)
			last_color = color
			opened = true
		bbcode += _escape_char(ch)
		width += _char_width(ch)
	if opened:
		bbcode += "[/color]"

	var label := RichTextLabel.new()
	label.name = "MapText%d" % row.get_child_count()
	label.bbcode_enabled = true
	label.fit_content = false
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	label.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	label.custom_minimum_size = Vector2(width, _line_height)
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	label.text = bbcode
	row.add_child(label)


func _add_button(row: HBoxContainer, digits: String, tokens: PackedStringArray, start_index: int) -> void:
	var width := 0.0
	var text_color := _default_color
	for k in digits.length():
		text_color = _resolve_color(tokens, start_index + k)
		width += _char_width(digits[k])

	var value := int(digits)
	var button := Button.new()
	button.name = "MapButton%d" % value
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.text = digits
	button.custom_minimum_size = Vector2(width, _line_height)
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.pressed.connect(_on_pressed.bind(value))
	row.add_child(button)
	_buttons.append(button)
	_ids.append(value)


func _on_pressed(id: int) -> void:
	picked.emit(id)


## 解析一格颜色；[code]""[/code] 表示沿用上一格。
func _resolve_color(tokens: PackedStringArray, index: int) -> Color:
	if index >= tokens.size():
		return _current_color
	var token := tokens[index].strip_edges()
	if token.is_empty():
		return _current_color
	var color := _parse_color(token)
	if color.r >= 0.0:
		_current_color = color
	return _current_color


func _parse_color(token: String) -> Color:
	var key := token.to_lower()
	if key == "def" or key == "0":
		return _default_color
	if NAMED_COLORS.has(key):
		return NAMED_COLORS[key]
	if key.begins_with("0x"):
		return Color.html(key.substr(2))
	if key.begins_with("#"):
		return Color.html(key.substr(1))
	return Color(-1, -1, -1, -1)


func _char_width(ch: String) -> float:
	if not _char_widths.has(ch):
		_char_widths[ch] = _font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size).x
	return float(_char_widths[ch])


func _is_digit(ch: String) -> bool:
	return ch.length() == 1 and ch >= "0" and ch <= "9"


## BBCode 里 "[code][[/code]" 要写成 [code][lb][/code]；地图的字符画里暂时没有别的特殊字符。
func _escape_char(ch: String) -> String:
	if ch == "[":
		return "[lb]"
	return ch
