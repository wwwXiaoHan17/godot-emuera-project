class_name EraEvent
extends RefCounted
## EraEvent, 事件内容的基类
## 
## 每个事件脚本 extends EraEvent，基本写法如下:
## [codeblock]
## func run(context: EventContext) -> GDScript：
##   return 下一个事件的脚本   # 引擎接着跑它
##   return null             # 如果返回null，则流程结束
## [/codeblock]
## 这里什么逻辑都不放，只规定形状。context 由引擎在执行前打包。

func run(_context: EventContext) -> GDScript:
	return null
