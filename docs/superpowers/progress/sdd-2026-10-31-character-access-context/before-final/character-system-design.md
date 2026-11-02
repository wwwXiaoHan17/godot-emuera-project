# 角色系统设计（定稿）

> 日期：2026-10-26
> 状态：已按 `docs/superpowers/specs/2026-10-25-engine-boundaries-design.md` 落地
> 历史版本：旧的组件/关系/KOJO 讨论保留在 `docs/step-*.md` 里；本文件只写当前接口。

## 1. 目标

角色由**可选的 Resource 组件**组合，而不是一个字段越来越多的 Godot Node。
内容仍然只写普通 GDScript：`Era.print`、`await Era.input()`、`if`、`return 下一个事件`。

## 2. Character：只保留身份与组件宿主

```gdscript
class_name Character extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export var callname: String = ""
@export var components: Array[CharacterComponent] = []
@export var is_prototype := false
```

- `id`：程序身份（`player / daughter / maid / father`）。
- `display_name`：真名；`callname`：默认称呼。
- 不再有 `age`、`relations` 或关系读写方法。
- 组件由 `components` 数组持有；`spawn()` 产生独立副本。

## 3. 组件身份与显示名

- **身份 = 脚本类型**：`CharacterComponent.component_type()` 默认返回自身脚本。
- `Character.get_component(type: Script)` 按类型查找，支持继承（`LifeComponent` 的查找能找到 `SlimeLifeComponent`）。
- `add_component()` 按 `component_type()` 替换同类组件；同显示名的无关组件不会互相覆盖。
- `remove_component(type: Script)` 删除；组件查找只按脚本类型，不再有按键名或旧身份键的 API。
- `display_name: String` 只用于界面显示，空时回退脚本类名；不参与查找/替换/程序 ID。
- 基类型示例：`LifeComponent.component_type()` 返回 `LifeComponent`，子类继承该身份。

## 4. 组件清单

| 组件 | 字段 / 方法 | 显示名 | 说明 |
|---|---|---|---|
| `LifeComponent` | `value / max_value`、`hurt/heal/ratio` | 生命 | 基础类型，子类仍按 Life 查找 |
| `StaminaComponent` | `value / max_value`、`spend/rest` | 体力 | 示例模板 |
| `EnergyComponent` | `value / max_value`、`spend/rest` | 精力 | 示例模板 |
| `SexyComponent` | `sexy_value / sexy_level`、`increased/decreased` | 性欲 | 等级阈值仍在按游戏规则完善 |
| `AgeComponent` | `value / died_age`、`increase/decrease`、信号 `died` | 年龄 | 可选；越过 `died_age` 时发一次 `died` |
| `TalentListComponent` | `selected: Array[StringName]`、`text()` | 天赋 | 存已选天赋 ID |
| `RelationComponent` | 见 §5 | 关系 | 可选；玩家/女儿/女仆安装 |
| `KojoComponent` | `book`、`enabled_events`、`counters` | 口上 | 口上书的运行时状态 |

组件字段和程序 ID 用英文；显示名、玩家可见文字用中文。

## 5. 关系与称呼

`RelationComponent` 同时保存数据和规则：

```gdscript
signal relation_changed(target: StringName, value: int)

@export var relations: Array[RelationEntry] = []
@export var min_value: int = 0
@export var max_value: int = 100

func relation_to(other: StringName) -> int
func set_relation_to(other: StringName, value: int) -> void
func add_relation(other: StringName, delta: int) -> int
func callname_for(other: StringName) -> String
func set_callname_for(other: StringName, value: String) -> void
```

- `set_relation_to()` / `add_relation()` 夹在 `min_value..max_value`；
- 关系值实际变化时才发 `relation_changed(target, value)`，并 `_mark_changed(&"relations")`；
- 定向称呼存 `RelationEntry.callname`；
- `Character.name_for(other)` 的回退顺序：可选 `RelationComponent` 的定向称呼 → 对方默认称呼 → 对方真名 → `"-"`；没有关系组件时跳过定向称呼。

## 6. 原型与 spawn

- `Character.spawn(new_id)` 对每个组件调用 `duplicate_for_spawn()`；
- 默认实现：`script.new()` + `apply_fields(to_fields())` + `apply_static_refs(...)`；
- `RelationComponent` 覆盖它，逐条 `RelationEntry.duplicate_entry()`，避免嵌套 Resource 与原型共享；
- 原型是 `.tres`：玩家/女儿/女仆/父亲分别带英文 `id`；关系数据在各自的 `RelationComponent`；
- 只有女儿安装 `AgeComponent`；没有年龄概念的角色不伪造默认年龄。

## 7. 页面与事件

### 挂载页面

```gdscript
var result: Variant = await Era.show_screen(CHARACTER_CREATE, {
    "display_name": daughter.display_name,
    "age": age_component.value if age_component != null else 18,
})
```

- `EraScreenPage.configure(data)` 在页面入树前调用；
- 页面只使用 `configure()` 输入，不读取或修改 `Era.state`；
- 完成后发 `finished(result)`，由事件写回角色/组件；
- 角色创建页结果键：`display_name`、`age`。

### 事件

- 重启当前事件：`return get_script() as GDScript`（局部变量重置，游戏状态保留）；
- 当前事件内循环：`while true:`（保留实例和局部变量）；
- 进入其他事件：`return OtherEvent`。

## 8. KOJO

- `KojoBook` 只注册 `register(event_name, Callable)`，口上函数是普通 GDScript；
- `Era.kojo(character, event_name, extras = {})` 每次新建 `KojoContext`：

```gdscript
var speaker: Character
var player: Character
var state: GameState
var extras: Dictionary
```

- 固定字段是 `speaker / player / state`；调用者的临时数据放 `extras`，同名键不会覆盖固定字段；
- 事件函数：`func _morning(context: KojoContext) -> Variant`；
- 事件 ID：`morning / after_training / act_cute / daily / caress`；
- 按钮：`Era.print_button(...)` + `await Era.input()`；sync：函数里不写 await；
- 口上开关/计数在 `KojoComponent`；计数键用英文事件 ID。

## 9. 命名边界

- 英文：变量、方法、导出字段、信号、上下文固定字段、组件字段、状态字段、程序字符串 ID。
- 中文：玩家可见名字/台词/按钮/状态文本、中文注释/文档、既有资源文件名。
- 角色 ID：`player / daughter / maid / father`；天赋 ID：`ignorant / childish / precocious / sexually_repressed / weak_bladder`。
- 测试 ID：`prototype / daughter_copy / test_character / stranger`。

## 10. 存档边界（以后）

- 组件继续用 `to_fields()` / `apply_fields()` 白名单口径；
- 静态 Resource 引用（口上书）走 `to_static_refs()` / `apply_static_refs()`，不进存档；
- 本轮没有新增存档系统，也没有存档迁移。

## 11. 验证

- `tests/check_*.tscn` 共 **17** 个，全部输出 `CHECK OK`；
- 主场景和 demo 场景 headless 无脚本错误；
- 关键覆盖：组件类型身份、可选 Age/Relation、spawn 深拷贝、页面输入、事件重启/循环、`KojoContext` 固定字段与 extras、英文程序 ID。

## 12. 已知限制

- `SexyComponent` 的等级阈值/增减规则仍是示例，待游戏规则确定后完善；
- 父亲原型只有占位组件，尚未接入内容；
- 没有存档系统；
- 生命/体力/精力/天赋等字段是示例模板，具体数值规则由游戏内容定义。

## 参考

- 迁移边界：`docs/superpowers/specs/2026-10-25-engine-boundaries-design.md`
- 执行计划：`docs/superpowers/plans/2026-10-25-engine-boundaries.md`
- 旧版设计/讨论：`docs/step-*.md`
- Emuera / GDEmuera / era-electron 的对照结论保留在历史记录中。
