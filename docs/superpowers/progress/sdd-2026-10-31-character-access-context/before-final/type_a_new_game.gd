extends EraEvent

func run() -> GDScript:
	
	Era.clear()
	Era.print_rule()
	await Era.print_wait("叮咚~你家的门铃忽然间响起")
	await Era.print_wait("你感到疑惑。因为你不记得这个时间还有谁会来拜访自己")
	await Era.print_wait("你走向门，通过猫眼观察外面")
	await Era.print_wait("门外是一个较小的女孩，看上去只有8，9岁的样子")
	await Era.print_wait("你想起来了，她是你的--")
	
	Era.print_button("亲生女儿", 0)
	Era.print_button("继女", 1)
	
	match await Era.input():
		0:
			await Era.print_wait("是的，她是的你的女儿")
			await Era.print_wait("由于你和你的前妻分手了")
			await Era.print_wait("女儿曾在她那居住了一段时间")
			await Era.print_wait("现在她的经济不太景气")
			await Era.print_wait("不愿意承担抚养费的前妻决定将女儿甩给你")
			await Era.print_wait("多么无情")
		1:
			await Era.print_wait("是的，她是你的继女")
			await Era.print_wait("由于你和你的前妻分手了")
			await Era.print_wait("但是你的前妻由于病情原因去世了")
			await Era.print_wait("无亲无故的继女只好找上你了")
			await Era.print_wait("多么可怜")
			
	await Era.print_wait("好的，我当然知道你在想什么~")
	await Era.print_wait("这么可爱的女孩，你可得好生疼爱一番呢")
	await Era.print_wait("当然~是哪一方面的疼爱呢？")
	await Era.print_wait("🎶我就不知道了咯🎶")
	
	Era.print_gap()
	await Era.print_wait("咳咳，闲话就说到这里")
	await Era.print_wait("还请享受接下来的时光吧~")
	
	return load("res://content/events/day_start.gd")
