extends Node
## CheckCharacterCreate, 校验挂载式角色创建页面（显式输入 + 结果）
##
## 覆盖：configure() 入树前预填、全局状态不影响页面、结果英文键、
## 未配置时拒绝完成。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const PAGE := preload("res://content/screens/character_create.tscn")

var _finished_count := 0
var _result: Variant = null


func _ready() -> void:
	var failures: Array[String] = []

	var host := Control.new()
	add_child(host)
	host.size = Vector2(900, 600)

	# 1) configure() 在 add_child 之前传入初始值，页面入树后显示它
	var page: Control = PAGE.instantiate()
	page.configure({"display_name": "初始名", "age": 20})
	host.add_child(page)
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.finished.connect(_on_finished)
	await get_tree().process_frame
	await get_tree().process_frame

	if (page.get_node("%NameEdit") as LineEdit).text != "初始名":
		failures.append("configure 后名字应显示“初始名”，实际 %s" % (page.get_node("%NameEdit") as LineEdit).text)
	if (page.get_node("%AgeValue") as Label).text != "20":
		failures.append("configure 后年龄应显示 20，实际 %s" % (page.get_node("%AgeValue") as Label).text)

	# 2) 全局状态里的女儿名字不同，不能影响已配置的页面
	var book := CharacterBook.new()
	var global_daughter := Character.new()
	global_daughter.id = &"daughter"
	global_daughter.display_name = "全局名"
	book.add(global_daughter)
	Era.set_character_book(book)

	var isolated: Control = PAGE.instantiate()
	isolated.configure({"display_name": "初始名", "age": 20})
	host.add_child(isolated)
	await get_tree().process_frame
	if (isolated.get_node("%NameEdit") as LineEdit).text != "初始名":
		failures.append("页面不应读取 Era.state；实际显示 %s" % (isolated.get_node("%NameEdit") as LineEdit).text)
	isolated.queue_free()

	# 3) 改名字、年龄 +2，确认后交出英文键结果
	(page.get_node("%NameEdit") as LineEdit).text = "小灯"
	var plus: Button = page.get_node("%Plus")
	plus.pressed.emit()
	plus.pressed.emit()
	(page.get_node("%StartButton") as Button).pressed.emit()

	if _finished_count != 1:
		failures.append("配置完成后应发 1 次 finished，实际 %d" % _finished_count)
	if not (_result is Dictionary):
		failures.append("页面没有交出 Dictionary 数据")
	else:
		var data: Dictionary = _result
		if str(data.get("display_name", "")) != "小灯":
			failures.append("display_name 应为“小灯”，实际 %s" % str(data.get("display_name")))
		if int(data.get("age", 0)) != 22:
			failures.append("age 应为 22，实际 %s" % str(data.get("age")))
		if data.has("天赋"):
			failures.append("角色创建页不应该再交天赋（天赋在 talent_select 里选）")

	# 4) 未 configure 的页面：缺少必填输入时不能完成
	_finished_count = 0
	_result = null
	var unconfigured: Control = PAGE.instantiate()
	host.add_child(unconfigured)
	await get_tree().process_frame
	(unconfigured.get_node("%StartButton") as Button).pressed.emit()
	if _finished_count != 0:
		failures.append("未配置的页面不应发出 finished，实际 %d" % _finished_count)
	unconfigured.queue_free()

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _on_finished(result: Variant) -> void:
	_finished_count += 1
	_result = result
