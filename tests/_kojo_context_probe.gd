extends KojoBook
## 测试替身：记录收到的 KojoContext，返回 extras["partner"]。

var last_context: KojoContext


func _build() -> void:
	register(&"probe", _probe)


func _probe(context: KojoContext) -> Variant:
	last_context = context
	return context.extras.get("partner", null)
