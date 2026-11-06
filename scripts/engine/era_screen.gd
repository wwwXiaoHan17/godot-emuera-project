extends Control
## EraScreen, 常驻壳
##
## 引擎里唯一的一份“屏幕”：背景、滚动区、行容器、页面槽。
## 只负责行级别的操作（追加 / 裁上限 / 滚动 / 清屏 / 按宽度算字数），
## 不认识游戏状态，也不认识事件。
## [br][br]
## 页面槽 [code]Slot[/code] 留给第 3 步的挂载式页面，现在先隐藏。

## 行数上限。
## [br][br]
## 超过就该数值将移除旧的节点，防止一直增加节点，导致游戏内存过大。
const MAX_ROWS := 500

@onready var _scroll: ScrollContainer = %Scroll
@onready var _rows: VBoxContainer = %Rows
@onready var _slot: Control = %Slot

var _scroll_queued := false


## 追加一行。超过上限时移除旧节点，然后请求滚到底。多行连发时只滚一次
func append_row(row: Control) -> void:
	_rows.add_child(row)
	while _rows.get_child_count() > MAX_ROWS:
		var oldest := _rows.get_child(0)
		_rows.remove_child(oldest)
		oldest.queue_free()
	_request_scroll()


## 当前行数。
func row_count() -> int:
	return _rows.get_child_count()


## 当前滚动位置，给校验场景用。
func scroll_offset() -> int:
	return _scroll.scroll_vertical


## 清空所有行，并回到顶部。
func clear_rows() -> void:
	for child in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	_scroll.scroll_vertical = 0
	# 内容变短时滚动条尺寸会赖着不走，强制重算一次
	_scroll.get_combined_minimum_size()
	_scroll.queue_sort()


## 把一个挂载式页面放进页面槽；文字流暂时藏起来。
func show_page(page: Control) -> void:
	_slot.add_child(page)
	_slot.show()
	_scroll.hide()


## 把页面拿掉，恢复文字流（历史文字和滚动位置都还在）。
func hide_page(page: Control) -> void:
	_slot.remove_child(page)
	page.queue_free()
	_slot.hide()
	_scroll.show()


## 现在槽里有几个页面（校验场景用）。
func page_count() -> int:
	return _slot.get_child_count()


## 滚到底。等两帧让容器先排版，再按内容高度算目标位置。
func scroll_to_bottom() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var target := int(_rows.size.y - _scroll.size.y)
	_scroll.scroll_vertical = maxi(0, target)


## 当前文字区宽度（给分割线字数、引擎启动等待用）。
func text_width() -> float:
	if _rows.size.x > 0.0:
		return _rows.size.x
	return _scroll.size.x


## 按当前文字区宽度，算某个符号要重复几次才能占满一整行。
## 拿不到字体或宽度时退回 144。
func text_char_count(char: String) -> int:
	if char.is_empty():
		return 0
	var font: Font = _rows.get_theme_default_font()
	if font == null:
		return 144
	var font_size: int = _rows.get_theme_default_font_size()
	var char_width := font.get_string_size(char, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var width := text_width()
	if char_width <= 0.0 or width <= 0.0:
		return 144
	return maxi(1, int(floor(width / char_width)))


## 合并连续追加时的滚动请求。一帧内只排一次“滚到底”。
func _request_scroll() -> void:
	if _scroll_queued:
		return
	_scroll_queued = true
	await scroll_to_bottom()
	_scroll_queued = false
