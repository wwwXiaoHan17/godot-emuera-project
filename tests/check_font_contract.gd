extends Node
## CheckFontContract, 校验主题字体 GEMono SC 的度量契约
##
## 覆盖：字体身份、系统回退关闭、行高（不做固定，断言当前原生值）、逐字符
## advance ∈ {font_size/2, font_size}、ERB 字符画整串对齐、缺字清单与构建产物一致。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const CHARSET_PATH := "res://tools/font/charset.txt"
const MISSING_PATH := "res://tools/font/charset_missing.txt"
const EXPECTED_FONT_NAME := "GE Mono SC"
const EXPECTED_LINE_HEIGHT := 22.0
## 不可见/格式类字符不参与 advance 断言（宽度 0 合法）。
const INVISIBLE_RANGES := [Vector2i(0x200B, 0x200F), Vector2i(0x2028, 0x202F),
	Vector2i(0x2060, 0x206F), Vector2i(0xFE00, 0xFE0F), Vector2i(0xFEFF, 0xFEFF)]


func _ready() -> void:
	var failures: Array[String] = []
	var theme: Theme = _load_project_theme()
	if theme == null:
		_finish(["读不到 gui/theme/custom 指向的主题资源"], failures)
		return
	var font: Font = theme.default_font
	if font == null:
		_finish(["主题 default_font 为空"], failures)
		return
	var fs: int = theme.default_font_size
	var half := fs / 2.0
	var full := float(fs)

	# 1) 字体身份与「关系统回退」
	if font.get_font_name() != EXPECTED_FONT_NAME:
		failures.append("主题字体应为 %s，实际 %s" % [EXPECTED_FONT_NAME, font.get_font_name()])
	var font_file := font as FontFile
	if font_file == null:
		failures.append("主题字体不是 FontFile（内嵌字体预期是 FontFile）")
	elif font_file.allow_system_fallback:
		failures.append("allow_system_fallback 必须为 false，否则缺字会回退并撑高行")

	# 2) 行高：不做固定，锁定当前字体原生高度，防止换字体后悄悄变高
	if not is_equal_approx(font.get_height(fs), EXPECTED_LINE_HEIGHT):
		failures.append("行高应为 %s（@%d），实际 %s" % [str(EXPECTED_LINE_HEIGHT), fs, str(font.get_height(fs))])

	# 3) 逐字符 advance 契约
	var charset := FileAccess.get_file_as_string(CHARSET_PATH)
	if charset.is_empty():
		failures.append("读不到字符集 " + CHARSET_PATH)
	var missing_actual := ""
	var bad: Array[String] = []
	for i in charset.length():
		var ch := charset[i]
		var cp := ch.unicode_at(0)
		if not font.has_char(cp):
			missing_actual += ch          # 缺字清单按全量比对（含不可见控制符）
			continue
		if _is_invisible(cp):
			continue
		var w := font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		if is_zero_approx(w):
			continue
		if not (is_equal_approx(w, half) or is_equal_approx(w, full)):
			if bad.size() < 10:
				bad.append("U+%04X=%s" % [cp, str(w)])
	if not bad.is_empty():
		failures.append("advance 不是 %s/%s：%s" % [str(half), str(full), ", ".join(bad)])

	# 4) 缺字清单必须与构建产物一致（GEMono SC 的契约：缺字=已知集合，不会多）
	var expected_missing := FileAccess.get_file_as_string(MISSING_PATH)
	if missing_actual != expected_missing:
		failures.append("缺字清单与 tools/font/charset_missing.txt 不一致：实测 %d 个，期望 %d 个" % [missing_actual.length(), expected_missing.length()])

	# 5) ERB 字符画：整串宽度必须等于格数 × 半角宽（无 kerning）
	var box := "┏━━━━━━━━━━┓"          # 12 个全角格
	if not is_equal_approx(font.get_string_size(box, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x, 12.0 * full):
		failures.append("字符画框线串宽应为 12 格 = %s，实际 %s" % [str(12.0 * full), str(font.get_string_size(box, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)])
	var blocks := "▰▰▰▰▱▱▱▱"        # 8 个半角格
	if not is_equal_approx(font.get_string_size(blocks, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x, 8.0 * half):
		failures.append("块元素串宽应为 8 个半角格 = %s，实际 %s" % [str(8.0 * half), str(font.get_string_size(blocks, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)])

	# 6) 混排串：整串宽 = 逐字宽之和（防止 kerning 破坏对齐）
	for sample in ["中文abc测试", "「测试」……", "abcdefghij", "第1章：开始"]:
		var per_char := 0.0
		for i in sample.length():
			per_char += font.get_string_size(sample[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var shaped := font.get_string_size(sample, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		if not is_equal_approx(shaped, per_char):
			failures.append("混排串宽 ≠ 逐字和（有 kerning？）：%s 实测=%s 逐字和=%s" % [sample, str(shaped), str(per_char)])

	# 7) 本项目常用字必须全部命中（含 2026-11-05 补的 ∬ 卍 · ）
	for ch in "查询测试选择存档读取战斗道具技能状态设置返回结局开始游戏∬卍·":
		if not font.has_char(ch.unicode_at(0)):
			failures.append("常用字缺字形：" + ch)

	# 8) Label / Button 实测高度 = 行高
	var holder := Control.new()
	add_child(holder)
	holder.theme = theme
	for sample in ["abc", "查询测试", "┏━━━━━━━━━━┓"]:
		var label := Label.new()
		label.text = sample
		holder.add_child(label)
		if not is_equal_approx(label.get_combined_minimum_size().y, EXPECTED_LINE_HEIGHT):
			failures.append("Label(%s) 高度=%s，应为 %s" % [sample, str(label.get_combined_minimum_size().y), str(EXPECTED_LINE_HEIGHT)])
		var button := Button.new()
		button.text = sample
		holder.add_child(button)
		if not is_equal_approx(button.get_combined_minimum_size().y, EXPECTED_LINE_HEIGHT):
			failures.append("Button(%s) 高度=%s，应为 %s" % [sample, str(button.get_combined_minimum_size().y), str(EXPECTED_LINE_HEIGHT)])

	_finish([], failures)


func _finish(errors: Array, failures: Array[String]) -> void:
	for e in errors:
		failures.append(e)
	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _load_project_theme() -> Theme:
	var setting := str(ProjectSettings.get_setting("gui/theme/custom", ""))
	if setting.is_empty():
		return null
	var resource = load(setting)
	return resource as Theme


func _is_invisible(cp: int) -> bool:
	for r in INVISIBLE_RANGES:
		if cp >= r.x and cp <= r.y:
			return true
	return false
