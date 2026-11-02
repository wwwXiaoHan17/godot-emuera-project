extends Node
## FontGuard, 主题字体缺字告警
##
## GEMono SC / 主题字体关闭了系统回退：缺字时直接画 .notdef 方块（行高不变），
## 但不会报错。本守卫在文字进入行部件时检查一遍，缺字用 push_warning 报出码点，
## 同一码点整局只报一次，避免刷屏。
##
## 用法（行部件里）：
##   const FontGuard := preload("res://engine/font_guard.gd")
##   FontGuard.check(self, text)

## 已告警过的码点，避免重复。
static var _warned: Dictionary = {}

## 这些是不可见/格式类字符，缺字形也不影响阅读，不告警。
const _INVISIBLE_RANGES := [
	Vector2i(0x200B, 0x200F),
	Vector2i(0x2028, 0x202F),
	Vector2i(0x2060, 0x206F),
	Vector2i(0xFE00, 0xFE0F),
	Vector2i(0xFEFF, 0xFEFF),
]


## 检查一段文字里有没有主题字体缺的字形。[param source] 是拿主题字体的任意 Control。
static func check(source: Control, text: String) -> void:
	if text.is_empty() or not source.is_inside_tree():
		return      # 不在树里时主题上下文不完整，拿到的是引擎默认字体，会误报
	var font: Font = source.get_theme_default_font()
	if font == null:
		return
	for i in text.length():
		var cp: int = text.unicode_at(i)
		if cp < 0x20 or _warned.has(cp) or _is_invisible(cp):
			continue
		if font.has_char(cp):
			continue
		_warned[cp] = true
		push_warning("FONT_GLYPH_MISSING U+%04X「%s」：主题字体没有这个字形，会显示缺字方块" % [cp, String.chr(cp)])


static func _is_invisible(cp: int) -> bool:
	for r in _INVISIBLE_RANGES:
		if cp >= r.x and cp <= r.y:
			return true
	return false
