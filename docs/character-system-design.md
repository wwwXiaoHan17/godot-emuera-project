# 角色系统设计（定稿）

> 日期：2026-10-26 初稿 / 2026-11-01 全面改造版
> 状态：已按 `docs/superpowers/specs/2026-10-25-engine-boundaries-design.md` 落地，
> 并完成 2026-11-01「Character 全面改造」（实 bug 修复 + 封装收口 + 存档/批量/动态变量能力 + API 直观化）。
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
- 组件由 `components` 数组持有；`spawn()` 产生独立副本。
- **`components` 运行时只能经 `add_component()` / `remove_component()` 变更**：直改数组不会触发类型索引重建（索引无失效路径；.tres/Inspector 编辑依赖首次查询时的懒重建）。四个原型 .tres 均带 `is_prototype = true`。

## 3. 组件身份与显示名

- **身份 = 脚本类型**：`CharacterComponent.component_type()` 默认返回自身脚本。
- `Character.get_component(type: Script)` 按类型查找，支持继承（`LifeComponent` 的查找能找到 `SlimeLifeComponent`）。
- `add_component()` 按 `component_type()` 替换同类组件；同显示名的无关组件不会互相覆盖。
- `get_or_add(type: Script)`：没有该组件就现建一个再返回——内容侧"免判空"的基石（非 CharacterComponent 子类 push_warning 返回 null）。
- **类型索引统一"后者胜"**：identity 槽与基类槽都按数组顺序后写覆盖，与 `add_component` 的替换语义一致（直装两个同 identity 组件时，spawn 会折叠为最后一个的副本——这是定义化投影，不是丢件）。
- `display_name: String` 只用于界面显示，空时回退脚本类名；不参与查找/替换/程序 ID。

## 4. 组件清单

| 组件 | 字段 / 方法 | 显示名 | 说明 |
|---|---|---|---|
| `LifeComponent` | `value / max_value`、`hurt/heal/ratio` | 生命 | 基础类型，子类仍按 Life 查找 |
| `StaminaComponent` | `value / max_value`、`spend/rest` | 体力 | 示例模板 |
| `EnergyComponent` | `value / max_value`、`spend/rest` | 精力 | 示例模板 |
| `SexyComponent` | `sexy_value`、派生 `sexy_level`、`increased/decreased/set_value` | 性欲 | **等级由 value 派生**（阈值表 `LEVEL_THRESHOLDS`：<0 厌恶 / 0..999 正常 / 1000..4999 萌芽 / ≥5000 高涨），勿手写 level；只在跨档时发变更信号 |
| `AgeComponent` | `value / died_age`、`increase/decrease/set_value`、信号 `died` | 年龄 | 可选；`increase` 跨越 `died_age` 时发一次 `died`；**`set_value` 是"设定当前年龄"，保证不越死**（v ≥ died_age 时抬 died_age = v+1），不触发死亡——修"死亡年龄按默认 18 岁随机、创建年龄后写入"的锚点错 |
| `TalentListComponent` | `selected: Array[StringName]`、`text()`、`TALENT_RESOURCES` | 天赋 | `TALENT_RESOURCES` 是全工程唯一天赋清单（页面与组件共用，勿再复制一份） |
| `RelationComponent` | 见 §5 | 关系 | 可选；玩家/女儿/女仆安装 |
| `KojoComponent` | `book`、`enabled_events`、`counters` | 口上 | 口上书的运行时状态 |
| `FlagTableComponent`（engine/character/components/） | `values: Dictionary[StringName,int]`、`set_flag/get_flag/add_flag` | 标记 | **动态变量组**（对标 Emuera CFLAG/#DIM 的零代码加变量）；CSV `flag` 行的落点 |

组件字段和程序 ID 用英文；显示名、玩家可见文字用中文。

## 5. 关系与称呼

`RelationComponent` 同时保存数据和规则：

```gdscript
signal relation_changed(target: StringName, value: int)
signal callname_changed(target: StringName, value: String)

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
- 关系值实际变化时才发 `relation_changed(target, value)` + `_mark_changed(&"relations")`；**称呼实际变化时才发 `callname_changed(target, value)` + `_mark_changed(&"callname")`**（双通知对称）；
- 定向称呼存 `RelationEntry.callname`；
- `Character.name_for(other)` 的回退顺序：可选 `RelationComponent` 的定向称呼 → 对方默认称呼 → 对方真名 → `"-"`；没有关系组件时跳过定向称呼。
- **存档/复制走纯数据轨**：`to_fields()` 把 relations 降成 `[{target, relation, callname}]` 字典数组，`apply_fields()` 逐条 `new RelationEntry` 重建（不复用入参引用）。

## 6. 原型与 spawn

- `Character.spawn(new_id)` 对每个组件调用 `duplicate_for_spawn()`；
- 默认实现：`script.new()` + `apply_fields(to_fields())` + `apply_static_refs(...)`——**fields 纯数据轨天然深拷贝**（RelationComponent 已不再覆写 duplicate_for_spawn，字典往返即逐条重建）；
- 脚本缺 `resource_path`（内部类/运行时拼脚本）时 push_warning 并跳过该组件，不再静默丢件；
- 原型是 `.tres`：玩家/女儿/女仆/父亲分别带英文 `id` 与 `is_prototype = true`；关系数据在各自的 `RelationComponent`；
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
- 完成后发 `finished(result)`，由事件写回角色/组件（年龄写回走 `AgeComponent.set_value`）。

### 事件

- 事件签名统一：`func run(context: EventContext) -> GDScript`；引擎每执行一个事件前打包一个 `EventContext`（`state` + `player`＝protagonist 绑定），每事件一包；
- 事件里拿人用 `context.character(&"daughter")` / `context.player`（**拿数据用 `context`，做事用 `Era.*`**）；
- **装配收口**：`Era.state` 只读（getter）；角色表装配只在 new_game 一处，写回走 `Era.set_character_book(CharacterSetup.ensure(Era.state.character_book))`；其余事件信任书已就绪。`CharacterSetup.ensure` 只在**新建书**时设默认 `protagonist_id`（已有书不碰——为主角换绑留路）；
- 重启当前事件：`return get_script() as GDScript`；当前事件内循环：`while true:`；进入其他事件：`return OtherEvent`；
- **preload 一律 `res://` 路径，禁止 `uid://`**：docs/superpowers 历史快照曾与正本撞 UID 导致事件链静默死亡（已加 .gdignore + 清快照 .uid 根治，规则仍须遵守）。

### EventContext 便捷 API（2026-11-01 新增，治"不直观"）

```gdscript
context.target                      # 当前交互对象（对标 Emuera TARGET），活读 Era.target；口上执行期 == speaker
context.characters_with(LifeComponent)   # 所有装了该组件的角色
context.each(LifeComponent, func(c): ...)  # 同上，直接遍历
var hp := context.get_value(&"daughter", LifeComponent, &"value", 0)  # 免判空一行读（缺角色/组件/字段回默认）
context.name_between(&"daughter", &"player")  # 女儿怎么称呼玩家（定向称呼→默认称呼→真名，缺失 "-")
```

- `Era.set_target(char)` / `Era.target`：引擎维护的"当前交互对象"；`Era.kojo(speaker, ...)` 执行期间自动置 `target = speaker`，结束恢复。

## 8. KOJO

- `KojoBook` 只注册 `register(event_name, Callable)`，口上函数是普通 GDScript；
- `Era.kojo(speaker, event_name, extras = {})` 每次新建 `KojoContext`；`KojoContext` **extends `EventContext`**（继承 `player` / `state` / `character()` / §7 便捷 API），口上特有的固定字段是 `speaker / extras`（同名 extras 不覆盖固定字段）；
- **说话人语义（治"speaker 是谁"）**：`speaker` = 正在说话的人，口上执行期恒等于 `context.target`；
  - `context.speaker_name()` = 说话人对玩家的称呼（player 判空回 `"-"`）；
  - `context.listener_name()` = 玩家对说话人的称呼；
- 事件函数：`func _morning(context: KojoContext) -> Variant`；事件 ID：`morning / after_training / act_cute / daily / caress`；
- 按钮：`Era.print_button(...)` + `await Era.input()`；sync：函数里不写 await；
- 口上开关/计数在 `KojoComponent`；计数键用英文事件 ID。

## 9. 命名边界

- 英文：变量、方法、导出字段、信号、上下文固定字段、组件字段、状态字段、程序字符串 ID。
- 中文：玩家可见名字/台词/按钮/状态文本、中文注释/文档、既有资源文件名。
- 角色 ID：`player / daughter / maid / father`；天赋 ID：`ignorant / childish / precocious / sexually_repressed / weak_bladder`。
- 测试 ID：`prototype / daughter_copy / test_character / stranger`。

## 10. 存档系统（2026-11-01 落地）

口径统一为**白名单 fields 轨**（"整本 CharacterBook 当 Resource 序列化"的旧说法作废）：

- `SaveManager.save_to(slot, state)` → `user://save_slot<N>.json`：`{save_version, min_supported, day, flags, protagonist_id, book}`；
- `SaveManager.load_from(slot)` → `{ok, state, error, warnings}`：
  - **版本门禁**：`save_version < min_supported` 拒载（缺版本视为 0）；比当前新则警告后宽容继续；
  - **宽容读取**：未知键/未知组件/坏字段跳过并汇总进 warnings（缺失补默认）；
  - **迁移钩子**：组件可选实现 `on_load_fixup(old_version)`，读档后分发；
- `CharacterBook.to_save_dict()/apply_save_dict()`：组件按**脚本全局类名**做键（加组件/加字段天然前向兼容）；静态引用（口上书）存 resource_path/类名规格，不进字段；内联子资源用 `{"__resource__": {class|path, fields}}` 规格；
- JSON 读回的类型修正（整数→float、typed 容器元素对齐）在 `CharacterBook._apply_component_fields` 统一处理后**委托给组件自己的 `apply_fields`**（含子类覆写）落值。

## 11. 批量装配：CharaCsvLoader（2026-11-01 新增）

对标 eraTW 的 `ADDCHARA + EXISTCSV`（eraTW 用 168 个 Chara CSV + 脚本侧 for 批量初始化）：

```gdscript
var chars: Array[Character] = CharaCsvLoader.load_dir("res://data/chara")  # 递归 *.csv
Era.state.character_book.add_all(chars)
```

CSV 行格式 v1：`id,英文id` / `名字,中文` / `称呼,中文` / `组件,类名,字段=值,...`（同组件多行合并）/ `flag,键,整数`（→ FlagTableComponent）；未知行 push_warning 跳过。样例见 `tests/fixtures/chara/`。

## 12. 全局变量容器（2026-11-01 新增）

`GameState`：`day: int = 1` + `flags: Dictionary[StringName, int]`（对标 Emuera FLAG/DAY 的非角色变量），随存档往返；事件里 `Era.state.day` / `Era.state.flags[&"gold"]`。

## 13. 验证

- `tests/check_*.tscn` 共 **20** 个，全部输出 `CHECK OK`（17 旧 + `check_component_fixes` / `check_content_fixes` / `check_engine_api`）；
- 关键覆盖：组件类型身份与"后者胜"索引、get_or_add、sexy 四档派生、age 设定不越死/跨界死亡、callname 双通知、关系纯数据往返、存档门禁与宽容读取、CSV 批量、target/speaker 语义、页面输入、事件重启/循环、英文程序 ID。

## 14. 已知限制与工程陷阱

- `SexyComponent` 阈值数值仍是示例，待游戏规则确定后调整（派生机制已定稿）；
- 父亲原型只有 Sexy 组件占位，尚未接入内容；
- 主流程事件尚未触发任何 `Era.kojo`（口上只在测试/演示路径激活）——集成空缺待内容补；
- **Godot 4.8-dev7 陷阱**（实测记录）：typed 容器成员整体 `set()` 会被静默丢弃（必须 assign/merge 逐元素）；JSON 整数解析为 float；场景根脚本编译失败零输出（headless 需超时击杀兜底）；脚本级 `static var` 有静默崩溃嫌疑（character_book 的 static 缓存当前实测可用，保持观察）；`uid://` 预加载禁用（见 §7）。

## 参考

- 迁移边界：`docs/superpowers/specs/2026-10-25-engine-boundaries-design.md`
- 角色访问统一 spec：`docs/superpowers/specs/2026-10-31-character-access-context-design.md`
- 执行计划：`docs/superpowers/plans/2026-10-25-engine-boundaries.md`
- 旧版设计/讨论：`docs/step-*.md`
- Emuera / GDEmuera / era-electron / eraTW 的对照结论保留在历史记录与项目记忆中。
