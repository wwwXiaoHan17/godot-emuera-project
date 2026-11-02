# SDD ledger — plan: docs/superpowers/plans/2026-10-25-engine-boundaries.md

## Setup

- 2026-10-26: plan/spec read; no git repository → no worktree/commit; plan's Global Constraints confirmed this. Workspace/ledger kept under `docs/superpowers/progress/` instead of `.superpowers/sdd/` (no git to ignore it).
- Baseline: 16 `check_*.tscn` all `CHECK OK` before Task 1.

## Pre-flight

- Task 1 → Task 2: Task 1 provides `CharacterComponent.display_name/get_display_name()/component_type()`; Task 2 consumes `component(AgeComponent)` — compatible, no conflict.
- Task 1 → Task 3: Task 1 removes `context_key/get_context_key/get_component`; Task 3 adds `RelationComponent` and uses `component(RelationComponent)` — compatible.
- Task 3 → Task 6: Task 3 moves relation reads to `RelationComponent`; Task 6's `KojoContext` examples only use `speaker.name_for(player)` — compatible, no direct relation-field dependency.
- Task 2 → Task 7: Task 2 removes `Character.age`; Task 7 does not reference `age` — compatible.
- Task 4 → Task 7: Task 4's `show_screen(scene, data)` remains through Task 7 — compatible.
- Task 6 → Task 7: Task 6 uses English kojo event IDs; Task 7 migrates remaining program IDs — compatible, Task 7 includes kojo IDs in its sweep.
- Plan's per-task “用户审阅” steps are kept as gates; the user asked to follow this plan and their established workflow requires review. Continuous no-check-in from the executing-plans skill is overridden by the plan's explicit gate.

## Task 1: 组件类型身份与显示名

- Ruling: no git → skip worktree/commit and use check pass + user review as the task completion signal, per plan Global Constraints. Cost if wrong: no commit history; plan already forbids git init.
- Step 1: `check_character` extended with `SlimeLifeComponent extends LifeComponent` and `FakeLifeComponent` (same “生命” display name). Assertions cover subclass lookup, subclass replacing base identity, unrelated same-display-name coexistence, empty display-name fallback, type removal, and repeated add/remove index rebuild.
- Step 2 RED: `check_character` failed to parse on missing `display_name`, `get_display_name()`, `component_type()`, and `remove_component(Script)`; exactly the planned missing interfaces.
- Step 3 GREEN: added `CharacterComponent.display_name/get_display_name()/component_type()`; `LifeComponent.component_type()` returns `LifeComponent`; `Character` index keyed by `Script` identity plus base-script chain, rebuilt on add/remove; removed `context_key/get_context_key/component_key/get_component`; migrated components, prototypes and `show_component`.
- Step 4: `check_character` → `CHECK OK`; `demo_show_component` headless no script errors; full 16-check suite → 16/16 `CHECK OK`.
- Ruling: user requested `component()` → `get_component()` for clearer semantics after removing the old key-based `get_component()`; renamed the method and all 47 call sites/tests/docs, updated spec §4.1 and Plan Task 1/6 references. Cost if wrong: any external caller using `.component()` breaks; project is self-contained and full suite is green.
- Task 1: complete (tests: 16 checks → 16/16 CHECK OK) — awaiting user review per plan Step 5.

## Task 2: AgeComponent 与 Character 瘦身

- Step 1: `check_character` now asserts `AgeComponent.display_name == "年龄"`, default `value == 18`, a new `Character` has no `AgeComponent`, and no `age` script property; `check_day_start` reads `AgeComponent.value == 21`; `_drive_kojo_buttons` prints `picked=<value>` instead of abusing `Character.age`; `check_kojo_buttons` asserts that row.
- Step 2 RED: `check_day_start` and `check_character` parse-failed on undeclared `AgeComponent`; exactly the planned missing type.
- Step 3 GREEN: added `age_component.gd`; removed `Character.age` and its spawn copy; installed `AgeComponent` only on the daughter prototype; `new_game`, `character_create` and `day_start` read/write age via the component; no `Character.age` refs remain.
- Ruling: daughter prototype contained a historical `null` entry in `components` (not introduced by this task); cleaned it while re-saving the prototype. Cost if wrong: none; lookup already skipped null and the re-save preserves all real components.
- Step 4: `check_character`, `check_day_start`, `check_kojo_buttons` → `CHECK OK`; full 16-check suite → 16/16; main/demos headless no script errors.
- Task 2: complete (tests: 16 checks → 16/16 CHECK OK) — awaiting user review per plan Step 5.

## Task 3: RelationComponent 合并关系数据与规则

- Step 1: `check_relations` rewritten around `RelationComponent`: prototype relation values, spawn independence, directional values, range clamp, `relation_changed` payload/count (no duplicate when unchanged), callname fallback/custom, missing-component fallback, `CharacterBook`.
- Step 2 RED: `check_relations` parse-failed on undeclared `RelationComponent`; exactly the planned missing type.
- Step 3 GREEN: added `relation_component.gd` with `relations/min_value/max_value`, clamp+signal on real changes; added `CharacterComponent.duplicate_for_spawn()` and `RelationEntry.duplicate_entry()`; `Character.spawn()` now delegates to `duplicate_for_spawn()`; removed `Character.relations` and all relation methods; `Character.name_for()` reads the optional component and keeps fallback.
- Step 4: migrated prototype relation arrays into `RelationComponent` via a one-off tool; removed root `relations`; removed `AffectionComponent` from the daughter prototype and deleted its script/UID; migrated `day_start`, `character_panel`, kojo, demos and tests; cleaned historical `null` component entries from prototypes.
- Ruling: migration tool ran while the old `Character.relations` field still existed, then the field was removed and prototypes re-saved. Cost if wrong: a stale root `relations` property would be ignored/cleaned; all prototypes load and checks pass.
- Step 5: `check_character`, `check_relations`, `check_kojo`, `check_day_start` → `CHECK OK`; full 16-check suite → 16/16; main + demo_character/demo_relations/demo_kojo/demo_show_component headless no script errors.
- Task 3: complete (tests: 16 checks → 16/16 CHECK OK) — awaiting user review per plan Step 6.

## Task 4: 挂载页面显式输入

- Step 1: `check_character_create` now calls `configure({"display_name": "初始名", "age": 20})` before `add_child`, asserts control prefill, puts a different daughter name in `Era.state` to prove isolation, asserts English result keys (`display_name`/`age`), and verifies an unconfigured page refuses to finish.
- Step 2 RED: `Nonexistent function 'configure'` on the page.
- Step 3 GREEN: `EraScreenPage.configure(data)` added; `Era.show_screen(scene, data = {})` calls `configure()` before the page enters the tree; `CharacterCreate` validates input (String / int 1–99), stores it, applies controls in `_ready`, refuses `finished` when unconfigured, and emits `{"display_name", "age"}`; `new_game` prepares input from daughter + `AgeComponent` and handles English result keys.
- Step 4: `check_character_create` and `check_day_start` → `CHECK OK`; `content/screens/*.gd` contains 0 `Era.state` refs; full 16-check suite → 16/16; main headless no script errors.
- Ruling: `check_day_start` emits English result keys directly; it simulates the page signal, and the real page now emits the same keys. Cost if wrong: a stale Chinese-key test would fail visibly.
- Task 4: complete (tests: 16 checks → 16/16 CHECK OK) — awaiting user review per plan Step 5.

## Task 5: 事件重启与局部循环

- Step 1: added `check_event_flow` with two inner events. Restart records local count `[1,1]`, mutates life 100→90, returns `get_script()`, and second visit returns null; loop records `[1,2]` in one instance and finishes after the second display. Driven through real `Era.input()`.
- Step 2: characteristic check passed on the current engine (`CHECK OK`), so no engine change was needed before content refactor.
- Step 3: `title` self-jumps now `return get_script() as GDScript`; `day_start` removed its self-preload and uses `get_script()`; `character_panel` keeps `while true`, drops `load(SelfPath)`, and only returns `DayStart` when leaving.
- Step 4: `check_event_flow`, `check_title`, `check_day_start` → `CHECK OK`; full suite now 17 checks → 17/17 `CHECK OK`.
- Ruling: `check_event_flow` uses test-only inner events, including a second-visit stop condition; test does not directly call `run()`. Cost if wrong: test semantics are narrower than production, but production content checks (`title`, `day_start`, panel) cover the real paths.
- Task 5: complete (tests: 17 checks → 17/17 CHECK OK) — awaiting user review per plan Step 5.

## Task 6: KojoContext 与口上英文 ID

- Step 1: added `_kojo_context_probe.gd` (records the context and returns `extras["partner"]`); extended `check_kojo` with fixed `speaker/player/state`, malicious same-name extras (`speaker/player/state`) that must not override fixed fields, extra `other=42`, and `probe` return value. Migrated kojo tests to `morning/after_training/act_cute/daily/caress`.
- Step 2 RED: `KojoContext` undeclared in `check_kojo.gd`/probe.
- Step 3 GREEN: added `kojo_context.gd`; `Era.kojo(character, event_name, extras = {})` builds a fresh `KojoContext` and duplicates extras; removed the merged Chinese-key Dictionary; `女儿_kojo.gd` functions take `KojoContext`, use `speaker/player/state`, and register English IDs; `_爱抚` renamed `_caress`.
- Step 4: `check_kojo`, `check_kojo_buttons` → `CHECK OK`; `demo_kojo` headless no script errors; full suite 17/17.
- Ruling: `extras` are deep-duplicated (`duplicate(true)`) rather than shallow; fixed fields are separate properties so collisions cannot override them. Cost if wrong: nested temporary objects are copied, which is safer but may differ if callers expect reference identity.
- Task 6: complete (tests: 17 checks → 17/17 CHECK OK) — awaiting user review per plan Step 5.

## Task 7: 英文标识符与程序 ID 统一

- Step 1: scanned declarations (`var/func/const/signal/for`), StringName literals, prototype ids/targets, talent ids and state/component fields. Classified player-visible Chinese/comment text/resource filenames as out of scope; migrated identifiers and program IDs.
- Step 2: `GameState.角色簿` → `character_book` everywhere; `LifeComponent`/`StaminaComponent` `值/上限` → `value/max_value` including `.tres` and `_mark_changed` keys; no aliases.
- Step 3: character ids/targets → `player/daughter/maid/father`; talent ids → `ignorant/childish/precocious/sexually_repressed/weak_bladder` with conflicts updated; test ids → `prototype/daughter_copy/test_character/stranger` (+`you` for the fallback fixture); `father.tres` gained `id = &"father"`; experiment C main/page keys and identifiers migrated.
- Step 4: 17 checks → 17/17 `CHECK OK`; added father prototype id assertion to `check_relations` (still green); all demo scenes + main + experiment C headless parse/run without script errors; final scan for Chinese declarations/StringNames is empty.
- Ruling: broad mechanical replacement of `&"玩家/女儿/女仆/父亲"` was scoped to StringName literals in `.gd/.tres`; Chinese display names, dialogue, button labels and resource filenames were intentionally untouched. Cost if wrong: any external program contract using Chinese ids would break; project is self-contained and full suite is green.
- Task 7: complete (tests: 17 checks → 17/17 CHECK OK) — awaiting user review per plan Step 5.

## Task 8: 文档同步与最终验收

- Step 1: rewrote `docs/character-system-design.md` to the final model (type identity/display_name, optional Age/Relation, `RelationComponent`, `duplicate_for_spawn`, `KojoContext`, configured pages, event semantics, English IDs). Updated `docs/engine-v1-design.md` command table/state example/data section/event semantics/naming. Updated `docs/README.md` links, demo list and 17-check baseline.
- Step 2: stale-interface scan over engine/content/tests + current design docs returned 0 real hits after rephrasing one doc sentence that intentionally described removed APIs. `get_component(type)` is current API (user ruling), not stale; old key-based form has 0 hits.
- Step 3: 17/17 `CHECK OK`; main + 6 demos + experiment C headless no script errors. Removed broken leftover `tests/demo_grid_a.tscn` (referenced a deleted `demo_grid_a.gd`) discovered during full demo verification.
- Step 4: simulated full F5 chain (title → new_game → character page → talent → day 1 → panel → back → component list) and captured `experiment/shots/final_day2.png`, `final_panel2.png`, `final_components2.png`. Found one manual-acceptance regression: talent UI showed program ID `childish`; fixed `TalentListComponent.text()` to map IDs back to Chinese display names, added assertions in `check_day_start` / `check_talent_select`, and re-captured.
- Ruling: Task 8's stale-scan literal `get_component` would flag the current type-based API because the plan predates the user's rename request; scan checks the old key-based call form instead. Cost if wrong: a stale key-based usage could hide behind the same name; grep for `get_component(&` is empty.
- Task 8: complete (tests: 17 checks → 17/17 CHECK OK; manual F5 screenshots reviewed) — awaiting user acceptance per plan Step 5.

## Final acceptance

- 2026-10-26: user accepted the engine boundaries refactor. Plan `docs/superpowers/plans/2026-10-25-engine-boundaries.md` all checkboxes complete.
- Final evidence: 17/17 `check_*.tscn` `CHECK OK`; main + 6 demos + experiment C headless no script errors; stale-interface scan 0 hits; F5 chain screenshots `experiment/shots/final_day2.png`, `final_panel2.png`, `final_components2.png`.
- Deferred/known limits: `SexyComponent` level thresholds/rules WIP; father prototype placeholder; no save system.

