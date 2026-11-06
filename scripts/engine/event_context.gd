class_name EventContext
extends RefCounted
## EventContext, 事件的随身工具包
##
## 拿数据用 context（人、主角、状态），做事用 Era.*。
## player 是 CharacterBook.protagonist_id 的绑定（可为 null），不是按 id 查找。

var player: Character
var state: GameState

## 当前交互对象（对标 Emuera 的 TARGET）：直接读 [member Era.target]，
## 随 [method Era.set_target] 实时变化；口上执行期间等于说话人。
## [codeblock]
## if context.target != null:
##     Era.print(context.target.display_name)
## [/codeblock]
var target: Character:
	get:
		return Era.target


## 按 id 取角色；查无此人返回 null。
## [codeblock]
## var 女儿 := context.character(&"daughter")
## [/codeblock]
func character(id: StringName) -> Character:
	if state == null or state.character_book == null:
		return null
	return state.character_book.find(id)


## 所有装了指定组件类型的角色（线性扫描角色表，含子类组件）。
## [codeblock]
## for 队友 in context.characters_with(LifeComponent):
##     Era.print(队友.display_name)
## [/codeblock]
func characters_with(type: Script) -> Array[Character]:
	var result: Array[Character] = []
	if state == null or state.character_book == null:
		return result
	for entry in state.character_book.characters:
		if entry != null and entry.get_component(type) != null:
			result.append(entry)
	return result


## 对每个装了指定组件类型的角色调用 [param fn]（参数是该 [Character] 本身）。
## [codeblock]
## context.each(LifeComponent, func(谁): Era.print(谁.display_name))
## [/codeblock]
func each(type: Script, fn: Callable) -> void:
	for entry in characters_with(type):
		fn.call(entry)


## 免判空一行读：角色、组件、字段任一缺失（或字段不存在/值为 null）时返回 [param default]。
## [codeblock]
## var hp: int = int(context.get_value(&"daughter", LifeComponent, &"value", 0))
## [/codeblock]
func get_value(char_id: StringName, component_type: Script, field: StringName, default: Variant = null) -> Variant:
	var entry := character(char_id)
	if entry == null:
		return default
	var component := entry.get_component(component_type)
	if component == null:
		return default
	var value: Variant = component.get(field)
	if value == null:
		return default
	return value


## [param from_id] 对 [param to_id] 的称呼（定向称呼 → 默认称呼 → 真名）；任一缺失返回 "-"。
## [codeblock]
## context.name_between(&"daughter", &"player") # 女儿怎么称呼玩家
## [/codeblock]
func name_between(from_id: StringName, to_id: StringName) -> String:
	var from_character := character(from_id)
	var to_character := character(to_id)
	if from_character == null or to_character == null:
		return "-"
	return from_character.name_for(to_character)
