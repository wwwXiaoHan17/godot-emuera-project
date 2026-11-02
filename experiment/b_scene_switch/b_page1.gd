extends Control
## 实验 B：一个“页面” = 一个 .tscn；用 change_scene_to_file() 当 goto。
##
## 观察点：
## 1. 点开始后整屏被换掉，页 1 的历史文字不再存在。
## 2. 切场景后旧场景已经离开树，里面的代码继续执行会报错。

@onready var _scroll: ScrollContainer = %Scroll
@onready var _rows: VBoxContainer = %Rows


func _ready() -> void:
	_line("实 验 B：每页一个 .tscn，用 change_scene 当 goto")
	_line("────────────────────────────────────────")
	_line("下面这些是“页 1 的历史文字”，一共 10 行：")
	for i in 10:
		_line("页 1 的第 %d 行历史文字" % (i + 1))
	_line("")
	var btn := Button.new()
	btn.text = "[0] 开始游戏 → 切换到页 2"
	btn.flat = true
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(_on_start)
	_rows.add_child(btn)
	_scroll_to_bottom()



func _on_start() -> void:
	print("[B] 切换前 get_tree() = ", get_tree())
	get_tree().change_scene_to_file("res://experiment/b_scene_switch/b_page2.tscn")
	print("[B] 切换后 get_tree() = ", get_tree())
	# 下面这行模拟“内容流程还要继续往下走（比如再等玩家一次点击）”。
	# 旧场景已经离树，所以这里会报错，后面的代码不会执行：
	await get_tree().process_frame
	print("[B] 你没看到这行，说明流程在这里断了")


func _line(text: String) -> void:
	var row := Label.new()
	row.text = text
	_rows.add_child(row)


func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)
