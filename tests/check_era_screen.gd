extends Node
## CheckEraScreen, 校验常驻壳 EraScreen
##
## 覆盖：追加行、行数上限裁剪、清屏、滚动归零、按宽度算分割线字数。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const EraScreenScene := preload("res://engine/era_screen.tscn")
const TEST_SIZE := Vector2(1152, 648)


func _ready() -> void:
	var failures: Array[String] = []

	# 用一个固定尺寸的宿主，避免 headless 窗口太小影响宽度计算
	var host := Control.new()
	add_child(host)
	host.size = TEST_SIZE

	var screen: Control = EraScreenScene.instantiate()
	host.add_child(screen)
	await get_tree().process_frame
	await get_tree().process_frame

	# 1) 追加行
	for i in 3:
		screen.append_row(Label.new())
	if screen.row_count() != 3:
		failures.append("追加 3 行后 row_count 应为 3，实际 %d" % screen.row_count())

	# 2) 行数上限：再追加 600 行，应只剩 500 行
	for i in 600:
		screen.append_row(Label.new())
	if screen.row_count() != 500:
		failures.append("超过上限后应剩 500 行，实际 %d" % screen.row_count())

	# 3) 按宽度算分割线字数：窄符号（╍ 8px）应比全角（■ 16px）多
	var count_thin: int = screen.text_char_count("╍")
	var count_wide: int = screen.text_char_count("■")
	if count_thin <= 0 or count_wide <= 0:
		failures.append("分割线字数应大于 0（╍=%d, ■=%d）" % [count_thin, count_wide])
	elif count_wide >= count_thin:
		failures.append("全角符号的字数应少于窄符号（╍=%d, ■=%d）" % [count_thin, count_wide])

	# 4) 清屏
	screen.clear_rows()
	if screen.row_count() != 0:
		failures.append("清屏后 row_count 应为 0，实际 %d" % screen.row_count())
	if screen.scroll_offset() != 0:
		failures.append("清屏后滚动位置应为 0，实际 %d" % screen.scroll_offset())

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)
