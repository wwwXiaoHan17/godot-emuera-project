extends EraEvent
## 校验用事件：跑一次带按钮的口上，把返回值写进状态。

const PLAYER_PROTO := preload("res://scripts/content/characters/prototypes/玩家.tres")
const DAUGHTER_PROTO := preload("res://scripts/content/characters/prototypes/女儿.tres")


func run(context: EventContext) -> GDScript:
	var player := PLAYER_PROTO.spawn(&"player")
	var daughter := DAUGHTER_PROTO.spawn(&"daughter")
	var book := CharacterBook.new()
	book.add(player)
	book.add(daughter)
	book.protagonist_id = &"player"
	Era.set_character_book(book)

	Era.clear()
	var picked: int = await Era.kojo(daughter, &"act_cute", {"partner": player})
	Era.print("picked=%d" % picked)
	return null
