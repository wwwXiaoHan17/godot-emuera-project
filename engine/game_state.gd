class_name GameState
extends Resource
## GameState, 游戏状态
##
## 整局游戏的容器：角色表（[member character_book]）+ 全局进度（[member day]）
## + 全局标记（[member flags]）。角色自己的数据在 [Character] 的组件里；
## 事件里拿人用入参 context：
## [codeblock]
## var 女儿 := context.character(&"daughter")
## var 生命 := 女儿.get_component(LifeComponent) as LifeComponent
## 生命.hurt(10)
## [/codeblock]

## 多角色：角色表（id → Character）；所有角色数据都从这里取。
@export var character_book: CharacterBook = CharacterBook.new()

## 游戏天数；从 1 开始。随 [SaveManager] 存档往返。
@export var day: int = 1

## 全局非角色变量容器（对标 Emuera 的 FLAG）：键为英文变量名，值为整数，随存档往返。
## 角色侧标记用 [FlagTableComponent]，不放在这里。
## [codeblock]
## context.state.flags[&"gold"] = 100
## [/codeblock]
@export var flags: Dictionary[StringName, int] = {}
