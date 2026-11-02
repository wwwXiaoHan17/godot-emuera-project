extends Node
## CheckTextRow, 校验 TextRow
##
## 覆盖三种情况：
## 1. 普通文字 → Label 可见、RichTextLabel 隐藏；
## 2. 含 BBCode → RichTextLabel 可见、行内标签保留；
## 3. 对齐（Label 与 BBCode 两个分支）。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const TextRowScene := preload("res://engine/rows/text_row.tscn")


func _ready() -> void:
	var failures: Array[String] = []

	var row: MarginContainer = TextRowScene.instantiate()
	add_child(row)
	var label: Label = row.get_node("Label")
	var rich: RichTextLabel = row.get_node("RichTextLabel")

	# 1) 普通文字走 Label
	row.setup("普通文字", Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT)
	if not label.visible or rich.visible:
		failures.append("普通文字应该只显示 Label")
	if label.text != "普通文字":
		failures.append("Label 文字不正确")
	if not label.has_theme_color_override("font_color"):
		failures.append("Label 没有设置文字颜色")

	# 2) 含 BBCode 走 RichTextLabel
	row.setup("[color=#ff8888]红[/color]", Color(1, 0.5, 0.5), HORIZONTAL_ALIGNMENT_LEFT)
	if not rich.visible or label.visible:
		failures.append("含 BBCode 应该只显示 RichTextLabel")
	if not rich.text.contains("[color"):
		failures.append("RichTextLabel 的行内标签丢了")
	if not rich.has_theme_color_override("default_color"):
		failures.append("RichTextLabel 没有设置文字颜色")

	# 3) 对齐：Label 分支
	row.setup("居中", Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	if label.horizontal_alignment != HORIZONTAL_ALIGNMENT_CENTER:
		failures.append("Label 居中对齐没生效")

	# 4) 对齐：BBCode 分支用 [center] 包一层
	row.setup("[center]居中的 BBCode[/center]", Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	if not rich.text.contains("[center]"):
		failures.append("RichTextLabel 居中标签没生效")

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)
