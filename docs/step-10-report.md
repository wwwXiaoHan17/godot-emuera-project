# 第 10 步完成记录（角色系统第 4 步：口上按钮 / sync / 开关计数）

> 日期：2026-10-21
> 设计：`docs/character-system-design.md`（v2）
> 前一步：`docs/step-9-report.md`（角色系统第 3 步 · 直接 GDScript 版 KOJO）

## 这一步做完了什么

**口上组件 `KojoComponent` 增加运行时状态**

```gdscript
@export var enabled_events: Dictionary[StringName, bool] = {}   # 事件开关（不存在 = 开）
@export var counters: Dictionary[StringName, int] = {}          # 使用次数

func is_event_enabled(name) -> bool
func set_event_enabled(name, enabled) -> void
func bump_counter(name) -> int
func counter(name) -> int
```

- 开关和计数是运行时状态，会进存档（`to_fields/apply_fields` 已经覆盖）；
- `enabled_events/counters` 不在 `CharacterComponent.FIELD_WHITELIST` 之外（Dictionary 本来就在白名单里），不用额外处理。

**`Era.kojo`**

- 先查事件是否存在 → 再查开关（关掉就 warning + 返回 null，不打印、不计数）→ 计数 +1；
- context 里多放一个 `"口上"`（`KojoComponent`），口上函数可以读自己的开关/次数。

**口上内容**

- `撒娇`：普通函数里 `Era.print` + `Era.print_button` + `await Era.input()`，返回选中的编号；
- `每日开场`：函数里**没有 await**，就是 sync 口上（只打印不等待）。

**演示 / 校验**

- `tests/demo_kojo.tscn` 更新：7 个菜单项（早上 / 调教后 / 撒娇（带选项）/ 每日开场（sync）/ 开关每日开场 / 好感+10 / 退出），并显示各口上调用次数。
- 新增 `tests/check_kojo_buttons.tscn/.gd` + `tests/_drive_kojo_buttons.gd`：
  - 带按钮口上打印 1 行文字 + 3 个按钮；选“抱抱”后 `Era.kojo` 返回 1，屏幕出现“（紧紧抱住。）”；
  - 撒娇计数 = 1；关掉后调用返回 null、不打印、不计数。
- `check_kojo` 补充：sync 口上只打印 + “早上”调用两次计数为 2 + 每日开场计数 1。

## 验收结果

- 15 个校验场景全部 `CHECK OK`（原 14 个 + `check_kojo_buttons`）。
- `tests/demo_kojo.tscn` headless 无报错，F6 可跑。
- 截图：
  - `experiment/shots/kojo_buttons.png`：带选项的口上；
  - `experiment/shots/kojo_buttons_result.png`：选“抱抱”后的结果 + `Era.kojo` 返回值 1。

## 口上按钮/sync 的写法（最终形态）

```gdscript
func _act_cute(context: Dictionary) -> Variant:
    Era.print("……")
    Era.print_button("摸摸头", 0)
    Era.print_button("抱抱", 1)
    var picked: int = await Era.input()
    return picked                      # 这个值会从 await Era.kojo(...) 返回
```

```gdscript
func _daily(context: Dictionary) -> Variant:
    Era.print("……")                    # 没有 await = sync，只打印
    return null
```

## 已知限制

- 计数只是“调用次数”，没有内建冷却/上限；“用了几次就不再说”由内容自己判断 `context["口上"].counter(...)`。
- 没有“默认口上书”回退：角色必须有 `KojoComponent` 且 `book` 非空。
- 没有 `%KEY%` 自动替换 / YAML 导入（选直接 GDScript 的代价）。

## 文件清单

- 修改：`engine/kojo/kojo_component.gd`、`engine/era.gd`、`content/kojo/女儿_kojo.gd`、`tests/_demo_kojo_event.gd`、`tests/check_kojo.gd`
- 新增：`tests/check_kojo_buttons.tscn/.gd`、`tests/_drive_kojo_buttons.gd`、`docs/step-10-report.md`
