extends Node
## CheckContentFixes, 内容层修复的校验（Phase A）
##
## 覆盖四件事：
## 1. 女儿口上 _caress 在主角为 null 时不崩、不引用对方称呼，且零食行是“有吃不完”；
## 2. 父亲原型没有手存的 sexy_level（与全新组件的默认值一致），且 is_prototype = true；
## 3. CharacterSetup.ensure 不改已有书的 protagonist_id（新建书才设默认）；
## 4. 天赋清单单源：组件里是唯一清单（5 个、顺序固定），天赋选择事件的编号与它一致。
## 5. Phase B：day_start 的天数标题读 Era.state.day（不硬编码“第 1 天”）。
## 6. Phase B：装配收敛——new_game 经 Era.set_character_book 装配且年龄走 set_value，
##    其余 4 个事件不再出现 Era.state.character_book 直写或 ensure 装配行。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。
##
## caress 口上里有等键的 print_wait：_ready 直接 await Era.kojo，由逐帧泵键的
## _pump_tick 推进；若口上中途崩溃（主角为 null 的旧 bug），await 永远不回来，
## 泵键帧数超限后由 _pump_tick 判 FAIL 收尾。
##
## 注意：引擎常量一律显式类型成 Script 再调 Object 方法；本 Godot 构建
## （4.8-dev7）对静态类型为 GDScript 的值调 has_method 等会编译失败且无报错输出。

const DAUGHTER_PROTO := preload("res://content/characters/prototypes/女儿.tres")
const FATHER_PROTO := preload("res://content/characters/prototypes/父亲.tres")
const TALENT_SELECT_SCRIPT: Script = preload("res://content/events/talent_select.gd")
const DAY_START_SCRIPT := preload("res://content/events/day_start.gd")
const NEW_GAME_PATH := "res://content/events/new_game.gd"
const DAY_START_PATH := "res://content/events/day_start.gd"
const PANEL_PATH := "res://content/events/character_panel.gd"
const SHOW_PATH := "res://content/events/show_component.gd"
const TALENT_PATH := "res://content/events/talent_select.gd"

## 泵键帧数上限：caress 有 3 个 print_wait，120 帧远远够；超了按“崩溃/卡住”算。
const CARESS_MAX_FRAMES := 120

var _failures: Array[String] = []
var _caress_finished := false
var _pump_frames := 0
var _finished := false


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	# 1) caress：主角为 null（protagonist_id 指向不存在的角色）
	var book := CharacterBook.new()
	book.protagonist_id = &"nobody"
	var daughter := DAUGHTER_PROTO.spawn(&"daughter")
	book.add(daughter)
	Era.set_character_book(book)
	Era.clear()

	get_tree().process_frame.connect(_pump_tick)
	await Era.kojo(daughter, &"caress")
	_caress_finished = true
	_disconnect_pump()

	var kojo_component := daughter.get_component(KojoComponent) as KojoComponent
	if Era.row_count() != 3:
		_failures.append("caress 应打印 3 行（player 为 null 时崩溃会一行都没有），实际 %d" % Era.row_count())
	elif kojo_component == null or kojo_component.counter(&"caress") != 1:
		_failures.append("caress 口上应被调用 1 次")
	else:
		var texts := _row_texts()
		if texts.size() == 3:
			if texts[0].contains("-"):
				_failures.append("player 为 null 时第一行不该出现称呼占位“-”，实际：%s" % texts[0])
			if not texts[1].contains("有吃不完"):
				_failures.append("零食行应为“有吃不完”，实际：%s" % texts[1])

	# 2) 父亲原型：没有手存 sexy_level，is_prototype = true
	var father := FATHER_PROTO as Character
	if not father.is_prototype:
		_failures.append("父亲原型应 is_prototype = true（对齐玩家/女儿/女仆）")
	var sexy := father.get_component(SexyComponent) as SexyComponent
	if sexy == null:
		_failures.append("父亲原型应保留 SexyComponent")
	else:
		var fresh := SexyComponent.new()
		if sexy.sexy_level != fresh.sexy_level:
			_failures.append("父亲原型的 sexy_level 是手存覆盖（%d），应与默认值 %d 一致" % [sexy.sexy_level, fresh.sexy_level])

	# 3) ensure：已存在的书不碰 protagonist_id；新建书才设默认
	var rebound := CharacterBook.new()
	rebound.protagonist_id = &"daughter"  # 模拟主角换绑
	var returned := CharacterSetup.ensure(rebound)
	if returned != rebound:
		_failures.append("ensure 应返回同一本书")
	if rebound.protagonist_id != &"daughter":
		_failures.append("ensure 不该把已有书的 protagonist_id 打回 player，实际 %s" % str(rebound.protagonist_id))
	var again := CharacterSetup.ensure(rebound)
	if again.protagonist_id != &"daughter":
		_failures.append("ensure 二次调用仍不该改 protagonist_id，实际 %s" % str(again.protagonist_id))
	for id in [&"player", &"daughter", &"maid"]:
		if rebound.find(id) == null:
			_failures.append("ensure 后角色表里应有 %s" % str(id))
	var fresh_book := CharacterSetup.ensure(null)
	if fresh_book.protagonist_id != &"player":
		_failures.append("新建书的 protagonist_id 应为 player，实际 %s" % str(fresh_book.protagonist_id))

	# 4) 天赋清单单源：组件是唯一清单；talent_select 的编号必须与组件清单一致
	var selector: Variant = TALENT_SELECT_SCRIPT.new()
	var resources: Array = TalentListComponent.TALENT_RESOURCES
	var expected: Array[StringName] = [&"ignorant", &"childish", &"precocious", &"sexually_repressed", &"weak_bladder"]
	if resources.size() != 5:
		_failures.append("TalentListComponent.TALENT_RESOURCES 应有 5 个天赋，实际 %d" % resources.size())
	else:
		for i in expected.size():
			var data := resources[i] as TalentData
			if data == null or data.talent_name != expected[i]:
				_failures.append("清单第 %d 个天赋应是 %s，实际 %s" % [i + 1, str(expected[i]), str(data.talent_name if data != null else "空")])
		for i in expected.size():
			var got_id: int = selector._id_of(expected[i])
			if got_id != i + 1:
				_failures.append("talent_select 的编号与组件清单不一致：%s 应是 %d，实际 %d" % [str(expected[i]), i + 1, got_id])
		# 严格检查（本构建可能没有这个反射 API，没有就跳过）：talent_select 不再自带 TALENTS 常量
		if TALENT_SELECT_SCRIPT.has_method("has_script_constant"):
			if bool(TALENT_SELECT_SCRIPT.call("has_script_constant", "TALENTS")):
				_failures.append("talent_select.gd 不该再自带 TALENTS 清单（应引用 TalentListComponent.TALENT_RESOURCES）")

	# 5) Phase B：day_start 的天数标题读 Era.state.day（事件只读，不推进天数）
	Era.set_character_book(CharacterSetup.ensure(null))
	Era.state.day = 3
	Era.clear()
	Era.start(DAY_START_SCRIPT)
	var walked := 0
	while Era.row_count() < 13 and walked < 120:
		await get_tree().process_frame
		walked += 1
	var day_texts := _row_texts()
	if not day_texts.has("第 3 天"):
		_failures.append("day_start 应按 Era.state.day 显示“第 3 天”，实际 %s" % str(day_texts))

	# 6) Phase B：装配收敛到 new_game 一处；其余事件不再碰 Era.state.character_book
	var new_game_source := FileAccess.get_file_as_string(NEW_GAME_PATH)
	if not new_game_source.contains("Era.set_character_book(CharacterSetup.ensure("):
		_failures.append("new_game 应改为 Era.set_character_book(CharacterSetup.ensure(...)) 装配")
	if new_game_source.contains("age_component.value = age"):
		_failures.append("new_game 的年龄写回应走 age_component.set_value(age)，不该裸赋值")
	for source_path in [DAY_START_PATH, PANEL_PATH, SHOW_PATH, TALENT_PATH]:
		var event_source := FileAccess.get_file_as_string(source_path)
		if event_source.contains("Era.state.character_book"):
			_failures.append("%s 不该再出现 Era.state.character_book（装配归 new_game，取人用 context）" % source_path)
		if event_source.contains("CharacterSetup.ensure"):
			_failures.append("%s 不该再自带 ensure 装配行（信任 new_game 已装配）" % source_path)

	_finish()


## 逐帧泵键：口上没跑完就按一次键；跑完或超限就断开自己。
func _pump_tick() -> void:
	if _finished or _caress_finished:
		_disconnect_pump()
		return
	_pump_frames += 1
	if _pump_frames > CARESS_MAX_FRAMES:
		_failures.append("caress 口上没跑完（player 为 null 时崩溃或卡住）")
		_disconnect_pump()
		_finish()
		return
	Era._resolve_key()


func _disconnect_pump() -> void:
	if get_tree().process_frame.is_connected(_pump_tick):
		get_tree().process_frame.disconnect(_pump_tick)


## 统一收尾：只执行一次。
func _finish() -> void:
	if _finished:
		return
	_finished = true
	if _failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in _failures:
			print("  - ", failure)
		get_tree().quit(1)


## 把文字行（Label / RichTextLabel）收成字符串；按钮/格子行跳过。
func _row_texts() -> Array[String]:
	var texts: Array[String] = []
	var rows := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Scroll/Rows")
	if rows == null:
		return texts
	for row in rows.get_children():
		var label := row.get_node_or_null("Label") as Label
		if label != null and label.visible:
			texts.append(label.text)
			continue
		var rich := row.get_node_or_null("RichTextLabel") as RichTextLabel
		if rich != null and rich.visible:
			texts.append(rich.text)
	return texts
