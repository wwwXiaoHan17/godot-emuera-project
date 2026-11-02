extends Control
## 实验 B：页 2。切换过来时，页 1 的文字已经不见了——因为整棵树被换掉了。

@onready var _scroll: ScrollContainer = %Scroll
@onready var _rows: VBoxContainer = %Rows


func _ready() -> void:
	_line("实 验 B：这是页 2")
	_line("────────────────────────────────────────")
	_line("页 1 那 10 行历史文字已经没了 —— 整棵树被换掉了。")
	_line("想往上滚看看刚才的字？没有可滚的内容。")
	_line("")
	var btn := Button.new()
	btn.text = "[0] 返回页 1"
	btn.flat = true
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(_on_back)
	_rows.add_child(btn)
	_scroll_to_bottom()



func _on_back() -> void:
	get_tree().change_scene_to_file("res://experiment/b_scene_switch/b_page1.tscn")


func _line(text: String) -> void:
	var row := Label.new()
	row.text = text
	_rows.add_child(row)


func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)
