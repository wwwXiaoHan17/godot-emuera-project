class_name CharacterSetup
extends RefCounted
## CharacterSetup, 装配助手
##
## 主流程里统一用 [method ensure] 准备角色：角色表里没有就从 `.tres` 原型里
## spawn 出来，保证任何一屏都能按 id 拿到角色。

const PLAYER_PROTO := preload("res://scripts/content/characters/prototypes/玩家.tres")
const DAUGHTER_PROTO := preload("res://scripts/content/characters/prototypes/女儿.tres")
const MAID_PROTO := preload("res://scripts/content/characters/prototypes/女仆.tres")


## 确保角色表里有玩家/女儿/女仆；返回同一个角色表（新建时由调用方写回 Era.state）。
## 已存在的书不碰 protagonist_id：主角换绑由内容层决定，装配助手不把默认值打回去。
static func ensure(book: CharacterBook) -> CharacterBook:
	var target := book if book != null else CharacterBook.new()
	if book == null:
		# 只有新建的书才设默认主角（CharacterBook.new() 本身也默认 player，这里显式声明意图）。
		target.protagonist_id = &"player"
	if target.find(&"player") == null:
		target.add(PLAYER_PROTO.spawn(&"player"))
	if target.find(&"daughter") == null:
		target.add(DAUGHTER_PROTO.spawn(&"daughter"))
	if target.find(&"maid") == null:
		target.add(MAID_PROTO.spawn(&"maid"))
	return target
