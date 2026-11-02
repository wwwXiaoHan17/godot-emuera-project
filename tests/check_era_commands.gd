extends Node
## CheckEraCommands, 校验引擎命令与输入流程
##
## 覆盖：print / print_rule / print_gap / print_button、input 返回编号、
## 旧编号失效、wait_key、flow_finished。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const DRIVER := preload("res://tests/_drive_commands.gd")

var _flow_finished := false


func _ready() -> void:
	var failures: Array[String] = []
	Era.flow_finished.connect(_on_flow_finished, CONNECT_ONE_SHOT)

	# 启动事件：start 会先等壳排版，再同步跑到第一个 await Era.input()
	Era.start(DRIVER)
	var guard := 0
	while Era.row_count() < 6 and guard < 120:
		await get_tree().process_frame
		guard += 1
	if Era.row_count() != 6:
		failures.append("启动后应有 6 行（4 文本 + 2 按钮），实际 %d" % Era.row_count())

	# 模拟点“甲”（编号 0）
	Era._choose(0)
	if Era.row_count() != 7:
		failures.append("选择后应追加 1 行，实际 %d" % Era.row_count())

	var tester := Era.state.character_book.find(&"test_character")
	var life := tester.get_component(LifeComponent) as LifeComponent if tester != null else null
	if life == null or life.value != 7:
		failures.append("选择 0 后测试角色的生命组件应为 7，实际 %s" % (
			str(life.value) if life != null else "无组件"
		))

	# 旧编号不该再生效
	Era._choose(1)
	if life != null and life.value != 7:
		failures.append("选择结束后旧编号不该再生效")

	# 模拟按任意键，流程结束
	Era._resolve_key()
	if not _flow_finished:
		failures.append("流程没有结束（flow_finished 没发出）")

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _on_flow_finished() -> void:
	_flow_finished = true
