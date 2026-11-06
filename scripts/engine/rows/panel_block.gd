extends Control
## PanelBlock，EraFlet 面板块
##
## 一块“画布”：面板用绝对坐标摆放，整块高度由面板声明的行数决定
## （取所有面板里最长的行数 × 26px，再减掉最后一行后面不需要的 4px 间距），
## 这样跟在后面的文字行仍然落在 26px 的同一套行距上。
## [br][br]
## 面板内容默认竖排（VBox，行距 4px）；横排用 hbox 项（HBox，间距可调）。
## 按钮（包括地图里的数字按钮）点击后发 [signal picked]，编号交给引擎。

## 面板里的按钮被点了，[param id] 是按钮编号。
signal picked(id: int)

const TEXT_ROW_SCENE := preload("res://scripts/engine/rows/text_row.tscn")
const BUTTON_ROW_SCENE := preload("res://scripts/engine/rows/button_row.tscn")
const ASCII_MAP_ROW_SCENE := preload("res://scripts/engine/rows/ascii_map_row.tscn")

## 一行文字的行距（22px 行高 + 4px 间距）。
const LINE_PITCH := 26.0
const LINE_GAP := 4.0

var _buttons: Dictionary = {}   # id -> 按钮节点（ButtonRow 或 AsciiMapRow）
var _ids: Array[int] = []
var _max_rows := 0


## 构建整块面板。
## [br][br]
## [param panels] 每项：[code]{x, y, w, h, rows, items: [...]}[/code]；
## items 里每项是 [code]{kind: "text"/"button"/"hbox"/"map", ...}[/code]。
func build(panels: Array) -> void:
	for panel in panels:
		if not (panel is Dictionary):
			continue
		_max_rows = maxi(_max_rows, int(panel.get("rows", 0)))
		var width := int(panel.get("w", 100))
		var height := int(panel.get("h", 100))
		var frame := PanelContainer.new()
		frame.name = "Panel%d" % get_child_count()
		frame.position = Vector2(int(panel.get("x", 0)), int(panel.get("y", 0)))
		frame.custom_minimum_size = Vector2(width, height)
		frame.size = Vector2(width, height)
		frame.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		frame.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(frame)

		# 面板是“死框”：内容放进一个会裁剪的 Control 里，面板不会因为内容多而变大。
		var clip := Control.new()
		clip.clip_contents = true
		clip.mouse_filter = Control.MOUSE_FILTER_PASS
		frame.add_child(clip)
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", int(LINE_GAP))
		clip.add_child(box)
		box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_build_items(box, panel.get("items", []))

		_check_overflow_later.call_deferred(frame.get_index(), box, clip)
	if _max_rows > 0:
		custom_minimum_size.y = _max_rows * LINE_PITCH - LINE_GAP


## 面板内容放不下时警告一次（面板本身固定大小，超出部分会被裁掉）。
func _check_overflow_later(index: int, box: VBoxContainer, clip: Control) -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if not is_inside_tree():
		return      # 这一帧里被 clear() 拿掉了，不用再警告
	await get_tree().process_frame
	if not is_inside_tree() or not is_instance_valid(box) or not is_instance_valid(clip):
		return
	var need := box.get_combined_minimum_size()
	var available := clip.size
	if need.x > available.x + 0.5 or need.y > available.y + 0.5:
		push_warning(
			"PanelBlock：面板 %d 的内容超出面板（需要 %.0f x %.0f，可用 %.0f x %.0f），超出部分会被裁掉"
			% [index, need.x, need.y, available.x, available.y]
		)


## 已经建好的按钮编号（升序）。
func button_ids() -> Array[int]:
	var result := _ids.duplicate()
	result.sort()
	return result


## 校验用：按编号取按钮节点。
func get_button(id: int) -> Variant:
	return _buttons.get(id, null)


## 输入结束后由引擎调用：整块按钮失效（跟别的行部件一致）。
func make_inert() -> void:
	for node in _buttons.values():
		if node.has_method("make_inert"):
			node.make_inert()
		elif node is Button:
			(node as Button).disabled = true


# ---------- 内部 ----------

func _build_items(box: Container, items: Array) -> void:
	for item in items:
		if not (item is Dictionary):
			continue
		match str(item.get("kind", "")):
			"text":
				var row: Variant = TEXT_ROW_SCENE.instantiate()
				box.add_child(row)
				row.setup(
					str(item.get("text", "")),
					item.get("color", Color(0.78, 0.78, 0.78)),
					int(item.get("align", HORIZONTAL_ALIGNMENT_LEFT))
				)
			"button":
				_add_button(box, item)
			"hbox":
				_add_hbox(box, item)
			"map":
				_add_map(box, item)


func _add_hbox(box: Container, item: Dictionary) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", int(item.get("separation", 0)))
	hbox.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	box.add_child(hbox)
	for child in item.get("items", []):
		if not (child is Dictionary):
			continue
		match str(child.get("kind", "")):
			"text":
				var label := Label.new()
				label.text = str(child.get("text", ""))
				label.autowrap_mode = TextServer.AUTOWRAP_OFF
				label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
				label.add_theme_color_override("font_color", child.get("color", Color(0.78, 0.78, 0.78)))
				hbox.add_child(label)
			"button":
				_add_button(hbox, child)


func _add_button(box: Container, item: Dictionary) -> void:
	var row: Variant = BUTTON_ROW_SCENE.instantiate()
	box.add_child(row)
	row.setup(
		str(item.get("text", "")),
		int(item.get("id", -1)),
		int(item.get("align", HORIZONTAL_ALIGNMENT_LEFT))
	)
	row.picked.connect(_on_picked)
	_register(int(item.get("id", -1)), row)


func _add_map(box: Container, item: Dictionary) -> void:
	var map: Variant = ASCII_MAP_ROW_SCENE.instantiate()
	box.add_child(map)
	map.setup(
		item.get("rows", []),
		item.get("colors", []),
		item.get("color", Color(0.78, 0.78, 0.78))
	)
	map.picked.connect(_on_picked)
	for id in map.button_ids():
		_register(int(id), map)


func _register(id: int, node: Variant) -> void:
	if id < 0:
		push_warning("PanelBlock：按钮编号是负数")
		return
	if _buttons.has(id):
		push_warning("PanelBlock：按钮编号 %d 重复了" % id)
		return
	_buttons[id] = node
	_ids.append(id)


func _on_picked(id: int) -> void:
	picked.emit(id)
