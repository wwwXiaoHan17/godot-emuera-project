extends EraEvent
## 校验用事件：print_wait = 打印 + 等键。

func run(context: EventContext) -> GDScript:
	await Era.print_wait("等待行", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	Era.print("按键后继续。")
	await Era.wait_key()
	return null
