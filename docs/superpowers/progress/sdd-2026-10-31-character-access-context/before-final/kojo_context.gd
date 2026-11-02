class_name KojoContext
extends RefCounted
## KojoContext, 口上固定上下文
##
## 固定字段单独存放，调用者临时数据放在 [member extras]；extras 里的同名键
## 不会覆盖固定字段。口上函数统一接收这个类型。

var speaker: Character
var player: Character
var state: GameState
var extras: Dictionary = {}
