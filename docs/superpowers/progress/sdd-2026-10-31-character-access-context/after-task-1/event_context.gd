class_name EventContext
extends RefCounted
## EventContext, 事件的随身工具包
##
## 拿数据用 context（人、主角、状态），做事用 Era.*。
## player 是 CharacterBook.protagonist_id 的绑定（可为 null），不是按 id 查找。

var player: Character
var state: GameState


func character(id: StringName) -> Character:
	if state == null or state.character_book == null:
		return null
	return state.character_book.find(id)
