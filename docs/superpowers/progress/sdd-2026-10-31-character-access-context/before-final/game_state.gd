class_name GameState
extends Resource
## GameState, 游戏状态
##
## 现在只装“整局游戏的容器”：角色表（[CharacterBook]）。
## 角色自己的数据在 [Character] 的组件里：
## [codeblock]
## var 女儿 := Era.state.character_book.find(&"daughter")
## var 生命 := 女儿.get_component(LifeComponent) as LifeComponent
## 生命.hurt(10)
## [/codeblock]

## 多角色：角色表（id → Character）；所有角色数据都从这里取。
@export var character_book: CharacterBook = CharacterBook.new()
