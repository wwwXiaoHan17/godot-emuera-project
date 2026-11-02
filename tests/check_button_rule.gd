extends Node
## CheckButtonRule, 校验 ButtonRow 与 RuleRow
##
## ButtonRow：自动编号、对齐、不抢焦点、picked 信号、失效后不能再点。
## RuleRow：只做最简单的“符号重复”，长度由外部传入。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const ButtonRowScene := preload("res://engine/rows/button_row.tscn")
const RuleRowScene := preload("res://engine/rows/rule_row.tscn")


func _ready() -> void:
	var failures: Array[String] = []

	# ---------- ButtonRow ----------
	var button: Button = ButtonRowScene.instantiate()
	add_child(button)
	button.setup("开始游戏", 0, HORIZONTAL_ALIGNMENT_LEFT)

	if button.text != "[0] 开始游戏":
		failures.append("按钮编号前缀不对：%s" % button.text)
	if not button.flat:
		failures.append("按钮应该是平的（flat）")
	if button.focus_mode != Control.FOCUS_NONE:
		failures.append("按钮不应该抢键盘焦点")
	if button.alignment != HORIZONTAL_ALIGNMENT_LEFT:
		failures.append("按钮文字对齐没生效")

	var received: Array[int] = []
	button.picked.connect(func(id: int) -> void: received.append(id))
	button.pressed.emit()
	if received != [0]:
		failures.append("picked 信号没收到 id 0，收到：%s" % str(received))

	button.make_inert()
	if not button.disabled:
		failures.append("make_inert() 后按钮应 disabled")
	if not is_equal_approx(button.modulate.a, 0.45):
		failures.append("make_inert() 后按钮应变暗")

	# ---------- RuleRow ----------
	var rule: Label = RuleRowScene.instantiate()
	add_child(rule)

	rule.setup("╍", 10)
	if rule.text.length() != 10:
		failures.append("分割线长度应为 10，实际 %d" % rule.text.length())
	if rule.text.count("╍") != 10:
		failures.append("分割线应该全是 ╍")

	rule.setup("■", 8)
	if rule.text.length() != 8:
		failures.append("换符号后分割线长度应为 8，实际 %d" % rule.text.length())
	if rule.text.count("■") != 8:
		failures.append("换符号后分割线应该全是 ■")

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)
