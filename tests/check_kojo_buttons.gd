extends Node
## CheckKojoButtons, 校验带按钮的口上 + sync + 开关 + 计数（第 4 步）
##
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const DRIVER := preload("res://tests/_drive_kojo_buttons.gd")


func _ready() -> void:
	var failures: Array[String] = []

	Era.start(DRIVER)
	var guard := 0
	while Era.row_count() < 4 and guard < 120:
		await get_tree().process_frame
		guard += 1
	if Era.row_count() != 4:
		failures.append("“撒娇”口上应有 1 行文字 + 3 个按钮 = 4 行，实际 %d" % Era.row_count())

	# 选“抱抱”（编号 1）
	Era._choose(1)
	await get_tree().process_frame
	await get_tree().process_frame

	var daughter := Era.character(&"daughter")
	if daughter == null:
		failures.append("找不到女儿角色")
	var texts := _row_texts()
	if not texts.has("（紧紧抱住。）"):
		failures.append("选“抱抱”后应打印“（紧紧抱住。）”，实际 %s" % str(texts))
	if not texts.has("picked=1"):
		failures.append("Era.kojo 应返回 1，实际行：%s" % str(texts))

	var kojo := daughter.get_component(KojoComponent) as KojoComponent if daughter != null else null
	if kojo == null:
		failures.append("女儿没有口上组件")
	else:
		if kojo.counter(&"act_cute") != 1:
			failures.append("撒娇调用次数应为 1，实际 %d" % kojo.counter(&"act_cute"))

		# 关掉“撒娇”后调用：返回 null、不打印
		kojo.set_event_enabled(&"act_cute", false)
		Era.clear()
		var disabled: Variant = await Era.kojo(daughter, &"act_cute", {"partner": Era.character(&"player")})
		if disabled != null or Era.row_count() != 0:
			failures.append("关掉的口上不应输出，实际 result=%s rows=%d" % [str(disabled), Era.row_count()])
		kojo.set_event_enabled(&"act_cute", true)

		# 计数应保持 1（关掉的那次没执行）
		if kojo.counter(&"act_cute") != 1:
			failures.append("被关掉的调用不应增加计数，实际 %d" % kojo.counter(&"act_cute"))

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _row_texts() -> Array[String]:
	var texts: Array[String] = []
	var rows := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Scroll/Rows")
	if rows == null:
		return texts
	for row in rows.get_children():
		var label := row.get_node_or_null("Label") as Label
		if label != null and label.visible:
			texts.append(label.text)
			continue
		var rich := row.get_node_or_null("RichTextLabel") as RichTextLabel
		if rich != null and rich.visible:
			texts.append(rich.text)
	return texts
