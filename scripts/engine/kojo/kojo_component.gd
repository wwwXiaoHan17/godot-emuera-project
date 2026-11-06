class_name KojoComponent
extends CharacterComponent
## KojoComponent，口上组件
##
## 持有这个角色的口上书（[KojoBook]，静态资源，不进存档）；
## 运行时状态（事件开关、使用次数）放在这里，会进存档。
## [br][br]
## 用法：
## [codeblock]
## var kojo := 女儿.get_component(KojoComponent) as KojoComponent
## kojo.set_event_enabled(&"morning", false)   # 关掉 morning 口上
## kojo.counter(&"act_cute")                    # 这个口上被调用过几次
## [/codeblock]

@export var book: KojoBook
## 事件开关：键不存在视为开启。
@export var enabled_events: Dictionary[StringName, bool] = {}
## 事件使用次数：Era.kojo 每次成功调用 +1。
@export var counters: Dictionary[StringName, int] = {}


func _init() -> void:
	display_name = "口上"


func is_event_enabled(event_name: StringName) -> bool:
	return enabled_events.get(event_name, true)


func set_event_enabled(event_name: StringName, enabled: bool) -> void:
	enabled_events[event_name] = enabled


func bump_counter(event_name: StringName) -> int:
	counters[event_name] = int(counters.get(event_name, 0)) + 1
	return counters[event_name]


func counter(event_name: StringName) -> int:
	return int(counters.get(event_name, 0))


## 书是静态资源：不进存档，但 spawn 角色时要一起复制过去。
func to_static_refs() -> Dictionary:
	return {"book": book}


func apply_static_refs(refs: Dictionary) -> void:
	book = refs.get("book", null) as KojoBook
