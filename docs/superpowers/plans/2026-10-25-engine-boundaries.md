# Era Engine Boundaries Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不改变常驻壳与命令式写作方式的前提下，落实已确认的角色组件、页面输入、事件语义、口上下文和英文命名边界。

**Architecture:** 保持 `Era` 为单一作者入口，暂不拆分其实现。`Character` 只保留身份、名字与组件宿主；组件按脚本类型识别；页面显式接收输入；口上使用 `KojoContext`。先完成结构性迁移，再统一英文命名，最后更新设计文档并全量验收。

**Tech Stack:** Godot 4.8-dev7、GDScript、Resource、现有 `.tscn` 校验场景；不新增库或测试框架。

**Spec:** `docs/superpowers/specs/2026-10-25-engine-boundaries-design.md`（已获用户确认）

## Global Constraints

- 保留 `Era.print()`、`await Era.input()`、`await Era.kojo()` 的作者接口风格，不拆分 `engine/era.gd`。
- `Character` 保留 `id / display_name / callname / components / is_prototype`；年龄和关系是可选组件。
- 组件身份使用脚本类型；`display_name` 只用于显示，不能查找或替换组件。
- 页面不得读取或修改 `Era.state`；固定口上上下文使用明确字段，临时数据使用 `extras`。
- 代码标识符和程序字符串 ID 使用英文；玩家可见中文、中文文档和既有资源文件名不变。
- 不引入新的存档系统、存档迁移、字符串条件、事件 `refresh()` 命令或测试框架。
- 每个任务同步更新相关注释与 docstring；历史 `docs/step-*-report.md` 不改写。
- 当前目录不是 Git 仓库：不执行 `git init` 或 commit，每个任务以校验通过和用户审阅为完成标志。
- 在 PowerShell 的项目根目录设置引擎命令：`$GODOT = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'`。
- 2026-10-25 基线已实测：现有 16 个 `check_*.tscn` 全部输出 `CHECK OK`。

全量校验统一使用以下命令；任一失败立即停止，不能只检查 Godot 进程是否退出：

```powershell
Get-ChildItem "$PWD/tests/check_*.tscn" | ForEach-Object {
    & $GODOT --headless --path $PWD ("res://tests/" + $_.Name) --quit-after 300
    if ($LASTEXITCODE -ne 0) { throw "CHECK FAILED: $($_.Name)" }
}
```

## Review Focus

- 同显示名的无关组件、继承组件：必须按类型保留或替换，不能静默互相覆盖；由 Task 1 的 `check_character` 固定。
- 无年龄、无关系组件的角色：名字回退仍正常，不能伪造默认组件；由 Task 2、3 固定。
- 原型中的 `RelationEntry`：实例修改值或称呼后不得影响原型，范围夹取和通知必须带目标 ID；由 Task 3 固定。
- 页面缺少输入或全局状态存在不同数据：只能使用 `configure()` 输入，缺输入不得发出完成结果；由 Task 4 固定。
- `extras` 含 `speaker / player / state` 等同名键：固定字段不能被覆盖，额外键仍原样保留；由 Task 6 固定。

## File Structure

```text
engine/
  character/
    character.gd                 # 身份、名字、组件宿主、原型复制
    character_component.gd       # 类型身份、显示名、字段复制、spawn 复制入口
    relation_component.gd        # 新增：可选关系数据与规则
    relation_entry.gd            # 单条方向关系及其独立复制
  era.gd                         # show_screen 输入、KojoContext 装配；不拆文件
  era_screen_page.gd             # configure(data) 接口
  game_state.gd                  # character_book
  kojo/
    kojo_context.gd              # 新增：speaker/player/state/extras
    kojo_book.gd                 # 更新口上写法示例
content/
  characters/components/         # AgeComponent；组件字段英文化；删除 AffectionComponent
  characters/prototypes/         # 可选组件装配、英文 ID；文件名不变
  screens/character_create.gd    # 纯输入→编辑→结果页面
  events/                        # 新组件调用、页面输入、重启/循环语义
  kojo/女儿_kojo.gd              # KojoContext、英文事件 ID
tests/
  check_*.gd/.tscn               # 更新现有校验；新增 check_event_flow
  _kojo_context_probe.gd         # 新增：口上下文测试替身
docs/
  engine-v1-design.md            # 更新当前接口与示例
  character-system-design.md     # 更新为定稿后的角色设计
```

---

### Task 1: 组件类型身份与显示名

**Files:**
- Modify: `engine/character/character_component.gd`, `engine/character/character.gd`
- Modify: `content/characters/components/{life,stamina,energy,sexy,talent,affection}_component.gd`, `engine/kojo/kojo_component.gd`
- Modify: `content/characters/prototypes/{玩家,女儿,女仆,父亲}.tres`
- Modify: `content/events/show_component.gd`
- Test: `tests/check_character.gd`, `tests/check_character.tscn`

**Interfaces:**
- Produces: `CharacterComponent.display_name: String`、`get_display_name() -> String`、`component_type() -> Script`。
- Produces: `Character.get_component(type: Script) -> CharacterComponent`，支持继承；`remove_component(type: Script) -> void`。
- Removes: `context_key`、`get_context_key()`、`component_key()`、`get_component(key)`。

- [x] **Step 1: 先改 `check_character`，写身份与显示名校验**

在测试脚本内定义一个继承 `LifeComponent` 的测试组件。断言：基础类型能取得子类；子类替换普通生命组件；同 `display_name` 的无关组件不会替换生命组件；空显示名回退 `LifeComponent`；按类型删除后查询为 `null`；连续增删后索引结果正确。

- [x] **Step 2: 运行并确认因接口不存在而失败**

Run: `& $GODOT --headless --path $PWD res://tests/check_character.tscn --quit-after 300`
Expected: 非 0，错误指向 `get_display_name/component_type` 或旧测试接口不存在。

- [x] **Step 3: 实现类型身份并迁移显示名**

`CharacterComponent.component_type()` 默认返回 `get_script()`；`LifeComponent.component_type()` 返回 `LifeComponent`，供子类继承。`Character.add_component()` 按此身份替换，`component()` 沿 `get_base_script()` 检查继承；缓存以 `Script` 为键，只在初始化、增删时重建。

把现有组件和原型中的 `context_key` 改为字符串 `display_name`，中文显示值不变。`show_component` 改用 `get_display_name()`。更新所有受影响调用与注释。

- [x] **Step 4: 验证组件与组件展示**

Run: 分别运行 `check_character.tscn`、`demo_show_component.tscn --quit-after 60`。
Expected: 校验输出 `CHECK OK`、退出码 0；演示无脚本错误，显示名正确。

- [x] **Step 5: 用户审阅后进入 Task 2**

---

### Task 2: AgeComponent 与 Character 瘦身

**Files:**
- Create: `content/characters/components/age_component.gd`
- Modify: `engine/character/character.gd`, `content/characters/prototypes/女儿.tres`
- Modify: `content/events/{new_game,day_start}.gd`, `content/screens/character_create.gd`
- Modify: `tests/_drive_kojo_buttons.gd`, `tests/check_kojo_buttons.gd`
- Test: `tests/check_character.gd`, `tests/check_day_start.gd`

**Interfaces:**
- Produces: `class_name AgeComponent extends CharacterComponent`，`@export var value: int = 18`，显示名“年龄”。
- Removes: `Character.age` 及其 `spawn()` 复制。
- Consumes: Task 1 的 `component(AgeComponent)`。

- [x] **Step 1: 写年龄可选与现有流程校验**

`check_character` 断言新 `Character` 没有 `AgeComponent`，脚本属性中也没有 `age`。`check_day_start` 改为从女儿的 `AgeComponent.value` 验证 21。按钮口上校验不再借 `age` 保存测试结果，改由驱动打印 `picked=<值>` 并断言该行。

- [x] **Step 2: 运行并确认 AgeComponent 不存在导致失败**

Run: `& $GODOT --headless --path $PWD res://tests/check_day_start.tscn --quit-after 300`
Expected: 非 0，指向 `AgeComponent` 或已删除字段的引用。

- [x] **Step 3: 实现并迁移年龄读写**

创建 `AgeComponent`；只给女儿原型安装，其他角色不凭空添加。删除 `Character.age` 与复制逻辑。`new_game`、角色创建页和 `day_start` 暂沿用现有页面边界，但年龄一律通过 `AgeComponent` 读写。

- [x] **Step 4: 运行年龄相关回归**

Run: `check_character`、`check_day_start`、`check_kojo_buttons`。
Expected: 三者均 `CHECK OK`；无年龄组件的角色正常创建，女儿创建年龄仍为页面结果。

- [x] **Step 5: 用户审阅后进入 Task 3**

---

### Task 3: RelationComponent 合并关系数据与规则

**Files:**
- Create: `engine/character/relation_component.gd`
- Delete: `content/characters/components/affection_component.gd`, `content/characters/components/affection_component.gd.uid`
- Modify: `engine/character/{character,character_component,relation_entry}.gd`
- Modify: `content/characters/prototypes/{玩家,女儿,女仆}.tres`
- Modify: `content/events/{day_start,character_panel}.gd`, `content/kojo/女儿_kojo.gd`
- Modify: `tests/{_demo_character_event,_demo_relations_event,_demo_kojo_event}.gd`
- Test: `tests/check_character.gd`, `tests/check_relations.gd`, `tests/check_kojo.gd`, `tests/check_day_start.gd`

**Interfaces:**
- Produces: `RelationComponent.relations: Array[RelationEntry]`、`min_value: int = 0`、`max_value: int = 100`。
- Produces: `relation_to(other) -> int`、`set_relation_to(other, value) -> void`、`add_relation(other, delta) -> int`、`callname_for(other) -> String`、`set_callname_for(other, value) -> void`。
- Produces: `signal relation_changed(target: StringName, value: int)`；实际值变化时发出，并调用 `_mark_changed(&"relations")`。
- Produces: `CharacterComponent.duplicate_for_spawn() -> CharacterComponent`、`RelationEntry.duplicate_entry() -> RelationEntry`。
- Removes: `Character.relations` 及关系读写方法、`AffectionComponent`。

- [x] **Step 1: 写关系范围、通知、可选性和深拷贝校验**

扩展 `check_relations`：无 `RelationComponent` 时 `name_for()` 仍按默认称呼/真名回退；`add_relation()` 夹到 `min_value/max_value`；通知带正确目标和新值；修改 spawn 实例的关系或定向称呼不影响原型。

- [x] **Step 2: 运行并确认 RelationComponent 不存在导致失败**

Run: `& $GODOT --headless --path $PWD res://tests/check_relations.tscn --quit-after 300`
Expected: 非 0，指向新类型或新接口缺失。

- [x] **Step 3: 实现关系组件和通用 spawn 复制入口**

`duplicate_for_spawn()` 依次执行 `script.new()`、`apply_fields(to_fields())`、`apply_static_refs(to_static_refs())`。`RelationComponent` 覆盖该方法，在基类复制后逐条用 `duplicate_entry()` 重建关系，避免数组深拷贝仍共享 Resource。

`Character.spawn()` 对每个组件调用该入口。`Character.name_for()` 只在装有 `RelationComponent` 时读取定向称呼，随后执行现有回退。关系设置统一夹取，不再保留绕过入口。

- [x] **Step 4: 迁移原型和所有调用方**

玩家、女儿、女仆把原有关系条目移入各自的 `RelationComponent`；女儿用该组件替换 `AffectionComponent`。内容通过局部 `RelationComponent` 读写关系，最后删除旧好感脚本及 UID。

- [x] **Step 5: 运行关系回归**

Run: `check_character`、`check_relations`、`check_kojo`、`check_day_start`。
Expected: 全部 `CHECK OK`；原型初始值 50/20/30 保持不变，实例与原型互不影响。

- [x] **Step 6: 用户审阅后进入 Task 4**

---

### Task 4: 挂载页面显式输入

**Files:**
- Modify: `engine/era.gd`, `engine/era_screen_page.gd`
- Modify: `content/screens/character_create.gd`, `content/events/new_game.gd`
- Test: `tests/check_character_create.gd`, `tests/check_day_start.gd`

**Interfaces:**
- Produces: `EraScreenPage.configure(data: Dictionary) -> void`。
- Changes: `Era.show_screen(scene: PackedScene, data: Dictionary = {}) -> Variant`，在页面入树前调用 `configure(data)`。
- Produces: 角色创建页输入/结果键 `display_name`、`age`。

- [x] **Step 1: 写页面输入与缺输入校验**

`check_character_create` 在 `add_child()` 前调用 `configure({"display_name": "初始名", "age": 20})`，断言控件显示初始值；全局状态放置不同名字也不能影响页面。另建页面，缺输入时点击开始不得发出 `finished`，并出现 `push_warning` 提示。

- [x] **Step 2: 运行并确认 configure 接口缺失导致失败**

Run: `& $GODOT --headless --path $PWD res://tests/check_character_create.tscn --quit-after 300`
Expected: 非 0，指向 `configure` 不存在或初始值未使用。

- [x] **Step 3: 实现纯数据页面**

`CharacterCreate.configure()` 验证 `display_name` 为 String、`age` 为 int 且在 1–99；合法时保存输入，非法时警告并保持不可完成。`_ready()` 只把已保存输入写入控件。`_on_start()` 在未成功配置时警告并返回，否则发出英文键结果。

`new_game` 从女儿及 `AgeComponent` 准备输入，并处理英文结果键；只有事件写回角色数据。

- [x] **Step 4: 验证页面隔离和完整链路**

Run: `check_character_create`、`check_day_start`；另搜索 `content/screens/*.gd` 中的 `Era.state`。
Expected: 两个场景 `CHECK OK`；页面脚本无 `Era.state` 引用。

- [x] **Step 5: 用户审阅后进入 Task 5**

---

### Task 5: 明确事件重启与局部循环

**Files:**
- Create: `tests/check_event_flow.gd`, `tests/check_event_flow.tscn`
- Modify: `content/events/{title,day_start,character_panel}.gd`
- Test: `tests/check_title.gd`, `tests/check_day_start.gd`

**Interfaces:**
- Consumes: 现有 `Era.start()` 与 `EraEvent.run() -> GDScript`。
- Establishes: `return get_script() as GDScript` 为重启；`while` 为保留实例的局部循环。

- [x] **Step 1: 写事件语义的特征校验**

在 `check_event_flow.gd` 内定义两个测试事件。重启事件连续两次记录局部计数，预期 `[1, 1]`，第一次修改的生命值在重启后保持 90；循环事件两次记录同一局部计数，预期 `[1, 2]`。用真实 `Era.input()` 驱动，不直接调用 `run()`。

- [x] **Step 2: 先运行特征校验，不要求失败**

Run: `& $GODOT --headless --path $PWD res://tests/check_event_flow.tscn --quit-after 300`
Expected: 当前引擎若已符合两种语义则 `CHECK OK`；此步用于锁定重构前后的行为，失败则先停止内容重构。

- [x] **Step 3: 统一内容事件写法**

`title` 的自我跳转改为 `return get_script() as GDScript`。`day_start` 重画时也使用该形式并删除自我 preload。`character_panel` 保留 `while true`，动作后等待按键并进入下一轮，不再 `load(SelfPath)`；只有离开面板时返回 `DayStart`。

- [x] **Step 4: 运行流程回归**

Run: `check_event_flow`、`check_title`、`check_day_start`。
Expected: 全部 `CHECK OK`；面板修改生命后仍显示 90，返回链路不变。

- [x] **Step 5: 用户审阅后进入 Task 6**

---

### Task 6: KojoContext 与口上英文 ID

**Files:**
- Create: `engine/kojo/kojo_context.gd`, `tests/_kojo_context_probe.gd`
- Modify: `engine/era.gd`, `engine/kojo/{kojo_book,kojo_component}.gd`
- Modify: `content/kojo/女儿_kojo.gd`
- Modify: `tests/{_drive_kojo_buttons,_demo_kojo_event}.gd`
- Test: `tests/check_kojo.gd`, `tests/check_kojo_buttons.gd`

**Interfaces:**
- Produces: `KojoContext.speaker: Character`、`player: Character`、`state: GameState`、`extras: Dictionary`。
- Changes: `Era.kojo(character: Character, event_name: StringName, extras: Dictionary = {}) -> Variant`。
- Event IDs: `morning / after_training / act_cute / daily / caress`；额外数据示例键 `partner`。

- [x] **Step 1: 写固定字段与 extras 校验**

测试替身注册 `probe`，保存收到的上下文并返回 `extras["partner"]`。断言返回正确玩家，`speaker/player/state` 指向预期对象；即使 `extras` 含同名键也不改变固定字段；所有额外键仍可读取。同步更新口上测试使用英文事件 ID。

- [x] **Step 2: 运行并确认 KojoContext 不存在导致失败**

Run: `& $GODOT --headless --path $PWD res://tests/check_kojo.tscn --quit-after 300`
Expected: 非 0，指向 `KojoContext` 或新事件注册缺失。

- [x] **Step 3: 实现上下文并迁移口上**

`Era.kojo()` 每次新建 `KojoContext`，固定字段单独赋值，`extras = extras.duplicate()`；不再把固定值和调用者数据合并进同一个 Dictionary。旧 `角色/玩家/状态/口上` 字典键全部移除，口上组件仍可通过 `context.speaker.get_component(KojoComponent)` 获取。

所有口上函数改为 `func _event(context: KojoContext) -> Variant`，使用 `context.speaker/player/state/extras`；关系读取使用 Task 3 的组件。`_caress` 替换中文方法名，注册和调用全部使用英文事件 ID。

- [x] **Step 4: 运行口上回归**

Run: `check_kojo`、`check_kojo_buttons`、`demo_kojo --quit-after 60`。
Expected: 两个校验 `CHECK OK`；按钮、sync、开关、计数和返回值不回归，演示无脚本错误。

- [x] **Step 5: 用户审阅后进入 Task 7**

---

### Task 7: 英文标识符与程序 ID 统一

**Files:**
- Modify: `engine/game_state.gd`, `engine/era.gd`, `engine/character/character_book.gd`, `engine/character/relation_entry.gd`
- Modify: `content/characters/components/{life,stamina}.gd`, `content/characters/character_setup.gd`
- Modify: `content/characters/prototypes/*.tres`, `resources/talent_resource/*.tres`
- Modify: `content/events/*.gd`, `content/screens/*.gd`, `tests/*.gd`, `experiment/c_hybrid/c_main.gd`

**Interfaces:**
- Changes: `GameState.character_book: CharacterBook`；`CharacterBook.protagonist_id = &"player"`。
- Changes: `LifeComponent` 与 `StaminaComponent` 的 `值/上限` → `value/max_value`。
- Character IDs: `player / daughter / maid / father`。
- Talent IDs: `ignorant / childish / precocious / sexually_repressed / weak_bladder`；`conflicts_with` 同步使用 `childish/precocious`。
- Test IDs: `prototype / daughter_copy / test_character / stranger / missing`；数字按钮 ID 不变。

- [x] **Step 1: 先列出所有剩余命中**

搜索 GDScript 声明中的汉字，以及 `.gd/.tres` 中的中文 `StringName`。将命中分为“标识符/程序 ID”和“注释/玩家文本/资源路径”，只迁移前两类；资源文件名保持原样。

- [x] **Step 2: 迁移状态与组件字段**

把 `Era.state.角色簿` 全部改为 `Era.state.character_book`，生命和体力字段统一为 `value/max_value`。对应通知键 `_mark_changed(&"值")` 改为 `_mark_changed(&"value")`。同步所有 `.tres` 字段、内容、驱动、演示和断言，不保留双写或兼容别名。

- [x] **Step 3: 迁移程序字符串 ID**

替换角色、关系目标、测试角色和天赋 ID。`conflicts_with` 两端必须同时改；天赋 `display_name` 与所有台词保持中文。父亲原型使用 `id = &"father"`，其余原型使用既定英文 ID。

- [x] **Step 4: 运行完整校验**

Run: 执行 Global Constraints 中的全量 PowerShell 校验命令。
Expected: 17 个场景全部 `CHECK OK`，包括新增 `check_event_flow`；任一非 0 都停止后续任务。

- [x] **Step 5: 用户审阅后进入 Task 8**

---

### Task 8: 文档同步与最终验收

**Files:**
- Modify: `docs/engine-v1-design.md`, `docs/character-system-design.md`, `docs/README.md`
- Modify: 所有仍描述旧行为的 GDScript 注释/docstring
- Verify: `main.tscn`, `tests/check_*.tscn`, `tests/demo_*.tscn`

**Interfaces:**
- Consumes: Tasks 1–7 的最终接口；不再引入代码 API 变化。

- [x] **Step 1: 更新当前设计文档**

`character-system-design.md` 改为类型身份、`display_name`、可选 Age/Relation、spawn 深拷贝和 `KojoContext`；`engine-v1-design.md` 更新 `show_screen(scene, data)`、英文状态示例、重启/循环规则；`docs/README.md` 链接本次 spec 与 Plan。历史报告保持原样。

- [x] **Step 2: 扫描旧接口与过时注释**

在 `engine/`、`content/`、`tests/`、`docs/engine-v1-design.md` 和 `docs/character-system-design.md` 搜索 `context_key|get_context_key|component_key|get_component|AffectionComponent|Character.age|Character.relations|load\(SelfPath\)|Era.state.角色簿|\.值|\.上限|@export var (值|上限)|&"(值|上限|玩家|女儿|女仆|父亲|早上|调教后|撒娇|每日开场|爱抚)"`。
Expected: 这些当前代码与当前设计文档无旧接口命中；spec/Plan 中的迁移说明和历史报告不算旧用法，不改写。玩家可见中文和中文资源路径不受影响。

- [x] **Step 3: 全量自动验收**

先执行 Global Constraints 的全量校验命令，再运行：

```powershell
& $GODOT --headless --path $PWD res://main.tscn --quit-after 120
if ($LASTEXITCODE -ne 0) { throw "MAIN FAILED" }
Get-ChildItem "$PWD/tests/demo_*.tscn" | ForEach-Object {
    & $GODOT --headless --path $PWD ("res://tests/" + $_.Name) --quit-after 60
    if ($LASTEXITCODE -ne 0) { throw "DEMO FAILED: $($_.Name)" }
}
```

Expected: 17 个校验全部 `CHECK OK`、退出码 0；主场景与演示无脚本错误。口上缺事件/禁用事件等既有预期 warning 可保留，不得出现解析错误或无效调用。

- [x] **Step 4: 手动走完原始用户链路**

F5 执行：标题 → 开始游戏 → 角色创建 → 天赋选择 → 第 1 天 → 角色面板修改数值 → 返回第 1 天 → 口上演示。
Expected: 初始名字/年龄来自页面输入，年龄和关系来自组件，面板循环保留数值，中文显示不变，英文 ID 不泄露到界面。

- [x] **Step 5: 对照 spec 逐项审阅并交付**

验收：2026-10-26 用户接受；17/17 校验 `CHECK OK`，主场景/6 个 demo/实验 C headless 无脚本错误，F5 链路截图见 `experiment/shots/final_*.png`。

逐项核对 spec §1–10、16+1 个校验结果和手动链路。任何未验证项明确列为未完成，不以“代码已改”代替验收。
