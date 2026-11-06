class_name KojoBook
extends Resource
## KojoBook, 口上书（事件名 → GDScript 函数）
##
## 口上直接写普通 GDScript：函数里用 [code]Era.print[/code] / [code]if[/code] /
## [code]await Era.input()[/code] / [code]pick_random()[/code]，没有额外语法。
## 书只负责“事件名 → 函数”的注册，引擎按事件名找函数并把上下文传进去。
## [br][br]
## 内容脚本写法（[code]extends KojoBook[/code]，重写 [method _build]）：
## [codeblock]
## func _build() -> void:
##     register(&"morning", _morning)
##
## func _morning(context: KojoContext) -> Variant:
##     Era.print("早上好，%s。" % context.speaker.name_for(context.player))
##     var relations := context.speaker.get_component(RelationComponent) as RelationComponent
##     if relations != null and relations.relation_to(&"player") >= 30:
##         Era.print("今天也要一起加油哦。")
##     Era.print(["天气真好。", "要一起出门吗？"].pick_random())
##     return null
## [/codeblock]
## [br][br]
## 事件函数的 [param context] 由 [method Era.kojo] 填：
## 固定字段 [code]speaker / player / state[/code]，临时数据在 [code]extras[/code]。

var events: Dictionary[StringName, Callable] = {}

var _built := false


## 子类重写：用 [method register] 注册事件函数。
func _build() -> void:
	pass


## 使用[method register]注册一个口上事件，并将一个事件名绑定一个函数。
## [codeblock]
## func _build() -> void:
##     register(&"print_hello", _print_hello)
## 
## func _print_hello(context: KojoContext) -> Variant:
##     Era.print(context.speaker.name_for(context.player))
##     Era.print(context.player.display_name)
## [/codeblock]
func register(event_name: StringName, callable: Callable) -> void:
	events[event_name] = callable


## 取事件函数；第一次取时构建整本书。没注册返回无效 [Callable]。
func get_event(event_name: StringName) -> Callable:
	_ensure_built()
	return events.get(event_name, Callable())


func has_event(event_name: StringName) -> bool:
	_ensure_built()
	return events.has(event_name)


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	_build()
