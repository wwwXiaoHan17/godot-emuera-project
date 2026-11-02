# SDD ledger — plan: docs/superpowers/plans/2026-10-31-character-access-context.md

## Setup

- 环境：项目不是 git 仓库（计划 Global Constraints 已声明）→ 无 worktree / commit / BASE SHA。任务完成 = 校验绿 + task review；review package = 任务前后文件快照，用 `git diff --no-index` 生成。
- Ruling: 本 harness 的 subagent 工具不支持指定模型 → 无法按 SKILL.md 分层选型，全部使用默认模型；review 环节照常执行。
- 基线实测（2026-10-31 派发前）：**14/17 绿**。红：`check_title` / `check_day_start`（preload 已删除的 `title.gd` → 解析错误）、`check_talent_select`（talent 确认后现在进入 `type_a_new_game`，不再是 day_start 直达）。

## Pre-flight scan

| 检查项 | 结果 |
|---|---|
| T1 → T2：T1 产出 EventContext / KojoContext 继承，T2 消费 `run(context)` | 接口名一致，干净 |
| T2 → T3：T2 产出新签名，T3 迁移函数体用 `context.character` | 干净 |
| T1/T2 文件重叠：T1{event_context, kojo_context, check_kojo} vs T2{era, era_event, 事件, driver} | 无重叠 |
| T2/T3 文件重叠：check_event_flow、_demo_* 事件先后触碰 | 顺序执行，干净 |
| T2 自洽：文件清单 vs Step 3 数量 | 原一致；见 Ruling-3 后已修订（19 个脚本） |
| T2 grep 兜底：全库 `func run(` 权威清单 | era_event + content 7 个事件（含用户新增 type_a_* 两个）+ tests 12 处；计划原清单漏 type_a 两文件，已随 Ruling-3 修订 |
| 计划 grep 验证步骤 vs review rubric | grep 是验证步骤、非空测试，干净 |

## Rulings

- Ruling-3（基线漂移）: 用户已把主流程改为 type_a 线——`title.gd` 删除、`main.gd` 启动 `type_a_title.gd`、`talent_select` 确认后 `return TypeANewGame`（剧情过场）再进 day_start。3 个 check 红属于“测试没跟上用户改动”（先例：engine-boundaries Task 7 字段改名时的同类处理）。裁定：以用户流程为准，新增 **Task 0** 修复三个 check 恢复 17/17；Task 2 文件清单 `title.gd`→`type_a_title.gd`，另加 `type_a_new_game.gd`。代价：若用户并非此意，Task 0 的测试改动会随其流程意图一起回滚。
- Ruling-4（Task 0 简报缺陷，实现者上报）: 简报里“row_count >= 13 即到达第 1 天”的走路助手有撞车 bug——type_a_new_game 在选完“亲生女儿”后恰好经过 13 行（rule+5 wait+2 按钮+5 wait）再涨到 21 行、清屏进 day_start。实现者改为“先超过 13（peak > 13）、再回落到 13”才算到达，并把 `_choose(0)` 改为 check-before-act，避免误点 day_start 自己的 0 号按钮。裁定：接受该偏离（为满足简报自身的 17/17 验收所必需）；**后续任务穿过该剧情时禁止用“行数到达 N”当到达判定**。代价：到达条件与 type_a_new_game 的具体行数耦合，用户再改剧情行数时此助手需要跟着调。

## Task 0: 基线修复

- Implementer: a68504b2（DONE_WITH_CONCERNS，concern 即 Ruling-4，已裁定接受）。
- Review: 6933309c → Spec ✅ / Approved。审查者独立从 type_a_new_game.gd + era.gd 重推行数演进，确认 13 行撞车真实、peak>13 到达信号唯一、_choose(0) 门控有效。
- ⚠️ 关闭：17/17 由 controller 复跑确认（total=17 fail=none）。
- minor (deferred): 走路到达判定硬编码 day_start 的 13 行，未来 day_start 行数变化会超时失败（报错信息不够指向）；辅助函数在两个 check 里逐字重复（简报限定只能碰 3 个文件，无更优解）。
- Task 0: complete（tests: 17/17 CHECK OK，review clean）

## Task 1: EventContext 基类与 KojoContext 继承

- Implementer: bb9f47cc（DONE）。TDD：RED=check_kojo 解析错误"EventContext 未声明"→ GREEN → 17/17。
- Review: ef680f87 → Spec ✅ / Approved。审查者核验：接口逐字一致、kojo_context 删自身 player/state 保留 speaker/extras、era.gd 消费端（:347-351 四字段全可解析）无需改动、断言是真查找（hit+miss 不能靠 null 路径蒙混）。⚠️ 项（diff 里两个 .uid "被删"）审查者已自查为**快照工件**（after 快照没拷 .uid），非实现者越界。
- minor (deferred): character() 的 state/book 空守卫分支无直接测试（简报 3 断言之外的缺口，留给以后）；报告漏列自动生成的 event_context.gd.uid（纯记录性）。
- Ruling-5（流程修正，controller 自身）: 以后快照必须连 `.gd.uid` 一起拷贝，避免 review 包出现假删除、干扰审查范围判断。
- Task 1: complete（tests: 17/17 CHECK OK，review clean）

## Task 2: 事件签名切换 run(context)

- Implementer: 71b1912b（DONE）。TDD：RED=内嵌事件签名与基类不匹配的解析错误（简报预期的运行期错误同根因）→ GREEN；grep 无参 run() 0 命中；17/17 + main 干净。21 文件：17 事件脚本仅签名行（与备份逐行比对证实，type_a_new_game 只动第 3 行）。
- Review: 18e8e78c → Spec ✅ / Approved。审查者独立复算 60+/33- 逐 hunk、独立复跑 grep（20 处声明全带参、2 处调用点）、确认改绑主角断言真有判别力（复用旧包会读到 daughter 而失败）。
- minor (accepted-keep): 实现者顺手把 era_event.gd:7 / era.gd:12 两处 doc 示例签名对齐新签名（越出简报字面但文件在清单内、回退反而让示例教已编译不过的签名，保留）；check_event_flow 4 处 `_wait_rows` 目标随行数断言同步 2→3/1→3（必要且精确）。
- Forward note（带入 Task 3，已写入其简报）: `_run_flow` 在 `CharacterSetup.ensure` 之前打包的 context 其 player 为 null（如启动即跑的 title）；Task 3 只做 `context.character(id)` 同义替换，不引入新的 `context.player` 读取。
- Task 2: complete（tests: 17/17 CHECK OK + main clean，review clean）

## Task 3: 内容层退役 Era.character / character_book.find

- Implementer: 9e824fb5（DONE）。初始 grep：content 5 处 + tests 15 处；迁移 13 处/9 文件（content 5 + 事件脚本 8），保留 7 处 check 脚本装配/断言（spec 允许）。无新增 context.player 读取；装配代码未动。
- Review: 71a37a61 → Spec ✅ / Approved。审查者逐行核实 13 处均为纯接收者替换（参数/判空/逻辑零改动）；7 处保留确实不在事件体内；content grep=0 复验；等价性在引擎层核实（Era.character ≡ context.character；context.state 同引用，ensure 先行可见）。
- minor (deferred): 实现者报告 §2 标题写"12 处"，实为 13（其 §1 枚举本身正确，纯笔误）。
- Task 3: complete（tests: 17/17 CHECK OK + main clean，review clean）

## Task 4: 文档同步与最终验收

- Implementer: 0fdce1f7（DONE）。三份文档统一口径（逐字同句）；engine-v1/character-system 示例与实现逐行对照成立；era.gd/game_state.gd 仅注释行改动（每行以 ## 开头，可执行零改动）；顺手修正 era.gd state docstring 里从未存在过的幽灵字段示例（已披露）。两条扫描 0 命中；17/17 + main + 6 demo 干净。
- Review: de5c4067 → Spec ✅ / Approved。minor (deferred): §5 示意与实现的 `as EraEvent` vs `Variant` 措辞略宽（已标注“示意”）；README 规则句强调面与 engine-v1 不对称（不矛盾）。
- Task 4: complete（tests: 17/17 + main + 6 demo 干净，review clean；用户 F5 手动验收 pending-user）

## Final whole-branch review

- Reviewer: 3176c2d6 → **Deliverable: Ready**。Spec §1–§10 逐节 ✅；五条 Review Focus 全 COVERED（含独立重跑最终门：17/17 + main + 6 demo = 24 场景 0 失败 0 脚本错误）；交叉一致性（kojo 继承、每事件打包、run(null)、demo 装配可见性）全部成立；延后 Minor 全部判定 DEFER（测试专用/响亮失败/纯外观）。
- Ruling-6（终审后处置）: ① 补记本条 Task 4 账目（终审发现的记账遗漏，controller 自身职责，非代码修复）；② 本项目无 git，工作区快照/报告/review 包就是唯一审计记录——**不删除工作区**（与 SDD 默认“git 历史即记录”不同）；③ 终审指出 final 包漏拷 .gd.uid（Ruling-5 执行滑漏，纯外观，记录在案）。
- 交付条件：仅剩用户 F5 手动验收（plan Task 4 Step 4，by design 留给人类）。
- 2026-10-31：用户 F5 手动验收**通过**，计划全部 checkbox 完成，本改造正式收官。
