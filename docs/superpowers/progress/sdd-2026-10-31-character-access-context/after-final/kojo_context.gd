class_name KojoContext
extends EventContext
## KojoContext, 口上固定上下文
##
## 自身固定字段是 speaker 与 extras（调用者临时数据放在 [member extras]，extras
## 里的同名键不会覆盖固定字段）；player / state / character() 由 [EventContext]
## 继承获得。口上函数统一接收这个类型。

var speaker: Character
var extras: Dictionary = {}
