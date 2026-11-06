extends MarginContainer
## TextRow, 一行文字
##
## 不含 BBCode 标签时使用 [code]Label[/code]。
## [br][br]
## 含 BBCode 标签时自动切换到 [code]RichTextLabel[/code]，[code]RichTextLabel[/code]支持行内颜色。
## [br][br]
## 引擎通过 [method setup] 设置内容、颜色与对齐方式。
## [br][br]
## 本部件不认识游戏状态。

const FontGuard := preload("res://scripts/engine/font_guard.gd")

@onready var _label: Label = $Label
@onready var _rich: RichTextLabel = $RichTextLabel


## 设置这一行的文字、颜色和对齐方式。
## [br][br]
## [param align] 直接用 Godot 的 [enum HorizontalAlignment]：
## [code]HORIZONTAL_ALIGNMENT_LEFT[/code] 、 [code]HORIZONTAL_ALIGNMENT_CENTER[/code] 、 [code]HORIZONTAL_ALIGNMENT_RIGHT[/code]。
func setup(text: String, color: Color, align: HorizontalAlignment) -> void:
	FontGuard.check(self, text)
	var has_bbcode := text.contains("[")
	_label.visible = not has_bbcode
	_rich.visible = has_bbcode
	if has_bbcode:
		_rich.text = _with_align(text, align)
		_rich.add_theme_color_override("default_color", color)
	else:
		_label.text = text
		_label.horizontal_alignment = align
		_label.add_theme_color_override("font_color", color)


## RichTextLabel 没有 [code]horizontal_alignment[/code] 属性，改用 BBCode 标签包一层。
func _with_align(text: String, align: HorizontalAlignment) -> String:
	match align:
		HORIZONTAL_ALIGNMENT_CENTER:
			return "[center]%s[/center]" % text
		HORIZONTAL_ALIGNMENT_RIGHT:
			return "[right]%s[/right]" % text
		_:
			return text
