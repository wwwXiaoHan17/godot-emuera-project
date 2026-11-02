extends Button
## ButtonRow, 一行按钮
##
## 显示一行可点的选项，文字自动带上 [code][编号] [/code] 前缀。
## [br][br]
## 交互只通过 [signal picked] 交给引擎；本部件不认识游戏状态。
## 按钮不抢键盘焦点，避免空格/回车被按钮吃掉（键盘选择由引擎统一处理）。

signal picked(id: int)

const FontGuard := preload("res://engine/font_guard.gd")

var _id: int = -1


func _ready() -> void:
	pressed.connect(_on_pressed)


## 设置按钮文字、编号和对齐方式。
## [param align] 直接用 Godot 的 [enum HorizontalAlignment]。
func setup(text: String, id: int, align: HorizontalAlignment) -> void:
	FontGuard.check(self, text)
	_id = id
	self.flat = true
	self.text = "[%d] %s" % [id, text]
	self.alignment = align


## 让按钮失效（还能看见，但不能再点，颜色变暗）。
func make_inert() -> void:
	disabled = true
	modulate = Color(1, 1, 1, 0.45)


func _on_pressed() -> void:
	picked.emit(_id)
