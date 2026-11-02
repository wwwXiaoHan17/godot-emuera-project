extends Control
## 实验 C：常驻壳 + 挂载式页面。
##
## 和 B 的区别：页面 .tscn 不是用 change_scene 换掉整个场景，
## 而是【插进壳里的 Slot】——插进来、等它交出结果、拿出去。
## 壳（背景、滚动区、历史文字、主题）从头到尾没换过。

signal _choice(id: int)

const FORM_PAGE := preload("res://experiment/c_hybrid/c_page_form.tscn")

@onready var _scroll: ScrollContainer = %Scroll
@onready var _rows: VBoxContainer = %Rows
@onready var _slot: Control = %Slot

var _display_name := ""
var _age := 18


func _ready() -> void:
	_run()  # 故意不 await：让演示流程自己跑



func _run() -> void:
	while true:
		await _title_page()
		await _create_character()
		await _day_one()


func _title_page() -> void:
	_clear()
	_line("实 验 C：常驻壳 + 挂载式页面")
	_rule()
	_line("普通文字和选项，还是往同一个壳里追加（和 A 一样）。")
	_line("特殊页面（角色创建）是插进壳里的 .tscn（和 B 一样能用编辑器摆）。", "dim")
	_gap()
	_button("开始新游戏", 0)
	_button("继续游戏（没有存档）", 1)
	await _scroll_to_bottom()
	await _wait_choice()


func _create_character() -> void:
	_gap()
	_line("先创建你的角色。下面这块是挂载进来的页面：", "dim")
	await _scroll_to_bottom()
	var data: Dictionary = await _show_screen(FORM_PAGE)
	_display_name = str(data.get("display_name", "无名"))
	_age = int(data.get("age", 18))
	_gap()
	_line("你叫 %s，%d 岁。" % [_display_name, _age], "accent")
	_line("页面已经被拿掉了，但壳、滚动区、上面的历史文字都还在。", "dim")


func _day_one() -> void:
	_gap()
	_rule("◇ 第一天 ◇")
	_line("%s 醒了过来。" % _display_name)
	_gap()
	_button("继续", 0)
	await _scroll_to_bottom()
	await _wait_choice()


## 关键就这一段：插进壳里 → 等结果 → 拿出来。没有 change_scene。
func _show_screen(scene: PackedScene) -> Variant:
	var page := scene.instantiate()
	_slot.add_child(page)   # 页面插进壳的槽里
	_slot.show()
	_scroll.hide()
	var result: Variant = await page.finished
	_slot.remove_child(page)
	page.queue_free()
	_slot.hide()
	_scroll.show()
	return result


# ---------- 下面就是“引擎那层”将来要做的事，这里先手写一份最小版 ----------

func _line(text: String, style: String = "") -> void:
	var row := Label.new()
	row.text = text
	if style == "dim":
		row.modulate = Color(1, 1, 1, 0.55)
	elif style == "accent":
		row.modulate = Color(0.45, 0.95, 1.0)
	_rows.add_child(row)


func _rule(title: String = "") -> void:
	if title.is_empty():
		_line("────────────────────────────────────────")
	else:
		_line("──── %s ────" % title)


func _gap() -> void:
	_line("")


func _button(text: String, id: int) -> void:
	var row := Button.new()
	row.text = "[%d] %s" % [id, text]
	row.flat = true
	row.alignment = HORIZONTAL_ALIGNMENT_LEFT
	row.pressed.connect(func() -> void: _choice.emit(id))
	_rows.add_child(row)


func _clear() -> void:
	# 不能 free() 正在发信号的按钮，先移出树再排队释放
	for child in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	_scroll.scroll_vertical = 0
	# 内容变短时滚动条尺寸会赖着不走，强制重算
	_scroll.get_combined_minimum_size()
	_scroll.queue_sort()


func _wait_choice() -> int:
	var value: int = await _choice
	for child in _rows.get_children():
		if child is Button:
			(child as Button).disabled = true
			(child as Button).modulate = Color(1, 1, 1, 0.45)
	return value


func _scroll_to_bottom() -> void:
	# 等两帧：第一帧容器排序，第二帧尺寸稳定；只等一帧会滚不动
	await get_tree().process_frame
	await get_tree().process_frame
	var target := int(_rows.size.y - _scroll.size.y)
	_scroll.scroll_vertical = maxi(0, target)
