# 第 9 步完成记录（角色系统第 3 步：KOJO 基础 · 直接 GDScript 版）

> 日期：2026-10-21
> 设计：`docs/character-system-design.md`（v2，已按 review 改成直接 GDScript）
> 前一步：`docs/step-8-report.md`（角色系统第 2 步）

## 先记一次返工（重要）

最初 KOJO 做成了「节点树 + 条件字符串（Expression）+ KojoRunner」：`text()/when()/pick()`
搭树，Runner 解释。review 时你问：“为什么不直接用 GDScript？应该可以直接 Era.print 吧？”
——你说得对。那套东西多了一层自造语法，条件还受字符串白名单限制；删掉了，改成：

**`KojoBook` 只做“事件名 → GDScript 函数”注册，口上就是普通函数。**

## 最终实现

| 文件 | 作用 |
|---|---|
| `engine/kojo/kojo_book.gd` | 口上书基类：`register(事件名, Callable)` / `get_event(事件名)`；第一次取事件时调 `_build()` |
| `engine/kojo/kojo_component.gd` | 口上组件：持 `book`（静态资源）；`context_key = &"口上"` |
| `content/kojo/女儿_kojo.gd` | 女儿的口上：`_morning` / `_after_training` 两个普通函数 |
| `content/kojo/女儿_kojo.tres` | 口上书的资源实例（挂脚本） |
| `engine/era.gd` | `await Era.kojo(角色, 事件名, context)`：找组件 → 找函数 → 填 context → `await callable.call(context)` |

口上函数写法（和普通剧情脚本一样）：

```gdscript
extends KojoBook

func _build() -> void:
    register(&"早上", _morning)

func _morning(context: Dictionary) -> Variant:
    var speaker: Character = context["角色"]
    var player: Character = context["玩家"]
    Era.print("早上好，%s。" % speaker.name_for(player))
    if speaker.relation_to(&"玩家") >= 30:
        Era.print("今天也要一起加油哦。")
    Era.print(["天气真好。", "要一起出门吗？"].pick_random())
    return null
```

- 条件 = 原生 `if`；
- 随机 = `pick_random()`；
- 按钮（下一步）= `Era.print_button(...)` + `await Era.input()`；
- 称呼 = `speaker.name_for(player)`，没有 `%KEY%` 自动替换；
- `Era.kojo` 的 context：`角色` / `玩家` / `状态`，传参时还有 `对方` 和自定义键。

## 验收结果

- 14 个校验场景全部 `CHECK OK`（原 13 个 + 重写的 `check_kojo`）。
- `check_kojo` 现在直接走 `await Era.kojo(...)`，读屏幕文字行断言：
  - 好感 20 的“早上”：2 行（问候 + 随机）；
  - 好感 50：3 行（多一行条件台词）；
  - “调教后”：真/假分支正确；
  - 缺事件返回 null、不打印；没口上组件的角色不输出。
- `tests/demo_kojo.tscn` F6 可跑。
- 截图：
  - `experiment/shots/kojo_morning.png`：好感 30 的条件台词 + 随机行；
  - `experiment/shots/kojo_after.png`：好感 50 走真分支。

## 已知限制（第 4 步做）

- 口上按钮（打印选项 + `await Era.input()` 返回选择）还没在口上里实际用过；原生写法已经支持，只差示例和校验。
- 口上组件的“事件开关/使用次数/冷却”还没加；`sync`（不 await）就是函数里不写 await，还没有示例。
- 没有 `%KEY%` 自动替换、没有 YAML 导入（这是选直接 GDScript 的代价）。

## 文件清单

- 新增：`engine/kojo/kojo_book.gd`、`kojo_component.gd`、`content/kojo/女儿_kojo.gd`、`女儿_kojo.tres`、`tests/check_kojo.tscn/.gd`、`tests/demo_kojo.tscn`、`tests/demo_kojo.gd`、`tests/_demo_kojo_event.gd`、`docs/step-9-report.md`
- 修改：`engine/era.gd`、`engine/character/character_component.gd`、`engine/character/character.gd`、`content/characters/prototypes/女儿.tres`
- 删除：节点树那一套（`kojo_node/text/gap/if/pick/event/runner.gd`）
