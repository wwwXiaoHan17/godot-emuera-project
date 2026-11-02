extends KojoBook
## 女儿的口上（普通 GDScript 函数）
##
## 和写普通剧情脚本一样：Era.print / if / pick_random；
## 固定上下文用 [code]context.speaker/player/state[/code]，临时数据用
## [code]context.extras[/code]；带按钮的口上直接 print_button + await Era.input()。
## 称呼统一走 [method KojoContext.speaker_name]（说话人→玩家）/
## [method KojoContext.listener_name]（玩家→说话人）：内建判空，不再手写 name_for。

func _build() -> void:
	register(&"morning", _morning)
	register(&"after_training", _after_training)
	register(&"act_cute", _act_cute)
	register(&"daily", _daily)
	register(&"caress", _caress)


func _morning(context: KojoContext) -> Variant:
	var speaker := context.speaker
	var relations := speaker.get_component(RelationComponent) as RelationComponent
	
	Era.print("早上好，%s。" % context.speaker_name())
	
	if relations != null and relations.relation_to(&"player") >= 30:
		Era.print("今天也要一起加油哦。")
	
	var random_line: String = ["天气真好。", "要一起出门吗？"].pick_random()
	Era.print(random_line)
	return null


func _after_training(context: KojoContext) -> Variant:
	var speaker := context.speaker
	var relations := speaker.get_component(RelationComponent) as RelationComponent
	
	Era.print("（%s 把我抱在怀里。）" % context.speaker_name())
	
	if relations != null and relations.relation_to(&"player") >= 50:
		Era.print("……嗯，最喜欢你了。")
	else:
		Era.print("……别碰我。")
		
	return null


## 带按钮的口上：打印选项 → await Era.input() → 返回选中的编号。
func _act_cute(context: KojoContext) -> Variant:
	Era.print("（%s 抬头看着你。）" % context.speaker_name())
	Era.print_button("摸摸头", 0)
	Era.print_button("抱抱", 1)
	Era.print_button("算了", 2)
	
	var picked: int = await Era.input()
	match picked:
		0:
			Era.print("……嘿嘿。", Era.Style.ACCENT)
		1:
			Era.print("（紧紧抱住。）", Era.Style.ACCENT)
		2:
			Era.print("……嗯。", Era.Style.DIM)
	return picked


## sync 口上：只打印、不等待（函数里没有 await）。
func _daily(context: KojoContext) -> Variant:
	Era.print("（%s 今天也很有精神。）" % context.speaker_name())
	
	return null


## 主角没绑定（context.player 为 null）时用不含对方称呼的安全文案；
## 非空分支的称呼走 speaker_name() / listener_name()（内建判空）。
func _caress(context: KojoContext) -> Variant:
	var speaker := context.speaker
	var player := context.player

	if player == null:
		var speaker_name: String = speaker.display_name if speaker != null and speaker.display_name != "" else "女儿"
		await Era.print_wait("%s感受着父亲的手掌抚摸着自己的脑袋。" % speaker_name)
	else:
		await Era.print_wait("{name_1}看着{name_2}，感受着父亲的手掌抚摸着自己的脑袋。".\
				format({"name_1": context.speaker_name(), "name_2": context.listener_name()}))
	await Era.print_wait("或许，明天就会有吃不完的零食？")
	await Era.print_wait("女儿不禁笑出了声")

	return null
