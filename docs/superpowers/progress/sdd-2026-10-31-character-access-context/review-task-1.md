=== Task 1 diff（before → after，git diff --no-index；event_context.gd 为新增文件）===
 .../check_kojo.gd"                                        |  6 ++++++
 .../check_kojo.gd.uid" => /dev/null                       |  1 -
 .../event_context.gd"                                     | 15 +++++++++++++++
 .../kojo_context.gd"                                      |  9 ++++-----
 .../kojo_context.gd.uid" => /dev/null                     |  1 -
 5 files changed, 25 insertions(+), 7 deletions(-)

=== Full diff (U10) ===
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-1/check_kojo.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-1/check_kojo.gd"
index bf81818..d6e0bf7 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-1/check_kojo.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-1/check_kojo.gd"
@@ -116,20 +116,26 @@ func _ready() -> void:
 		if probe_context.player != player:
 			failures.append("KojoContext.player 应为主角")
 		if probe_context.state != Era.state:
 			failures.append("KojoContext.state 应为 Era.state")
 		if probe_result != player:
 			failures.append("probe 应返回 extras[partner]，实际 %s" % str(probe_result))
 		if probe_context.extras.get("speaker") != "恶意 speaker":
 			failures.append("extras 里的同名键应原样保留")
 		if probe_context.extras.get("other") != 42:
 			failures.append("extras 额外键应可读取")
+		if not (probe_context is EventContext):
+			failures.append("KojoContext 应继承 EventContext")
+		if probe_context.character(&"player") != player:
+			failures.append("context.character 应能查到主角")
+		if probe_context.character(&"missing") != null:
+			failures.append("查无此人时 character() 应返回 null")
 
 	if failures.is_empty():
 		print("CHECK OK")
 		get_tree().quit(0)
 	else:
 		print("CHECK FAIL")
 		for failure in failures:
 			print("  - ", failure)
 		get_tree().quit(1)
 
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-1/check_kojo.gd.uid" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-1/check_kojo.gd.uid"
deleted file mode 100644
index 7a2142f..0000000
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-1/check_kojo.gd.uid"
+++ /dev/null
@@ -1 +0,0 @@
-uid://86qlp5rftm07
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-1/event_context.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-1/event_context.gd"
new file mode 100644
index 0000000..878ef8f
--- /dev/null
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-1/event_context.gd"
@@ -0,0 +1,15 @@
+class_name EventContext
+extends RefCounted
+## EventContext, 事件的随身工具包
+##
+## 拿数据用 context（人、主角、状态），做事用 Era.*。
+## player 是 CharacterBook.protagonist_id 的绑定（可为 null），不是按 id 查找。
+
+var player: Character
+var state: GameState
+
+
+func character(id: StringName) -> Character:
+	if state == null or state.character_book == null:
+		return null
+	return state.character_book.find(id)
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-1/kojo_context.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-1/kojo_context.gd"
index eea98d1..5237775 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-1/kojo_context.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-1/kojo_context.gd"
@@ -1,11 +1,10 @@
 class_name KojoContext
-extends RefCounted
+extends EventContext
 ## KojoContext, 口上固定上下文
 ##
-## 固定字段单独存放，调用者临时数据放在 [member extras]；extras 里的同名键
-## 不会覆盖固定字段。口上函数统一接收这个类型。
+## 自身固定字段是 speaker 与 extras（调用者临时数据放在 [member extras]，extras
+## 里的同名键不会覆盖固定字段）；player / state / character() 由 [EventContext]
+## 继承获得。口上函数统一接收这个类型。
 
 var speaker: Character
-var player: Character
-var state: GameState
 var extras: Dictionary = {}
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-1/kojo_context.gd.uid" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-1/kojo_context.gd.uid"
deleted file mode 100644
index bf8ee6c..0000000
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-1/kojo_context.gd.uid"
+++ /dev/null
@@ -1 +0,0 @@
-uid://3xj1lc82oiw4
