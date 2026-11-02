extends Node
## CheckEngineApi, 校验引擎 API 与上游能力对齐
##
## 覆盖：Era.state 只读收窄 + set_character_book、Era.target 与口上 speaker 语义、
## EventContext（target/characters_with/each/get_value/name_between）、
## KojoContext 称呼方向、GameState day/flags、CharacterBook 信号与存档字典、
## SaveManager JSON 存档（往返/版本门禁/宽容读取）、CharaCsvLoader 三样例、
## FlagTableComponent 行为与信号。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const KOJO_TRES := preload("res://content/kojo/女儿_kojo.tres")
const CHARA_DIR := "res://tests/fixtures/chara"


class TargetProbeBook extends KojoBook:
	## 测试替身：记录口上执行瞬间的 Era.target 与 context.target。
	var target_at_call: Character
	var context_target_at_call: Character
	var last_context: KojoContext


	func _build() -> void:
		register(&"probe", _probe)


	func _probe(context: KojoContext) -> Variant:
		last_context = context
		target_at_call = Era.target
		context_target_at_call = context.target
		return "probe-ok"


func _ready() -> void:
	var failures: Array[String] = []
	await get_tree().process_frame

	# ---------- 1) GameState：day/flags 默认值；Era.state 只读但字段可改 ----------
	var fresh_state := GameState.new()
	if fresh_state.day != 1:
		failures.append("GameState.day 默认应为 1，实际 %d" % fresh_state.day)
	fresh_state.flags[&"mood"] = 3
	if int(fresh_state.flags.get(&"mood", 0)) != 3:
		failures.append("GameState.flags 应可按 StringName 键读写")
	if Era.state == null or not (Era.state is GameState):
		failures.append("Era.state 应为 GameState")
	Era.state.day = 5
	if Era.state.day != 5:
		failures.append("Era.state 字段应可读写（只收窄整体替换）")
	Era.state.day = 1

	# ---------- 2) 组装角色表 + 角色样例 ----------
	var player := Character.new()
	player.id = &"player"
	player.display_name = "你"
	player.callname = "你"
	var daughter := Character.new()
	daughter.id = &"daughter"
	daughter.display_name = "阿丽丝"
	daughter.callname = "小丽丝"
	var daughter_life := LifeComponent.new()
	daughter_life.value = 90
	daughter.add_component(daughter_life)
	var daughter_relations := RelationComponent.new()
	daughter_relations.set_callname_for(&"player", "爸爸")
	daughter.add_component(daughter_relations)
	var probe_book := TargetProbeBook.new()
	var daughter_kojo := KojoComponent.new()
	daughter_kojo.book = probe_book
	daughter.add_component(daughter_kojo)
	var maid := Character.new()
	maid.id = &"maid"
	maid.display_name = "小梅"
	maid.callname = "梅姐"

	var book := CharacterBook.new()
	book.add(player)
	book.add(daughter)
	book.add(maid)
	Era.set_character_book(book)
	if Era.state.character_book != book:
		failures.append("Era.set_character_book 应替换 Era.state.character_book")
	if Era.character(&"daughter") != daughter:
		failures.append("Era.character 应能查到女儿")

	# ---------- 3) EventContext 新方法 ----------
	var context := EventContext.new()
	context.state = Era.state
	context.player = player
	if context.character(&"daughter") != daughter:
		failures.append("context.character(&“daughter”) 没找到")
	var with_life: Array[Character] = context.characters_with(LifeComponent)
	if with_life.size() != 1 or with_life[0] != daughter:
		failures.append("characters_with(LifeComponent) 应只有女儿，实际 %s" % _ids_text(with_life))
	var visited: Array[Character] = []
	context.each(LifeComponent, func(c: Character): visited.append(c))
	if visited.size() != 1 or visited[0] != daughter:
		failures.append("each(LifeComponent, fn) 应遍历到女儿")
	if int(context.get_value(&"daughter", LifeComponent, &"value", -1)) != 90:
		failures.append("get_value 应读到生命 90，实际 %s" % str(context.get_value(&"daughter", LifeComponent, &"value", -1)))
	if int(context.get_value(&"nobody", LifeComponent, &"value", -1)) != -1:
		failures.append("角色缺失时 get_value 应返回默认值")
	if int(context.get_value(&"player", LifeComponent, &"value", -1)) != -1:
		failures.append("组件缺失时 get_value 应返回默认值")
	if int(context.get_value(&"daughter", LifeComponent, &"no_field", -1)) != -1:
		failures.append("字段不存在时 get_value 应返回默认值")
	if context.name_between(&"daughter", &"player") != "爸爸":
		failures.append("name_between 女儿→玩家应为“爸爸”，实际 %s" % context.name_between(&"daughter", &"player"))
	if context.name_between(&"player", &"daughter") != "小丽丝":
		failures.append("name_between 玩家→女儿应回退默认称呼“小丽丝”，实际 %s" % context.name_between(&"player", &"daughter"))
	if context.name_between(&"daughter", &"nobody") != "-":
		failures.append("目标缺失时 name_between 应返回“-”")
	if context.name_between(&"nobody", &"daughter") != "-":
		failures.append("来源缺失时 name_between 应返回“-”")
	Era.set_target(daughter)
	if context.target != daughter:
		failures.append("EventContext.target 应实时读 Era.target")
	Era.set_target(null)
	if context.target != null:
		failures.append("Era.set_target(null) 后 context.target 应为 null")

	# ---------- 4) kojo：speaker 语义 + 执行期间 Era.target == speaker ----------
	Era.set_target(maid)
	var probe_result: Variant = await Era.kojo(daughter, &"probe", {"k": 1})
	if probe_result != "probe-ok":
		failures.append("kojo 探针应返回 probe-ok，实际 %s" % str(probe_result))
	if probe_book.target_at_call != daughter:
		failures.append("kojo 执行期间 Era.target 应等于 speaker")
	if probe_book.last_context == null or probe_book.last_context.speaker != daughter:
		failures.append("KojoContext.speaker 应为说话人（女儿）")
	if probe_book.context_target_at_call != daughter:
		failures.append("口上执行期间 KojoContext.target 应等于 speaker")
	if Era.target != maid:
		failures.append("kojo 结束后应恢复原 Era.target")
	if probe_book.last_context.speaker_name() != "爸爸":
		failures.append("speaker_name 应为女儿对玩家的称呼“爸爸”，实际 %s" % probe_book.last_context.speaker_name())
	if probe_book.last_context.listener_name() != "小丽丝":
		failures.append("listener_name 应为玩家对女儿的称呼“小丽丝”，实际 %s" % probe_book.last_context.listener_name())

	# ---------- 5) KojoContext：player 为 null 时称呼回退 "-" ----------
	var orphan_context := KojoContext.new()
	orphan_context.speaker = daughter
	if orphan_context.speaker_name() != "-":
		failures.append("player 为 null 时 speaker_name 应为“-”")
	if orphan_context.listener_name() != "-":
		failures.append("player 为 null 时 listener_name 应为“-”")

	# ---------- 6) CharacterBook：信号 / find_by_name / add_all / set_protagonist / remove ----------
	var sbook := CharacterBook.new()
	var added: Array[Character] = []
	var removed: Array[Character] = []
	var protagonist_events: Array = []
	sbook.character_added.connect(func(c: Character): added.append(c))
	sbook.character_removed.connect(func(c: Character): removed.append(c))
	sbook.protagonist_changed.connect(func(old_id: StringName, new_id: StringName): protagonist_events.append([old_id, new_id]))
	var char_a := Character.new()
	char_a.id = &"a"
	char_a.display_name = "甲"
	char_a.callname = "小甲"
	var char_a2 := Character.new()
	char_a2.id = &"a"
	char_a2.display_name = "甲替身"
	var char_b := Character.new()
	char_b.id = &"b"
	char_b.display_name = "乙"
	var char_c := Character.new()
	char_c.id = &"c"
	char_c.display_name = "丙"
	sbook.add(char_a)
	if added.size() != 1 or added[0] != char_a:
		failures.append("add 应发 character_added")
	sbook.add(char_a2)
	if removed.size() != 1 or removed[0] != char_a:
		failures.append("同 id 替换应发 character_removed（旧角色）")
	if added.size() != 2 or added[1] != char_a2:
		failures.append("同 id 替换应发 character_added（新角色）")
	if sbook.find(&"a") != char_a2 or sbook.all().size() != 1:
		failures.append("同 id 替换后 find 应返回新角色")
	if sbook.remove(&"c") != null:
		failures.append("remove 不存在的角色应返回 null")
	sbook.add_all([char_b, char_c])
	if sbook.all().size() != 3:
		failures.append("add_all 应加入两个角色，实际 %d 个" % sbook.all().size())
	if sbook.remove(&"c") != char_c or sbook.find(&"c") != null:
		failures.append("remove 应移除并返回角色")
	if removed.size() != 2 or removed[1] != char_c:
		failures.append("remove 应发 character_removed")
	if sbook.find_by_name("乙") != char_b:
		failures.append("find_by_name 应按真名查到乙")
	if sbook.find_by_name("小甲") != null:
		failures.append("被替换角色的旧称呼不应再查到")
	char_a2.callname = "大甲"
	if sbook.find_by_name("大甲") != char_a2:
		failures.append("find_by_name 应按称呼查到甲替身")
	if sbook.find_by_name("不存在") != null:
		failures.append("find_by_name 查无应返回 null")
	sbook.set_protagonist(&"b")
	if sbook.protagonist_id != &"b" or protagonist_events.size() != 1 or protagonist_events[0][1] != &"b":
		failures.append("set_protagonist 应改绑并发信号")
	sbook.set_protagonist(&"ghost")
	if sbook.protagonist_id != &"b" or protagonist_events.size() != 1:
		failures.append("set_protagonist 遇未知 id 应保持原值且不发信号")

	# ---------- 7) FlagTableComponent：行为 + 信号 ----------
	var flag_component := FlagTableComponent.new()
	if flag_component.get_display_name() != "标记":
		failures.append("FlagTableComponent 显示名应为“标记”，实际 %s" % flag_component.get_display_name())
	var flag_signals: Array[StringName] = []
	flag_component.component_changed.connect(func(what: StringName): flag_signals.append(what))
	flag_component.set_flag(&"trust", 10)
	if flag_component.get_flag(&"trust") != 10:
		failures.append("set/get_flag 基本读写不对")
	if flag_component.get_flag(&"missing") != 0 or flag_component.get_flag(&"missing", 7) != 7:
		failures.append("get_flag 缺省值不对")
	if flag_component.add_flag(&"trust", 5) != 15:
		failures.append("add_flag 应返回新值 15")
	flag_component.set_flag(&"trust", 15)
	if flag_signals.size() != 2:
		failures.append("值不变时 set_flag 不应重复发信号，实际 %d 次" % flag_signals.size())
	var bad_signals := 0
	for what in flag_signals:
		if what != &"values":
			bad_signals += 1
	if bad_signals != 0:
		failures.append("FlagTableComponent 信号应携带 &“values”")

	# ---------- 8) CharacterBook 存档字典：JSON 纯净往返 ----------
	var save_book := CharacterBook.new()
	var roundtrip := Character.new()
	roundtrip.id = &"roundtrip"
	roundtrip.display_name = "往返"
	roundtrip.callname = "往返酱"
	var rt_life := LifeComponent.new()
	rt_life.value = 33
	rt_life.max_value = 77
	roundtrip.add_component(rt_life)
	var rt_relations := RelationComponent.new()
	rt_relations.set_relation_to(&"player", 44)
	rt_relations.set_callname_for(&"player", "主人")
	roundtrip.add_component(rt_relations)
	var rt_kojo := KojoComponent.new()
	rt_kojo.book = KOJO_TRES
	rt_kojo.bump_counter(&"daily")
	rt_kojo.bump_counter(&"daily")
	rt_kojo.set_event_enabled(&"morning", false)
	roundtrip.add_component(rt_kojo)
	var rt_flags := FlagTableComponent.new()
	rt_flags.set_flag(&"mood", 7)
	roundtrip.add_component(rt_flags)
	save_book.add(roundtrip)
	save_book.protagonist_id = &"roundtrip"
	var save_dict := save_book.to_save_dict()
	var save_json := JSON.stringify(save_dict)
	if save_dict.characters.size() != 1:
		failures.append("to_save_dict.characters 应有 1 个角色")
	if save_json.contains("Resource#"):
		failures.append("to_save_dict 应 JSON 纯净（不应残留 Resource 引用）：%s" % save_json.substr(0, 120))
	var restored_book := CharacterBook.new()
	restored_book.apply_save_dict(JSON.parse_string(save_json))
	var restored := restored_book.find(&"roundtrip")
	if restored == null:
		failures.append("apply_save_dict 后应能找到 roundtrip")
	else:
		if restored.display_name != "往返" or restored.callname != "往返酱":
			failures.append("往返后名字/称呼不对：%s / %s" % [restored.display_name, restored.callname])
		var restored_life := restored.get_component(LifeComponent) as LifeComponent
		if restored_life == null or restored_life.value != 33 or restored_life.max_value != 77:
			failures.append("往返后生命字段不对：%s" % str({"value": restored_life.value if restored_life else null, "max": restored_life.max_value if restored_life else null}))
		var restored_relations := restored.get_component(RelationComponent) as RelationComponent
		if restored_relations == null or restored_relations.relation_to(&"player") != 44 or restored_relations.callname_for(&"player") != "主人":
			failures.append("往返后关系条目不对：relation=%s callname=%s" % [str(restored_relations.relation_to(&"player")) if restored_relations else "无组件", restored_relations.callname_for(&"player") if restored_relations else "无组件"])
		var restored_kojo := restored.get_component(KojoComponent) as KojoComponent
		if restored_kojo == null or restored_kojo.counter(&"daily") != 2 or restored_kojo.is_event_enabled(&"morning") != false:
			failures.append("往返后口上计数/开关不对")
		elif restored_kojo.book != KOJO_TRES:
			failures.append("往返后静态口上书引用应还原为同一资源")
		var restored_flags := restored.get_component(FlagTableComponent) as FlagTableComponent
		if restored_flags == null or restored_flags.get_flag(&"mood") != 7:
			failures.append("往返后标记表不对")
		if restored_book.protagonist_id != &"roundtrip":
			failures.append("往返后主角 id 不对：%s" % str(restored_book.protagonist_id))

	# ---------- 9) SaveManager：往返 / 版本门禁 / 宽容读取 ----------
	var slot_state := GameState.new()
	slot_state.day = 12
	slot_state.flags[&"gold"] = 3
	slot_state.character_book = save_book
	var save_result := SaveManager.save_to(91, slot_state)
	if not bool(save_result.get("ok", false)):
		failures.append("save_to 应成功：%s" % str(save_result))
	elif not FileAccess.file_exists("user://save_slot91.json"):
		failures.append("save_to 应写出 user://save_slot91.json")
	var load_result := SaveManager.load_from(91)
	if not bool(load_result.get("ok", false)):
		failures.append("load_from 往返应成功：%s" % str(load_result.get("error", "")))
	else:
		var loaded_state: GameState = load_result["state"]
		if loaded_state.day != 12:
			failures.append("往返后天数不对：%d" % loaded_state.day)
		if int(loaded_state.flags.get(&"gold", 0)) != 3:
			failures.append("往返后全局 flags 不对：%s" % str(loaded_state.flags))
		var loaded_life := loaded_state.character_book.find(&"roundtrip").get_component(LifeComponent) as LifeComponent
		if loaded_life == null or loaded_life.value != 33:
			failures.append("往返后角色生命不对")
		if loaded_state.character_book.protagonist_id != &"roundtrip":
			failures.append("往返后主角不对")
	# 版本门禁：旧版本与缺版本号都拒载
	_write_slot(92, JSON.stringify({"save_version": 0, "min_supported": 1, "day": 3}))
	var gate_result := SaveManager.load_from(92)
	if bool(gate_result.get("ok", true)) or String(gate_result.get("error", "")).is_empty():
		failures.append("版本过旧应拒载并返回错误文案，实际 %s" % str(gate_result))
	_write_slot(92, JSON.stringify({"min_supported": 1, "day": 3}))
	gate_result = SaveManager.load_from(92)
	if bool(gate_result.get("ok", true)):
		failures.append("缺 save_version 应视为过旧拒载")
	var missing_result := SaveManager.load_from(95)
	if bool(missing_result.get("ok", true)) or String(missing_result.get("error", "")).is_empty():
		failures.append("读不存在的槽位应返回 ok=false")
	# 宽容读取：未知键汇总警告、未知组件跳过、坏字段忽略、缺失补默认
	var tolerant_payload := {
		"save_version": 1,
		"min_supported": 1,
		"mystery": true,
		"day": 7,
		"flags": {"a": 2},
		"protagonist_id": "t1",
		"book": {"characters": [
			{"id": "t1", "display_name": "T", "callname": "t", "components": {
				"NoSuchComponent": {"x": 1},
				"LifeComponent": {"value": 55, "bogus_field": "zz"},
			}},
		], "protagonist_id": "t1"},
	}
	_write_slot(93, JSON.stringify(tolerant_payload))
	var tolerant_result := SaveManager.load_from(93)
	if not bool(tolerant_result.get("ok", false)):
		failures.append("宽容读取应成功：%s" % str(tolerant_result.get("error", "")))
	else:
		var warnings: Array = tolerant_result.get("warnings", [])
		var joined := " | ".join(warnings)
		if not joined.contains("NoSuchComponent") or not joined.contains("mystery"):
			failures.append("未知组件与未知键都应进警告汇总：%s" % joined)
		var t_state: GameState = tolerant_result["state"]
		if t_state.day != 7 or int(t_state.flags.get(&"a", 0)) != 2:
			failures.append("宽容读取的天数/flags 不对")
		var t_char := t_state.character_book.find(&"t1")
		var t_life := t_char.get_component(LifeComponent) as LifeComponent if t_char != null else null
		if t_life == null or t_life.value != 55:
			failures.append("JSON 整数被解析为 float 后仍应还原为 55，实际 %s" % str(t_life.value if t_life else "无组件"))
	_write_slot(94, JSON.stringify({"save_version": 1, "min_supported": 1}))
	var minimal_result := SaveManager.load_from(94)
	if not bool(minimal_result.get("ok", false)):
		failures.append("最小存档应宽容读取成功")
	else:
		var m_state: GameState = minimal_result["state"]
		if m_state.day != 1 or not m_state.flags.is_empty() or m_state.character_book.all().size() != 0:
			failures.append("最小存档应补默认 day=1 / 空 flags / 空角色表")
		if (minimal_result.get("warnings", []) as Array).is_empty():
			failures.append("缺 book 应产生宽容警告")

	# ---------- 10) CharaCsvLoader：三个样例 ----------
	var chara_list: Array[Character] = CharaCsvLoader.load_dir(CHARA_DIR)
	if chara_list.size() != 3:
		failures.append("load_dir 应加载 3 个角色（含子目录），实际 %d：%s" % [chara_list.size(), _ids_text(chara_list)])
	var csv_daughter := _find_char(chara_list, &"daughter")
	var csv_maid := _find_char(chara_list, &"maid")
	var csv_guard := _find_char(chara_list, &"guard")
	if csv_daughter == null or csv_maid == null or csv_guard == null:
		failures.append("load_dir 应包含 daughter / maid / guard")
	else:
		if csv_daughter.display_name != "阿丽丝" or csv_daughter.callname != "小丽丝":
			failures.append("CSV 女儿名字/称呼不对：%s / %s" % [csv_daughter.display_name, csv_daughter.callname])
		var csv_life := csv_daughter.get_component(LifeComponent) as LifeComponent
		if csv_life == null or csv_life.value != 80 or csv_life.max_value != 120:
			failures.append("CSV 女儿生命字段不对")
		var csv_flags := csv_daughter.get_component(FlagTableComponent) as FlagTableComponent
		if csv_flags == null or csv_flags.get_flag(&"cute") != 5 or csv_flags.get_flag(&"anger") != 2:
			failures.append("CSV 女儿 flag 行不对")
		elif csv_flags.get_flag(&"unset") != 0:
			failures.append("CSV flag 未设键应返回 0")
		var csv_stamina := csv_maid.get_component(StaminaComponent) as StaminaComponent
		if csv_maid.display_name != "小梅" or csv_stamina == null or csv_stamina.value != 70:
			failures.append("CSV 女仆样例不对（未知行不应中断加载）")
		var csv_energy := csv_guard.get_component(EnergyComponent) as EnergyComponent
		if csv_energy == null or csv_energy.value != 55 or csv_energy.max_value != 90:
			failures.append("CSV 门卫同组件多行应合并（value=55 且 max_value=90）")
	var empty_list: Array[Character] = CharaCsvLoader.load_dir("res://tests/fixtures/chara_missing")
	if not empty_list.is_empty():
		failures.append("不存在的目录应返回空数组")

	# ---------- 收尾 ----------
	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _write_slot(slot: int, text: String) -> void:
	var file := FileAccess.open("user://save_slot%d.json" % slot, FileAccess.WRITE)
	if file != null:
		file.store_string(text)
		file.close()


func _ids_text(chara_list: Array[Character]) -> String:
	var ids: Array[String] = []
	for entry in chara_list:
		if entry != null:
			ids.append(String(entry.id))
	return ", ".join(ids)


func _find_char(chara_list: Array[Character], id: StringName) -> Character:
	for entry in chara_list:
		if entry != null and entry.id == id:
			return entry
	return null
