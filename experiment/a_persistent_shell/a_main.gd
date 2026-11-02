extends Control
## 实验 A：常驻壳 + 文本流。
##
## 核心：整个游戏只有一个场景（就是本场景）。所谓“下一页”“回到标题”，
## 只是换一段代码继续往同一个滚动区里印字，不换场景。

## “选择结果”通过这个信号交回流程。
signal _choice(id: int)

@onready var _scroll: ScrollContainer = %Scroll
@onready var _rows: VBoxContainer = %Rows


func _ready() -> void:
	_run()  # 故意不 await：让演示流程自己跑



func _run() -> void:
	while true:
		await _title_page()
		await _second_page()


## 标题页：把内容一行一行印出来，然后等玩家点按钮。
func _title_page() -> void:
	_clear()
	_line("实 验 A：常驻壳 + 文本流")
	_rule()
	_line("这个画面是用命令一行一行“印”出来的。")
	_line("点“开始游戏”后，新文字会继续往下加——像 Emuera。", "dim")
	_gap()
	_button("开始游戏", 0)
	_button("继续游戏", 1)
	await _scroll_to_bottom()
	await _wait_choice()


## 第二页：没有换场景，只是继续往同一个滚动区里追加文字。
func _second_page() -> void:
	_gap()
	_line("【第二页】上面第一页的字还在，只是往下滚。", "accent")
	_line("这就是“同一个控制台，换一段逻辑”。", "dim")
	_gap()
	_button("返回标题", 0)
	_button("再印三十行", 1)
	await _scroll_to_bottom()
	var pick: int = await _wait_choice()
	if pick == 1:
		for i in 30:
			_line("追加第 %d 行" % (i + 1))
		_gap()
		_button("返回标题", 0)
		await _scroll_to_bottom()
		await _wait_choice()
	# 回到 _run() 的循环，再进标题页（标题页会主动清屏）


# ---------- 下面就是“引擎那层”将来要做的事，这里先手写一份最小版 ----------

func _line(text: String, style: String = "") -> void:
	var row := Label.new()
	row.text = text
	if style == "dim":
		row.modulate = Color(1, 1, 1, 0.55)
	elif style == "accent":
		row.modulate = Color(0.45, 0.95, 1.0)
	_rows.add_child(row)


func _rule() -> void:
	_line("────────────────────────────────────────")


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
	# 注意：不能用 free()。这个函数是在按钮的 pressed 信号里被调到的，
	# 直接 free() 正在发信号的按钮会报 “locked object”。先移出树，再排队释放。
	for child in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	# 清空后滚回顶部；否则 ScrollContainer 还记着旧的滚动位置，会看到空白
	_scroll.scroll_vertical = 0
	# 内容变短时 ScrollContainer 的滚动条尺寸会“赖着不走”，强制它重算一次
	_scroll.get_combined_minimum_size()
	_scroll.queue_sort()


func _wait_choice() -> int:
	var value: int = await _choice
	# 选完以后，旧按钮要失效（还能看见，但不能再点）——Emuera 里就是这样。
	for child in _rows.get_children():
		if child is Button:
			(child as Button).disabled = true
			(child as Button).modulate = Color(1, 1, 1, 0.45)
	return value


func _scroll_to_bottom() -> void:
	# 等两帧：第一帧容器排序，第二帧尺寸才稳定；只等一帧会滚不动
	await get_tree().process_frame
	await get_tree().process_frame
	var target := int(_rows.size.y - _scroll.size.y)
	_scroll.scroll_vertical = maxi(0, target)
