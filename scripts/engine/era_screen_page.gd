class_name EraScreenPage
extends Control
## EraScreenPage, 挂载式页面基类
##
## 特殊页面（角色创建这类整块画面）继承它，做成普通的 [code].tscn[/code]；
## 引擎用 [code]Era.show_screen()[/code] 把它插进壳的页面槽，不换场景。
## [br][br]
## 页面做好后发 [signal finished]，把数据交回内容脚本：
## [codeblock]
## finished.emit({"display_name": "小灯", "age": 18})
## [/codeblock]

## 页面完成时发出；[param result] 由页面决定（通常是 Dictionary）。
signal finished(result)


## 入树前由 [method Era.show_screen] 调用；页面只使用这里传入的数据。
func configure(_data: Dictionary) -> void:
	pass
