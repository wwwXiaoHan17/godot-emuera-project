extends Label
## RuleRow, 一行分割线
##
## 只做最简单的事：把 [param char] 重复 [param count] 次，占满整行。
## 重复次数由引擎按当前文字区宽度算好传进来，本部件不自己猜宽度。
## [br][br]
## 带标题或更花哨的分割线，由内容脚本自己拼字符串用 [code]Era.print()[/code] 输出；
## 需要多次复用时，自己写一个辅助函数即可，不需要麻烦 RuleRow。

## 设置分割线。
## [param char] 用来重复的符号，例如 [code]╍[/code] 或 [code]■[/code]。
## [param count] 引擎按文字区宽度算好的总字符数。
func setup(char: String, count: int = 144) -> void:
	text = char.repeat(count)
