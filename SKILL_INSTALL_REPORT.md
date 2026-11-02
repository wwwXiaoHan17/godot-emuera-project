# Kimi Code Skill 安装报告

- 日期：2026-10-25
- 目标目录：`C:\Users\30873\.kimi-code\skills`
- 保留并复用官方共享目录：`C:\Users\30873\.agents\skills`
- 原始 Skill：未删除、未移动、未修改
- 全局配置：未修改 `config.toml`，未增加 `extra_skill_dirs`，未安装任何远程或可执行文件

## 1. 结果汇总

- 发现的 Skill 总数：**276**（递归计算每个含合法 `SKILL.md` 的目录，包含一个嵌套的 `godot-master`）。
- 本次成功安装并注册：**12**。
- 跳过：**260**（原生已可用 125；内容完全相同 135）。
- 不兼容/需适配、未安装：**4**。
- 失败：**0**。
- 当前 Kimi Code 用户级可发现 Skill：**137**（125 个原有 + 12 个新装，不含内置 Skill），名称大小写不敏感唯一。

“成功”只统计本次新复制并注册的目录；已位于官方扫描目录及内容相同的副本计入“跳过”，不重复占用名称。

### 按来源统计

| 来源体系 | 发现 | 新安装 | 原生可用跳过 | 相同内容跳过 | 不兼容/需适配 | 失败 |
|---|---:|---:|---:|---:|---:|---:|
| DSH | 123 | 4 | 0 | 116 | 3 | 0 |
| Claude | 12 | 3 | 0 | 9 | 0 | 0 |
| Codex | 16 | 5 | 0 | 10 | 1 | 0 |
| 其他 | 125 | 0 | 125 | 0 | 0 | 0 |

## 2. 官方安装约定与扫描范围

官方文档确认目录式 Skill 使用 `<skill-dir>/SKILL.md`，frontmatter 必须显式包含 `name`、`description`；默认用户目录为 `$KIMI_CODE_HOME/skills`，未设置时为 `~/.kimi-code/skills`。`~/.agents/skills` 也是官方用户级扫描目录，因此其中内容无需再复制。作用域优先级为 Project > User > Extra > Built-in。

- 官方 Skill 文档：https://www.kimi.com/code/docs/en/kimi-code-cli/customization/skills.html
- 官方数据目录文档：https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/data-locations.html
- `KIMI_CODE_HOME` 未设置；`DSH_HOME`、`DSH_SKILLS_DIR` 未设置。
- `kimi --help`：当前 Git Bash 的 `PATH` 中找不到 `kimi`，故没有虚构 CLI 验证结果；改用 Kimi Code Desktop 的实际 Skill 目录刷新与真实调用验证。
- `dsh --help`：通过 `E:\MyTools\Deepseek Harness\resources\runtime\cli\bin\dsh.cmd` 执行成功；没有 `skills list` 子命令。
- 已扫描 `~/.dsh/skills`、DSH 安装根目录、`~/Documents/deepseek-harness`、`~/.claude/skills`、`~/.codex/skills`、`~/.agents/skills`，以及工作区指定的 `.dsh/skills`、`.claude/skills`、`.agents/skills`、`skills/`。Documents 与工作区指定目录没有发现额外 `SKILL.md`。

## 3. 本次新安装的 Skill

| Skill 名称 | 来源体系 | 来源路径 | 安装路径 | 状态 | 备注 |
|---|---|---|---|---|---|
| office | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office | C:\Users\30873\.kimi-code\skills\office | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Kimi Skill 调用；渲染/PDF/重算路由因对应 3 项未安装而不可用 |
| office-docx | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office-docx | C:\Users\30873\.kimi-code\skills\office-docx | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12（DSH bundled 可用）；所需 Office 库已具备；load_workspace_dependencies 用现有 Python 替代；present 用工作区路径替代 |
| office-pptx | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office-pptx | C:\Users\30873\.kimi-code\skills\office-pptx | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12（DSH bundled 可用）；所需 Office 库已具备；load_workspace_dependencies 用现有 Python 替代；present 用工作区路径替代 |
| office-xlsx | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office-xlsx | C:\Users\30873\.kimi-code\skills\office-xlsx | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12（DSH bundled 可用）；所需 Office 库已具备；load_workspace_dependencies 用现有 Python 替代；present 用工作区路径替代 |
| cocoloop | Claude | C:\Users\30873\.claude\skills\cocoloop | C:\Users\30873\.kimi-code\skills\cocoloop | 成功（已安装） | 完整复制可迁移文件并安装；依赖：curl/git/node/npm/npx 可用；网络安装/更新仅按需，不在本次执行 |
| godot-master → godot-master-imported | Claude | C:\Users\30873\.claude\skills\godot-master | C:\Users\30873\.kimi-code\skills\godot-master-imported | 成功（冲突改名） | 与现有 godot-master 内容不同；保留现有版本并改名安装；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| xai-search | Claude | C:\Users\30873\.claude\skills\xai-search | C:\Users\30873\.kimi-code\skills\xai-search | 成功（已安装） | 完整复制可迁移文件并安装；依赖：XAI_API_KEY 已设置；curl 可用；xai-sdk、jq 缺失（对应路径暂不可用） |
| godot-master → godot-master-imported-2 | Codex | C:\Users\30873\.codex\skills\godot-master | C:\Users\30873\.kimi-code\skills\godot-master-imported-2 | 成功（冲突改名） | 第三份同名但内容不同的 godot-master；保留已有两版，使用扩展冲突名 godot-master-imported-2 安装；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| openai-docs | Codex | C:\Users\30873\.codex\skills\.system\openai-docs | C:\Users\30873\.kimi-code\skills\openai-docs | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Node 可用；OpenAI Docs MCP 未配置，可用 Kimi 官方域名 Web 回退；Codex 手册 helper 可用 |
| plugin-creator | Codex | C:\Users\30873\.codex\skills\.system\plugin-creator | C:\Users\30873\.kimi-code\skills\plugin-creator | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12 可用；PyYAML 缺失，验证脚本暂不能运行；面向 Codex 产物 |
| skill-creator | Codex | C:\Users\30873\.codex\skills\.system\skill-creator | C:\Users\30873\.kimi-code\skills\skill-creator | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12 可用；PyYAML 缺失，验证脚本暂不能运行；面向 Codex 产物 |
| skill-installer | Codex | C:\Users\30873\.codex\skills\.system\skill-installer | C:\Users\30873\.kimi-code\skills\skill-installer | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12、git 可用；仅标准库；面向 Codex 目录，网络操作按需 |

## 4. DSH Skill 迁移结果（全部 123 项）

DSH 用户目录中的 116 项与 `~/.agents/skills` 已注册版本内容相同，因此全部安全跳过；Office 新装 4 项，3 项因 LibreOffice Kit 依赖未安装。DSH 的 `root-probe-user-dsh` 文案仍写“115 个”，但本次磁盘实际发现其用户目录有 116 个 Skill；以实际文件为准。

| Skill 名称 | 来源体系 | 来源路径 | 安装路径 | 状态 | 备注 |
|---|---|---|---|---|---|
| brainstorming | DSH | C:\Users\30873\.dsh\skills\brainstorming | C:\Users\30873\.agents\skills\brainstorming | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：git（可用）；其余按具体工作流 |
| diagnosing-superpowers | DSH | C:\Users\30873\.dsh\skills\diagnosing-superpowers | C:\Users\30873\.agents\skills\diagnosing-superpowers | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| dispatching-parallel-agents | DSH | C:\Users\30873\.dsh\skills\dispatching-parallel-agents | C:\Users\30873\.agents\skills\dispatching-parallel-agents | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| emuera-basic-agent-guide | DSH | C:\Users\30873\.dsh\skills\emuera-basic-agent-guide | C:\Users\30873\.agents\skills\emuera-basic-agent-guide | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| executing-plans | DSH | C:\Users\30873\.dsh\skills\executing-plans | C:\Users\30873\.agents\skills\executing-plans | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：git（可用）；其余按具体工作流 |
| finishing-a-development-branch | DSH | C:\Users\30873\.dsh\skills\finishing-a-development-branch | C:\Users\30873\.agents\skills\finishing-a-development-branch | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：git（可用）；其余按具体工作流 |
| godot-2d-animation | DSH | C:\Users\30873\.dsh\skills\godot-2d-animation | C:\Users\30873\.agents\skills\godot-2d-animation | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-2d-physics | DSH | C:\Users\30873\.dsh\skills\godot-2d-physics | C:\Users\30873\.agents\skills\godot-2d-physics | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-3d-lighting | DSH | C:\Users\30873\.dsh\skills\godot-3d-lighting | C:\Users\30873\.agents\skills\godot-3d-lighting | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-3d-materials | DSH | C:\Users\30873\.dsh\skills\godot-3d-materials | C:\Users\30873\.agents\skills\godot-3d-materials | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-3d-world-building | DSH | C:\Users\30873\.dsh\skills\godot-3d-world-building | C:\Users\30873\.agents\skills\godot-3d-world-building | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-ability-system | DSH | C:\Users\30873\.dsh\skills\godot-ability-system | C:\Users\30873\.agents\skills\godot-ability-system | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-adapt-2d-to-3d | DSH | C:\Users\30873\.dsh\skills\godot-adapt-2d-to-3d | C:\Users\30873\.agents\skills\godot-adapt-2d-to-3d | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-adapt-3d-to-2d | DSH | C:\Users\30873\.dsh\skills\godot-adapt-3d-to-2d | C:\Users\30873\.agents\skills\godot-adapt-3d-to-2d | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-adapt-desktop-to-mobile | DSH | C:\Users\30873\.dsh\skills\godot-adapt-desktop-to-mobile | C:\Users\30873\.agents\skills\godot-adapt-desktop-to-mobile | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-adapt-mobile-to-desktop | DSH | C:\Users\30873\.dsh\skills\godot-adapt-mobile-to-desktop | C:\Users\30873\.agents\skills\godot-adapt-mobile-to-desktop | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-adapt-single-to-multiplayer | DSH | C:\Users\30873\.dsh\skills\godot-adapt-single-to-multiplayer | C:\Users\30873\.agents\skills\godot-adapt-single-to-multiplayer | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-agent-vision | DSH | C:\Users\30873\.dsh\skills\godot-agent-vision | C:\Users\30873\.agents\skills\godot-agent-vision | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Python 3/Pillow（可用）；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-ai-navigation | DSH | C:\Users\30873\.dsh\skills\godot-ai-navigation | C:\Users\30873\.agents\skills\godot-ai-navigation | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-analyst | DSH | C:\Users\30873\.dsh\skills\godot-analyst | C:\Users\30873\.agents\skills\godot-analyst | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-animation-player | DSH | C:\Users\30873\.dsh\skills\godot-animation-player | C:\Users\30873\.agents\skills\godot-animation-player | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-animation-tree-mastery | DSH | C:\Users\30873\.dsh\skills\godot-animation-tree-mastery | C:\Users\30873\.agents\skills\godot-animation-tree-mastery | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-audio-systems | DSH | C:\Users\30873\.dsh\skills\godot-audio-systems | C:\Users\30873\.agents\skills\godot-audio-systems | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-auditor | DSH | C:\Users\30873\.dsh\skills\godot-auditor | C:\Users\30873\.agents\skills\godot-auditor | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-autoload-architecture | DSH | C:\Users\30873\.dsh\skills\godot-autoload-architecture | C:\Users\30873\.agents\skills\godot-autoload-architecture | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-builder | DSH | C:\Users\30873\.dsh\skills\godot-builder | C:\Users\30873\.agents\skills\godot-builder | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.7+；Python 3（可用）；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-camera-systems | DSH | C:\Users\30873\.dsh\skills\godot-camera-systems | C:\Users\30873\.agents\skills\godot-camera-systems | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-characterbody-2d | DSH | C:\Users\30873\.dsh\skills\godot-characterbody-2d | C:\Users\30873\.agents\skills\godot-characterbody-2d | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-combat-system | DSH | C:\Users\30873\.dsh\skills\godot-combat-system | C:\Users\30873\.agents\skills\godot-combat-system | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-composition | DSH | C:\Users\30873\.dsh\skills\godot-composition | C:\Users\30873\.agents\skills\godot-composition | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-composition-apps | DSH | C:\Users\30873\.dsh\skills\godot-composition-apps | C:\Users\30873\.agents\skills\godot-composition-apps | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-debugging-profiling | DSH | C:\Users\30873\.dsh\skills\godot-debugging-profiling | C:\Users\30873\.agents\skills\godot-debugging-profiling | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-dialogue-system | DSH | C:\Users\30873\.dsh\skills\godot-dialogue-system | C:\Users\30873\.agents\skills\godot-dialogue-system | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-economy-system | DSH | C:\Users\30873\.dsh\skills\godot-economy-system | C:\Users\30873\.agents\skills\godot-economy-system | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-export-builds | DSH | C:\Users\30873\.dsh\skills\godot-export-builds | C:\Users\30873\.agents\skills\godot-export-builds | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.7+；对应平台 SDK/导出模板（按需）；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-game-loop-collection | DSH | C:\Users\30873\.dsh\skills\godot-game-loop-collection | C:\Users\30873\.agents\skills\godot-game-loop-collection | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-game-loop-harvest | DSH | C:\Users\30873\.dsh\skills\godot-game-loop-harvest | C:\Users\30873\.agents\skills\godot-game-loop-harvest | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-game-loop-time-trial | DSH | C:\Users\30873\.dsh\skills\godot-game-loop-time-trial | C:\Users\30873\.agents\skills\godot-game-loop-time-trial | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-game-loop-waves | DSH | C:\Users\30873\.dsh\skills\godot-game-loop-waves | C:\Users\30873\.agents\skills\godot-game-loop-waves | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-gdscript-mastery | DSH | C:\Users\30873\.dsh\skills\godot-gdscript-mastery | C:\Users\30873\.agents\skills\godot-gdscript-mastery | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-action-rpg | DSH | C:\Users\30873\.dsh\skills\godot-genre-action-rpg | C:\Users\30873\.agents\skills\godot-genre-action-rpg | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-battle-royale | DSH | C:\Users\30873\.dsh\skills\godot-genre-battle-royale | C:\Users\30873\.agents\skills\godot-genre-battle-royale | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-card-game | DSH | C:\Users\30873\.dsh\skills\godot-genre-card-game | C:\Users\30873\.agents\skills\godot-genre-card-game | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-educational | DSH | C:\Users\30873\.dsh\skills\godot-genre-educational | C:\Users\30873\.agents\skills\godot-genre-educational | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-fighting | DSH | C:\Users\30873\.dsh\skills\godot-genre-fighting | C:\Users\30873\.agents\skills\godot-genre-fighting | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-horror | DSH | C:\Users\30873\.dsh\skills\godot-genre-horror | C:\Users\30873\.agents\skills\godot-genre-horror | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-idle-clicker | DSH | C:\Users\30873\.dsh\skills\godot-genre-idle-clicker | C:\Users\30873\.agents\skills\godot-genre-idle-clicker | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-metroidvania | DSH | C:\Users\30873\.dsh\skills\godot-genre-metroidvania | C:\Users\30873\.agents\skills\godot-genre-metroidvania | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-moba | DSH | C:\Users\30873\.dsh\skills\godot-genre-moba | C:\Users\30873\.agents\skills\godot-genre-moba | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-open-world | DSH | C:\Users\30873\.dsh\skills\godot-genre-open-world | C:\Users\30873\.agents\skills\godot-genre-open-world | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-party | DSH | C:\Users\30873\.dsh\skills\godot-genre-party | C:\Users\30873\.agents\skills\godot-genre-party | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-platformer | DSH | C:\Users\30873\.dsh\skills\godot-genre-platformer | C:\Users\30873\.agents\skills\godot-genre-platformer | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-puzzle | DSH | C:\Users\30873\.dsh\skills\godot-genre-puzzle | C:\Users\30873\.agents\skills\godot-genre-puzzle | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-racing | DSH | C:\Users\30873\.dsh\skills\godot-genre-racing | C:\Users\30873\.agents\skills\godot-genre-racing | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-rhythm | DSH | C:\Users\30873\.dsh\skills\godot-genre-rhythm | C:\Users\30873\.agents\skills\godot-genre-rhythm | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-roguelike | DSH | C:\Users\30873\.dsh\skills\godot-genre-roguelike | C:\Users\30873\.agents\skills\godot-genre-roguelike | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-romance | DSH | C:\Users\30873\.dsh\skills\godot-genre-romance | C:\Users\30873\.agents\skills\godot-genre-romance | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-rts | DSH | C:\Users\30873\.dsh\skills\godot-genre-rts | C:\Users\30873\.agents\skills\godot-genre-rts | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-sandbox | DSH | C:\Users\30873\.dsh\skills\godot-genre-sandbox | C:\Users\30873\.agents\skills\godot-genre-sandbox | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-shooter | DSH | C:\Users\30873\.dsh\skills\godot-genre-shooter | C:\Users\30873\.agents\skills\godot-genre-shooter | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-shooter-fps | DSH | C:\Users\30873\.dsh\skills\godot-genre-shooter-fps | C:\Users\30873\.agents\skills\godot-genre-shooter-fps | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-simulation | DSH | C:\Users\30873\.dsh\skills\godot-genre-simulation | C:\Users\30873\.agents\skills\godot-genre-simulation | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-sports | DSH | C:\Users\30873\.dsh\skills\godot-genre-sports | C:\Users\30873\.agents\skills\godot-genre-sports | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-stealth | DSH | C:\Users\30873\.dsh\skills\godot-genre-stealth | C:\Users\30873\.agents\skills\godot-genre-stealth | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-survival | DSH | C:\Users\30873\.dsh\skills\godot-genre-survival | C:\Users\30873\.agents\skills\godot-genre-survival | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-tower-defense | DSH | C:\Users\30873\.dsh\skills\godot-genre-tower-defense | C:\Users\30873\.agents\skills\godot-genre-tower-defense | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-visual-novel | DSH | C:\Users\30873\.dsh\skills\godot-genre-visual-novel | C:\Users\30873\.agents\skills\godot-genre-visual-novel | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-input-handling | DSH | C:\Users\30873\.dsh\skills\godot-input-handling | C:\Users\30873\.agents\skills\godot-input-handling | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-inventory-system | DSH | C:\Users\30873\.dsh\skills\godot-inventory-system | C:\Users\30873\.agents\skills\godot-inventory-system | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-master | DSH | C:\Users\30873\.dsh\skills\godot-master | C:\Users\30873\.agents\skills\godot-master | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-mechanic-revival | DSH | C:\Users\30873\.dsh\skills\godot-mechanic-revival | C:\Users\30873\.agents\skills\godot-mechanic-revival | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-mechanic-secrets | DSH | C:\Users\30873\.dsh\skills\godot-mechanic-secrets | C:\Users\30873\.agents\skills\godot-mechanic-secrets | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-monte-carlo-balancer | DSH | C:\Users\30873\.dsh\skills\godot-monte-carlo-balancer | C:\Users\30873\.agents\skills\godot-monte-carlo-balancer | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Rust/Cargo/rayon（Cargo 不在 PATH）；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-multiplayer-networking | DSH | C:\Users\30873\.dsh\skills\godot-multiplayer-networking | C:\Users\30873\.agents\skills\godot-multiplayer-networking | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-navigation-pathfinding | DSH | C:\Users\30873\.dsh\skills\godot-navigation-pathfinding | C:\Users\30873\.agents\skills\godot-navigation-pathfinding | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-particles | DSH | C:\Users\30873\.dsh\skills\godot-particles | C:\Users\30873\.agents\skills\godot-particles | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-performance-optimization | DSH | C:\Users\30873\.dsh\skills\godot-performance-optimization | C:\Users\30873\.agents\skills\godot-performance-optimization | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-physics-3d | DSH | C:\Users\30873\.dsh\skills\godot-physics-3d | C:\Users\30873\.agents\skills\godot-physics-3d | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-platform-console | DSH | C:\Users\30873\.dsh\skills\godot-platform-console | C:\Users\30873\.agents\skills\godot-platform-console | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-platform-desktop | DSH | C:\Users\30873\.dsh\skills\godot-platform-desktop | C:\Users\30873\.agents\skills\godot-platform-desktop | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-platform-mobile | DSH | C:\Users\30873\.dsh\skills\godot-platform-mobile | C:\Users\30873\.agents\skills\godot-platform-mobile | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-platform-vr | DSH | C:\Users\30873\.dsh\skills\godot-platform-vr | C:\Users\30873\.agents\skills\godot-platform-vr | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-platform-web | DSH | C:\Users\30873\.dsh\skills\godot-platform-web | C:\Users\30873\.agents\skills\godot-platform-web | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-procedural-generation | DSH | C:\Users\30873\.dsh\skills\godot-procedural-generation | C:\Users\30873\.agents\skills\godot-procedural-generation | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-project-foundations | DSH | C:\Users\30873\.dsh\skills\godot-project-foundations | C:\Users\30873\.agents\skills\godot-project-foundations | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-project-templates | DSH | C:\Users\30873\.dsh\skills\godot-project-templates | C:\Users\30873\.agents\skills\godot-project-templates | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-quest-system | DSH | C:\Users\30873\.dsh\skills\godot-quest-system | C:\Users\30873\.agents\skills\godot-quest-system | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-raycasting-queries | DSH | C:\Users\30873\.dsh\skills\godot-raycasting-queries | C:\Users\30873\.agents\skills\godot-raycasting-queries | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-resource-data-patterns | DSH | C:\Users\30873\.dsh\skills\godot-resource-data-patterns | C:\Users\30873\.agents\skills\godot-resource-data-patterns | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-rpg-stats | DSH | C:\Users\30873\.dsh\skills\godot-rpg-stats | C:\Users\30873\.agents\skills\godot-rpg-stats | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-save-load-systems | DSH | C:\Users\30873\.dsh\skills\godot-save-load-systems | C:\Users\30873\.agents\skills\godot-save-load-systems | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-scene-management | DSH | C:\Users\30873\.dsh\skills\godot-scene-management | C:\Users\30873\.agents\skills\godot-scene-management | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-server-architecture | DSH | C:\Users\30873\.dsh\skills\godot-server-architecture | C:\Users\30873\.agents\skills\godot-server-architecture | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-shaders-basics | DSH | C:\Users\30873\.dsh\skills\godot-shaders-basics | C:\Users\30873\.agents\skills\godot-shaders-basics | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-signal-architecture | DSH | C:\Users\30873\.dsh\skills\godot-signal-architecture | C:\Users\30873\.agents\skills\godot-signal-architecture | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-state-machine-advanced | DSH | C:\Users\30873\.dsh\skills\godot-state-machine-advanced | C:\Users\30873\.agents\skills\godot-state-machine-advanced | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-testing-patterns | DSH | C:\Users\30873\.dsh\skills\godot-testing-patterns | C:\Users\30873\.agents\skills\godot-testing-patterns | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；GdUnit4；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-theme-easter | DSH | C:\Users\30873\.dsh\skills\godot-theme-easter | C:\Users\30873\.agents\skills\godot-theme-easter | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-tilemap-mastery | DSH | C:\Users\30873\.dsh\skills\godot-tilemap-mastery | C:\Users\30873\.agents\skills\godot-tilemap-mastery | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-turn-system | DSH | C:\Users\30873\.dsh\skills\godot-turn-system | C:\Users\30873\.agents\skills\godot-turn-system | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-tweening | DSH | C:\Users\30873\.dsh\skills\godot-tweening | C:\Users\30873\.agents\skills\godot-tweening | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-ui-containers | DSH | C:\Users\30873\.dsh\skills\godot-ui-containers | C:\Users\30873\.agents\skills\godot-ui-containers | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-ui-rich-text | DSH | C:\Users\30873\.dsh\skills\godot-ui-rich-text | C:\Users\30873\.agents\skills\godot-ui-rich-text | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-ui-theming | DSH | C:\Users\30873\.dsh\skills\godot-ui-theming | C:\Users\30873\.agents\skills\godot-ui-theming | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-version-migration | DSH | C:\Users\30873\.dsh\skills\godot-version-migration | C:\Users\30873\.agents\skills\godot-version-migration | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |
| receiving-code-review | DSH | C:\Users\30873\.dsh\skills\receiving-code-review | C:\Users\30873\.agents\skills\receiving-code-review | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| requesting-code-review | DSH | C:\Users\30873\.dsh\skills\requesting-code-review | C:\Users\30873\.agents\skills\requesting-code-review | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：git（可用）；其余按具体工作流 |
| root-probe-user-dsh | DSH | C:\Users\30873\.dsh\skills\root-probe-user-dsh | C:\Users\30873\.agents\skills\root-probe-user-dsh | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| subagent-driven-development | DSH | C:\Users\30873\.dsh\skills\subagent-driven-development | C:\Users\30873\.agents\skills\subagent-driven-development | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：git（可用）；其余按具体工作流 |
| systematic-debugging | DSH | C:\Users\30873\.dsh\skills\systematic-debugging | C:\Users\30873\.agents\skills\systematic-debugging | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：git（可用）；其余按具体工作流 |
| test-driven-development | DSH | C:\Users\30873\.dsh\skills\test-driven-development | C:\Users\30873\.agents\skills\test-driven-development | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| using-git-worktrees | DSH | C:\Users\30873\.dsh\skills\using-git-worktrees | C:\Users\30873\.agents\skills\using-git-worktrees | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：git（可用）；其余按具体工作流 |
| using-superpowers | DSH | C:\Users\30873\.dsh\skills\using-superpowers | C:\Users\30873\.agents\skills\using-superpowers | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：git（可用）；其余按具体工作流 |
| verification-before-completion | DSH | C:\Users\30873\.dsh\skills\verification-before-completion | C:\Users\30873\.agents\skills\verification-before-completion | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| writing-plans | DSH | C:\Users\30873\.dsh\skills\writing-plans | C:\Users\30873\.agents\skills\writing-plans | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：git（可用）；其余按具体工作流 |
| writing-skills | DSH | C:\Users\30873\.dsh\skills\writing-skills | C:\Users\30873\.agents\skills\writing-skills | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：git（可用）；其余按具体工作流 |
| office | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office | C:\Users\30873\.kimi-code\skills\office | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Kimi Skill 调用；渲染/PDF/重算路由因对应 3 项未安装而不可用 |
| office-docx | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office-docx | C:\Users\30873\.kimi-code\skills\office-docx | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12（DSH bundled 可用）；所需 Office 库已具备；load_workspace_dependencies 用现有 Python 替代；present 用工作区路径替代 |
| office-export-pdf | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office-export-pdf | — | 不兼容/需适配（未安装） | 缺少 LibreOffice Kit sidecar；DSH 的绝对 Node/CLI 路径未提供给 Kimi Code，需适配后再安装；依赖：缺 LibreOffice Kit sidecar 与 DSH 注入的绝对 Node/CLI 路径；未安装 |
| office-pptx | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office-pptx | C:\Users\30873\.kimi-code\skills\office-pptx | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12（DSH bundled 可用）；所需 Office 库已具备；load_workspace_dependencies 用现有 Python 替代；present 用工作区路径替代 |
| office-recalculate | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office-recalculate | — | 不兼容/需适配（未安装） | 缺少 LibreOffice Kit sidecar；DSH 的绝对 Node/CLI 路径未提供给 Kimi Code，需适配后再安装；依赖：缺 LibreOffice Kit sidecar 与 DSH 注入的绝对 Node/CLI 路径；未安装 |
| office-render | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office-render | — | 不兼容/需适配（未安装） | 缺少 LibreOffice Kit sidecar；DSH 的绝对 Node/CLI 路径未提供给 Kimi Code，需适配后再安装；依赖：缺 LibreOffice Kit sidecar 与 DSH 注入的绝对 Node/CLI 路径；未安装 |
| office-xlsx | DSH | E:\MyTools\Deepseek Harness\resources\runtime\office-skills\office-xlsx | C:\Users\30873\.kimi-code\skills\office-xlsx | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12（DSH bundled 可用）；所需 Office 库已具备；load_workspace_dependencies 用现有 Python 替代；present 用工作区路径替代 |

## 5. 其他来源明细

### Claude

| Skill 名称 | 来源体系 | 来源路径 | 安装路径 | 状态 | 备注 |
|---|---|---|---|---|---|
| cocoloop | Claude | C:\Users\30873\.claude\skills\cocoloop | C:\Users\30873\.kimi-code\skills\cocoloop | 成功（已安装） | 完整复制可迁移文件并安装；依赖：curl/git/node/npm/npx 可用；网络安装/更新仅按需，不在本次执行 |
| godot-master → godot-master-imported | Claude | C:\Users\30873\.claude\skills\godot-master | C:\Users\30873\.kimi-code\skills\godot-master-imported | 成功（冲突改名） | 与现有 godot-master 内容不同；保留现有版本并改名安装；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| tavily-best-practices | Claude | C:\Users\30873\.claude\skills\tavily-best-practices | C:\Users\30873\.agents\skills\tavily-best-practices | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-cli | Claude | C:\Users\30873\.claude\skills\tavily-cli | C:\Users\30873\.agents\skills\tavily-cli | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-crawl | Claude | C:\Users\30873\.claude\skills\tavily-crawl | C:\Users\30873\.agents\skills\tavily-crawl | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-dynamic-search | Claude | C:\Users\30873\.claude\skills\tavily-dynamic-search | C:\Users\30873\.agents\skills\tavily-dynamic-search | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-extract | Claude | C:\Users\30873\.claude\skills\tavily-extract | C:\Users\30873\.agents\skills\tavily-extract | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-map | Claude | C:\Users\30873\.claude\skills\tavily-map | C:\Users\30873\.agents\skills\tavily-map | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-research | Claude | C:\Users\30873\.claude\skills\tavily-research | C:\Users\30873\.agents\skills\tavily-research | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-search | Claude | C:\Users\30873\.claude\skills\tavily-search | C:\Users\30873\.agents\skills\tavily-search | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| xai-search | Claude | C:\Users\30873\.claude\skills\xai-search | C:\Users\30873\.kimi-code\skills\xai-search | 成功（已安装） | 完整复制可迁移文件并安装；依赖：XAI_API_KEY 已设置；curl 可用；xai-sdk、jq 缺失（对应路径暂不可用） |
| godot-master | Claude | C:\Users\30873\.claude\skills\godot-master\godot-master | C:\Users\30873\.agents\skills\godot-master | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |

### Codex

| Skill 名称 | 来源体系 | 来源路径 | 安装路径 | 状态 | 备注 |
|---|---|---|---|---|---|
| cocoloop | Codex | C:\Users\30873\.codex\skills\cocoloop | C:\Users\30873\.kimi-code\skills\cocoloop | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：curl/git/node/npm/npx 可用；网络安装/更新仅按需，不在本次执行 |
| godot-master → godot-master-imported-2 | Codex | C:\Users\30873\.codex\skills\godot-master | C:\Users\30873\.kimi-code\skills\godot-master-imported-2 | 成功（冲突改名） | 第三份同名但内容不同的 godot-master；保留已有两版，使用扩展冲突名 godot-master-imported-2 安装；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| tavily-best-practices | Codex | C:\Users\30873\.codex\skills\tavily-best-practices | C:\Users\30873\.agents\skills\tavily-best-practices | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-cli | Codex | C:\Users\30873\.codex\skills\tavily-cli | C:\Users\30873\.agents\skills\tavily-cli | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-crawl | Codex | C:\Users\30873\.codex\skills\tavily-crawl | C:\Users\30873\.agents\skills\tavily-crawl | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-dynamic-search | Codex | C:\Users\30873\.codex\skills\tavily-dynamic-search | C:\Users\30873\.agents\skills\tavily-dynamic-search | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-extract | Codex | C:\Users\30873\.codex\skills\tavily-extract | C:\Users\30873\.agents\skills\tavily-extract | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-map | Codex | C:\Users\30873\.codex\skills\tavily-map | C:\Users\30873\.agents\skills\tavily-map | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-research | Codex | C:\Users\30873\.codex\skills\tavily-research | C:\Users\30873\.agents\skills\tavily-research | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-search | Codex | C:\Users\30873\.codex\skills\tavily-search | C:\Users\30873\.agents\skills\tavily-search | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| xai-search | Codex | C:\Users\30873\.codex\skills\xai-search | C:\Users\30873\.kimi-code\skills\xai-search | 跳过（内容相同） | 与已注册同名 Skill 的全部有效文件内容相同，跳过复制；依赖：XAI_API_KEY 已设置；curl 可用；xai-sdk、jq 缺失（对应路径暂不可用） |
| imagegen | Codex | C:\Users\30873\.codex\skills\.system\imagegen | — | 不兼容/需适配（未安装） | 默认依赖 Codex 内置 image_gen/view_image；Kimi Code 未提供，CLI 回退又缺 OPENAI_API_KEY 与 openai 包，需适配；依赖：Codex image_gen/view_image 不存在；OPENAI_API_KEY、openai 包及 uv 缺失；未安装 |
| openai-docs | Codex | C:\Users\30873\.codex\skills\.system\openai-docs | C:\Users\30873\.kimi-code\skills\openai-docs | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Node 可用；OpenAI Docs MCP 未配置，可用 Kimi 官方域名 Web 回退；Codex 手册 helper 可用 |
| plugin-creator | Codex | C:\Users\30873\.codex\skills\.system\plugin-creator | C:\Users\30873\.kimi-code\skills\plugin-creator | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12 可用；PyYAML 缺失，验证脚本暂不能运行；面向 Codex 产物 |
| skill-creator | Codex | C:\Users\30873\.codex\skills\.system\skill-creator | C:\Users\30873\.kimi-code\skills\skill-creator | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12 可用；PyYAML 缺失，验证脚本暂不能运行；面向 Codex 产物 |
| skill-installer | Codex | C:\Users\30873\.codex\skills\.system\skill-installer | C:\Users\30873\.kimi-code\skills\skill-installer | 成功（已安装） | 完整复制可迁移文件并安装；依赖：Python 3.12、git 可用；仅标准库；面向 Codex 目录，网络操作按需 |

### 其他

| Skill 名称 | 来源体系 | 来源路径 | 安装路径 | 状态 | 备注 |
|---|---|---|---|---|---|
| brainstorming | 其他 | C:\Users\30873\.agents\skills\brainstorming | C:\Users\30873\.agents\skills\brainstorming | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：git（可用）；其余按具体工作流 |
| diagnosing-superpowers | 其他 | C:\Users\30873\.agents\skills\diagnosing-superpowers | C:\Users\30873\.agents\skills\diagnosing-superpowers | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| dispatching-parallel-agents | 其他 | C:\Users\30873\.agents\skills\dispatching-parallel-agents | C:\Users\30873\.agents\skills\dispatching-parallel-agents | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| emuera-basic-agent-guide | 其他 | C:\Users\30873\.agents\skills\emuera-basic-agent-guide | C:\Users\30873\.agents\skills\emuera-basic-agent-guide | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| executing-plans | 其他 | C:\Users\30873\.agents\skills\executing-plans | C:\Users\30873\.agents\skills\executing-plans | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：git（可用）；其余按具体工作流 |
| finishing-a-development-branch | 其他 | C:\Users\30873\.agents\skills\finishing-a-development-branch | C:\Users\30873\.agents\skills\finishing-a-development-branch | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：git（可用）；其余按具体工作流 |
| godot-2d-animation | 其他 | C:\Users\30873\.agents\skills\godot-2d-animation | C:\Users\30873\.agents\skills\godot-2d-animation | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-2d-physics | 其他 | C:\Users\30873\.agents\skills\godot-2d-physics | C:\Users\30873\.agents\skills\godot-2d-physics | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-3d-lighting | 其他 | C:\Users\30873\.agents\skills\godot-3d-lighting | C:\Users\30873\.agents\skills\godot-3d-lighting | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-3d-materials | 其他 | C:\Users\30873\.agents\skills\godot-3d-materials | C:\Users\30873\.agents\skills\godot-3d-materials | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-3d-world-building | 其他 | C:\Users\30873\.agents\skills\godot-3d-world-building | C:\Users\30873\.agents\skills\godot-3d-world-building | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-ability-system | 其他 | C:\Users\30873\.agents\skills\godot-ability-system | C:\Users\30873\.agents\skills\godot-ability-system | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-adapt-2d-to-3d | 其他 | C:\Users\30873\.agents\skills\godot-adapt-2d-to-3d | C:\Users\30873\.agents\skills\godot-adapt-2d-to-3d | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-adapt-3d-to-2d | 其他 | C:\Users\30873\.agents\skills\godot-adapt-3d-to-2d | C:\Users\30873\.agents\skills\godot-adapt-3d-to-2d | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-adapt-desktop-to-mobile | 其他 | C:\Users\30873\.agents\skills\godot-adapt-desktop-to-mobile | C:\Users\30873\.agents\skills\godot-adapt-desktop-to-mobile | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-adapt-mobile-to-desktop | 其他 | C:\Users\30873\.agents\skills\godot-adapt-mobile-to-desktop | C:\Users\30873\.agents\skills\godot-adapt-mobile-to-desktop | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-adapt-single-to-multiplayer | 其他 | C:\Users\30873\.agents\skills\godot-adapt-single-to-multiplayer | C:\Users\30873\.agents\skills\godot-adapt-single-to-multiplayer | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-agent-vision | 其他 | C:\Users\30873\.agents\skills\godot-agent-vision | C:\Users\30873\.agents\skills\godot-agent-vision | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Python 3/Pillow（可用）；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-ai-navigation | 其他 | C:\Users\30873\.agents\skills\godot-ai-navigation | C:\Users\30873\.agents\skills\godot-ai-navigation | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-analyst | 其他 | C:\Users\30873\.agents\skills\godot-analyst | C:\Users\30873\.agents\skills\godot-analyst | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-animation-player | 其他 | C:\Users\30873\.agents\skills\godot-animation-player | C:\Users\30873\.agents\skills\godot-animation-player | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-animation-tree-mastery | 其他 | C:\Users\30873\.agents\skills\godot-animation-tree-mastery | C:\Users\30873\.agents\skills\godot-animation-tree-mastery | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-audio-systems | 其他 | C:\Users\30873\.agents\skills\godot-audio-systems | C:\Users\30873\.agents\skills\godot-audio-systems | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-auditor | 其他 | C:\Users\30873\.agents\skills\godot-auditor | C:\Users\30873\.agents\skills\godot-auditor | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-autoload-architecture | 其他 | C:\Users\30873\.agents\skills\godot-autoload-architecture | C:\Users\30873\.agents\skills\godot-autoload-architecture | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-builder | 其他 | C:\Users\30873\.agents\skills\godot-builder | C:\Users\30873\.agents\skills\godot-builder | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.7+；Python 3（可用）；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-camera-systems | 其他 | C:\Users\30873\.agents\skills\godot-camera-systems | C:\Users\30873\.agents\skills\godot-camera-systems | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-characterbody-2d | 其他 | C:\Users\30873\.agents\skills\godot-characterbody-2d | C:\Users\30873\.agents\skills\godot-characterbody-2d | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-combat-system | 其他 | C:\Users\30873\.agents\skills\godot-combat-system | C:\Users\30873\.agents\skills\godot-combat-system | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-composition | 其他 | C:\Users\30873\.agents\skills\godot-composition | C:\Users\30873\.agents\skills\godot-composition | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-composition-apps | 其他 | C:\Users\30873\.agents\skills\godot-composition-apps | C:\Users\30873\.agents\skills\godot-composition-apps | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-debugging-profiling | 其他 | C:\Users\30873\.agents\skills\godot-debugging-profiling | C:\Users\30873\.agents\skills\godot-debugging-profiling | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-dialogue-system | 其他 | C:\Users\30873\.agents\skills\godot-dialogue-system | C:\Users\30873\.agents\skills\godot-dialogue-system | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-economy-system | 其他 | C:\Users\30873\.agents\skills\godot-economy-system | C:\Users\30873\.agents\skills\godot-economy-system | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-export-builds | 其他 | C:\Users\30873\.agents\skills\godot-export-builds | C:\Users\30873\.agents\skills\godot-export-builds | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.7+；对应平台 SDK/导出模板（按需）；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-game-loop-collection | 其他 | C:\Users\30873\.agents\skills\godot-game-loop-collection | C:\Users\30873\.agents\skills\godot-game-loop-collection | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-game-loop-harvest | 其他 | C:\Users\30873\.agents\skills\godot-game-loop-harvest | C:\Users\30873\.agents\skills\godot-game-loop-harvest | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-game-loop-time-trial | 其他 | C:\Users\30873\.agents\skills\godot-game-loop-time-trial | C:\Users\30873\.agents\skills\godot-game-loop-time-trial | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-game-loop-waves | 其他 | C:\Users\30873\.agents\skills\godot-game-loop-waves | C:\Users\30873\.agents\skills\godot-game-loop-waves | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-gdscript-mastery | 其他 | C:\Users\30873\.agents\skills\godot-gdscript-mastery | C:\Users\30873\.agents\skills\godot-gdscript-mastery | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-action-rpg | 其他 | C:\Users\30873\.agents\skills\godot-genre-action-rpg | C:\Users\30873\.agents\skills\godot-genre-action-rpg | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-battle-royale | 其他 | C:\Users\30873\.agents\skills\godot-genre-battle-royale | C:\Users\30873\.agents\skills\godot-genre-battle-royale | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-card-game | 其他 | C:\Users\30873\.agents\skills\godot-genre-card-game | C:\Users\30873\.agents\skills\godot-genre-card-game | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-educational | 其他 | C:\Users\30873\.agents\skills\godot-genre-educational | C:\Users\30873\.agents\skills\godot-genre-educational | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-fighting | 其他 | C:\Users\30873\.agents\skills\godot-genre-fighting | C:\Users\30873\.agents\skills\godot-genre-fighting | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-horror | 其他 | C:\Users\30873\.agents\skills\godot-genre-horror | C:\Users\30873\.agents\skills\godot-genre-horror | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-idle-clicker | 其他 | C:\Users\30873\.agents\skills\godot-genre-idle-clicker | C:\Users\30873\.agents\skills\godot-genre-idle-clicker | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-metroidvania | 其他 | C:\Users\30873\.agents\skills\godot-genre-metroidvania | C:\Users\30873\.agents\skills\godot-genre-metroidvania | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-moba | 其他 | C:\Users\30873\.agents\skills\godot-genre-moba | C:\Users\30873\.agents\skills\godot-genre-moba | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-open-world | 其他 | C:\Users\30873\.agents\skills\godot-genre-open-world | C:\Users\30873\.agents\skills\godot-genre-open-world | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-party | 其他 | C:\Users\30873\.agents\skills\godot-genre-party | C:\Users\30873\.agents\skills\godot-genre-party | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-platformer | 其他 | C:\Users\30873\.agents\skills\godot-genre-platformer | C:\Users\30873\.agents\skills\godot-genre-platformer | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-puzzle | 其他 | C:\Users\30873\.agents\skills\godot-genre-puzzle | C:\Users\30873\.agents\skills\godot-genre-puzzle | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-racing | 其他 | C:\Users\30873\.agents\skills\godot-genre-racing | C:\Users\30873\.agents\skills\godot-genre-racing | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-rhythm | 其他 | C:\Users\30873\.agents\skills\godot-genre-rhythm | C:\Users\30873\.agents\skills\godot-genre-rhythm | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-roguelike | 其他 | C:\Users\30873\.agents\skills\godot-genre-roguelike | C:\Users\30873\.agents\skills\godot-genre-roguelike | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-romance | 其他 | C:\Users\30873\.agents\skills\godot-genre-romance | C:\Users\30873\.agents\skills\godot-genre-romance | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-rts | 其他 | C:\Users\30873\.agents\skills\godot-genre-rts | C:\Users\30873\.agents\skills\godot-genre-rts | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-sandbox | 其他 | C:\Users\30873\.agents\skills\godot-genre-sandbox | C:\Users\30873\.agents\skills\godot-genre-sandbox | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-shooter | 其他 | C:\Users\30873\.agents\skills\godot-genre-shooter | C:\Users\30873\.agents\skills\godot-genre-shooter | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-shooter-fps | 其他 | C:\Users\30873\.agents\skills\godot-genre-shooter-fps | C:\Users\30873\.agents\skills\godot-genre-shooter-fps | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-simulation | 其他 | C:\Users\30873\.agents\skills\godot-genre-simulation | C:\Users\30873\.agents\skills\godot-genre-simulation | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-sports | 其他 | C:\Users\30873\.agents\skills\godot-genre-sports | C:\Users\30873\.agents\skills\godot-genre-sports | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-stealth | 其他 | C:\Users\30873\.agents\skills\godot-genre-stealth | C:\Users\30873\.agents\skills\godot-genre-stealth | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-survival | 其他 | C:\Users\30873\.agents\skills\godot-genre-survival | C:\Users\30873\.agents\skills\godot-genre-survival | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-tower-defense | 其他 | C:\Users\30873\.agents\skills\godot-genre-tower-defense | C:\Users\30873\.agents\skills\godot-genre-tower-defense | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-genre-visual-novel | 其他 | C:\Users\30873\.agents\skills\godot-genre-visual-novel | C:\Users\30873\.agents\skills\godot-genre-visual-novel | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-input-handling | 其他 | C:\Users\30873\.agents\skills\godot-input-handling | C:\Users\30873\.agents\skills\godot-input-handling | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-inventory-system | 其他 | C:\Users\30873\.agents\skills\godot-inventory-system | C:\Users\30873\.agents\skills\godot-inventory-system | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-master | 其他 | C:\Users\30873\.agents\skills\godot-master | C:\Users\30873\.agents\skills\godot-master | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-mechanic-revival | 其他 | C:\Users\30873\.agents\skills\godot-mechanic-revival | C:\Users\30873\.agents\skills\godot-mechanic-revival | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-mechanic-secrets | 其他 | C:\Users\30873\.agents\skills\godot-mechanic-secrets | C:\Users\30873\.agents\skills\godot-mechanic-secrets | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-monte-carlo-balancer | 其他 | C:\Users\30873\.agents\skills\godot-monte-carlo-balancer | C:\Users\30873\.agents\skills\godot-monte-carlo-balancer | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Rust/Cargo/rayon（Cargo 不在 PATH）；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-multiplayer-networking | 其他 | C:\Users\30873\.agents\skills\godot-multiplayer-networking | C:\Users\30873\.agents\skills\godot-multiplayer-networking | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-navigation-pathfinding | 其他 | C:\Users\30873\.agents\skills\godot-navigation-pathfinding | C:\Users\30873\.agents\skills\godot-navigation-pathfinding | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-particles | 其他 | C:\Users\30873\.agents\skills\godot-particles | C:\Users\30873\.agents\skills\godot-particles | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-performance-optimization | 其他 | C:\Users\30873\.agents\skills\godot-performance-optimization | C:\Users\30873\.agents\skills\godot-performance-optimization | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-physics-3d | 其他 | C:\Users\30873\.agents\skills\godot-physics-3d | C:\Users\30873\.agents\skills\godot-physics-3d | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-platform-console | 其他 | C:\Users\30873\.agents\skills\godot-platform-console | C:\Users\30873\.agents\skills\godot-platform-console | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-platform-desktop | 其他 | C:\Users\30873\.agents\skills\godot-platform-desktop | C:\Users\30873\.agents\skills\godot-platform-desktop | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-platform-mobile | 其他 | C:\Users\30873\.agents\skills\godot-platform-mobile | C:\Users\30873\.agents\skills\godot-platform-mobile | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-platform-vr | 其他 | C:\Users\30873\.agents\skills\godot-platform-vr | C:\Users\30873\.agents\skills\godot-platform-vr | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-platform-web | 其他 | C:\Users\30873\.agents\skills\godot-platform-web | C:\Users\30873\.agents\skills\godot-platform-web | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-procedural-generation | 其他 | C:\Users\30873\.agents\skills\godot-procedural-generation | C:\Users\30873\.agents\skills\godot-procedural-generation | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-project-foundations | 其他 | C:\Users\30873\.agents\skills\godot-project-foundations | C:\Users\30873\.agents\skills\godot-project-foundations | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-project-templates | 其他 | C:\Users\30873\.agents\skills\godot-project-templates | C:\Users\30873\.agents\skills\godot-project-templates | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-quest-system | 其他 | C:\Users\30873\.agents\skills\godot-quest-system | C:\Users\30873\.agents\skills\godot-quest-system | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-raycasting-queries | 其他 | C:\Users\30873\.agents\skills\godot-raycasting-queries | C:\Users\30873\.agents\skills\godot-raycasting-queries | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-resource-data-patterns | 其他 | C:\Users\30873\.agents\skills\godot-resource-data-patterns | C:\Users\30873\.agents\skills\godot-resource-data-patterns | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-rpg-stats | 其他 | C:\Users\30873\.agents\skills\godot-rpg-stats | C:\Users\30873\.agents\skills\godot-rpg-stats | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-save-load-systems | 其他 | C:\Users\30873\.agents\skills\godot-save-load-systems | C:\Users\30873\.agents\skills\godot-save-load-systems | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-scene-management | 其他 | C:\Users\30873\.agents\skills\godot-scene-management | C:\Users\30873\.agents\skills\godot-scene-management | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-server-architecture | 其他 | C:\Users\30873\.agents\skills\godot-server-architecture | C:\Users\30873\.agents\skills\godot-server-architecture | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-shaders-basics | 其他 | C:\Users\30873\.agents\skills\godot-shaders-basics | C:\Users\30873\.agents\skills\godot-shaders-basics | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-signal-architecture | 其他 | C:\Users\30873\.agents\skills\godot-signal-architecture | C:\Users\30873\.agents\skills\godot-signal-architecture | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-state-machine-advanced | 其他 | C:\Users\30873\.agents\skills\godot-state-machine-advanced | C:\Users\30873\.agents\skills\godot-state-machine-advanced | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-testing-patterns | 其他 | C:\Users\30873\.agents\skills\godot-testing-patterns | C:\Users\30873\.agents\skills\godot-testing-patterns | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；GdUnit4；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-theme-easter | 其他 | C:\Users\30873\.agents\skills\godot-theme-easter | C:\Users\30873\.agents\skills\godot-theme-easter | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-tilemap-mastery | 其他 | C:\Users\30873\.agents\skills\godot-tilemap-mastery | C:\Users\30873\.agents\skills\godot-tilemap-mastery | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-turn-system | 其他 | C:\Users\30873\.agents\skills\godot-turn-system | C:\Users\30873\.agents\skills\godot-turn-system | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-tweening | 其他 | C:\Users\30873\.agents\skills\godot-tweening | C:\Users\30873\.agents\skills\godot-tweening | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-ui-containers | 其他 | C:\Users\30873\.agents\skills\godot-ui-containers | C:\Users\30873\.agents\skills\godot-ui-containers | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-ui-rich-text | 其他 | C:\Users\30873\.agents\skills\godot-ui-rich-text | C:\Users\30873\.agents\skills\godot-ui-rich-text | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-ui-theming | 其他 | C:\Users\30873\.agents\skills\godot-ui-theming | C:\Users\30873\.agents\skills\godot-ui-theming | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.x；Godot CLI 不在 PATH，未验证引擎版本 |
| godot-version-migration | 其他 | C:\Users\30873\.agents\skills\godot-version-migration | C:\Users\30873\.agents\skills\godot-version-migration | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：Godot 4.7+；Godot CLI 不在 PATH，未验证引擎版本 |
| receiving-code-review | 其他 | C:\Users\30873\.agents\skills\receiving-code-review | C:\Users\30873\.agents\skills\receiving-code-review | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| requesting-code-review | 其他 | C:\Users\30873\.agents\skills\requesting-code-review | C:\Users\30873\.agents\skills\requesting-code-review | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：git（可用）；其余按具体工作流 |
| root-probe-user-agents | 其他 | C:\Users\30873\.agents\skills\root-probe-user-agents | C:\Users\30873\.agents\skills\root-probe-user-agents | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| root-probe-user-dsh | 其他 | C:\Users\30873\.agents\skills\root-probe-user-dsh | C:\Users\30873\.agents\skills\root-probe-user-dsh | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| subagent-driven-development | 其他 | C:\Users\30873\.agents\skills\subagent-driven-development | C:\Users\30873\.agents\skills\subagent-driven-development | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：git（可用）；其余按具体工作流 |
| systematic-debugging | 其他 | C:\Users\30873\.agents\skills\systematic-debugging | C:\Users\30873\.agents\skills\systematic-debugging | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：git（可用）；其余按具体工作流 |
| tavily-best-practices | 其他 | C:\Users\30873\.agents\skills\tavily-best-practices | C:\Users\30873\.agents\skills\tavily-best-practices | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-cli | 其他 | C:\Users\30873\.agents\skills\tavily-cli | C:\Users\30873\.agents\skills\tavily-cli | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-crawl | 其他 | C:\Users\30873\.agents\skills\tavily-crawl | C:\Users\30873\.agents\skills\tavily-crawl | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-dynamic-search | 其他 | C:\Users\30873\.agents\skills\tavily-dynamic-search | C:\Users\30873\.agents\skills\tavily-dynamic-search | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-extract | 其他 | C:\Users\30873\.agents\skills\tavily-extract | C:\Users\30873\.agents\skills\tavily-extract | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-map | 其他 | C:\Users\30873\.agents\skills\tavily-map | C:\Users\30873\.agents\skills\tavily-map | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-research | 其他 | C:\Users\30873\.agents\skills\tavily-research | C:\Users\30873\.agents\skills\tavily-research | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| tavily-search | 其他 | C:\Users\30873\.agents\skills\tavily-search | C:\Users\30873\.agents\skills\tavily-search | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：tvly 已在 PATH；TAVILY_API_KEY 已设置；未发起网络请求 |
| test-driven-development | 其他 | C:\Users\30873\.agents\skills\test-driven-development | C:\Users\30873\.agents\skills\test-driven-development | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| using-git-worktrees | 其他 | C:\Users\30873\.agents\skills\using-git-worktrees | C:\Users\30873\.agents\skills\using-git-worktrees | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：git（可用）；其余按具体工作流 |
| using-superpowers | 其他 | C:\Users\30873\.agents\skills\using-superpowers | C:\Users\30873\.agents\skills\using-superpowers | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：git（可用）；其余按具体工作流 |
| verification-before-completion | 其他 | C:\Users\30873\.agents\skills\verification-before-completion | C:\Users\30873\.agents\skills\verification-before-completion | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：无 DSH 专属运行时；本地 Markdown/引用资源可直接使用 |
| writing-plans | 其他 | C:\Users\30873\.agents\skills\writing-plans | C:\Users\30873\.agents\skills\writing-plans | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：git（可用）；其余按具体工作流 |
| writing-skills | 其他 | C:\Users\30873\.agents\skills\writing-skills | C:\Users\30873\.agents\skills\writing-skills | 跳过（原生可用） | 已位于 Kimi Code 官方用户级扫描目录，跳过复制；依赖：git（可用）；其余按具体工作流 |

## 6. 命名冲突

- 原有 `godot-master` 保留在 `C:\Users\30873\.agents\skills\godot-master`，未覆盖。
- Claude 的不同版本安装为 `godot-master-imported`。
- Codex 又提供第三份不同内容，因 `godot-master-imported` 已被占用，安装为 `godot-master-imported-2`。这是扩展冲突名，需用户日后决定是否保留全部三版。
- 三版的 frontmatter 注册名与目录名一致；其余重复来源内容相同并跳过，没有覆盖。

## 7. 不兼容、缺失依赖与替代方案

### 未安装的 4 项

- `office-export-pdf`、`office-recalculate`、`office-render`：缺少 LibreOffice Kit sidecar，且 Kimi Code 没有 DSH 注入的绝对 Node/CLI 路径。未复制到目标目录。若需要这三项，下一步需先明确授权安装 sidecar，再按其 `sidecar.md` 适配并验证。
- `imagegen`：默认工作流依赖 Codex 内置 `image_gen`/`view_image`，Kimi Code 未提供；CLI 回退所需的 `OPENAI_API_KEY`、Python `openai` 包及 `uv` 也缺失。未安装，不能视为可用。

### 已安装但带依赖警告

- `office-docx`、`office-pptx`、`office-xlsx`：DSH Python 3.12 中的所需库均已具备。Kimi 没有 `load_workspace_dependencies`，按 Skill 自带回退说明使用 `C:\Users\30873\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe`；没有 `present`，用 Kimi 支持的工作区文件路径/附件交付替代。
- `office` 路由 Skill 已可调用，但渲染、PDF 导出、公式重算三个分支不可用，不能据此宣称完整 Office 功能可用。
- `skill-creator`、`plugin-creator`：Python 可用，但 `PyYAML` 缺失，所以其 `quick_validate.py`/`validate_plugin.py` 暂不能运行；未擅自安装包。它们仍面向 Codex 产物，并未改写成 Kimi 插件生成器。
- `xai-search`：`XAI_API_KEY` 已设置，curl 路径可用；`xai-sdk` 与 `jq` 缺失，SDK/jq 路径需另装依赖。
- `openai-docs`：Node 可用；未配置 OpenAI Docs MCP 时可使用 Skill 规定的官方域名 Web 回退。
- Tavily 系列：`tvly` 在 PATH，`TAVILY_API_KEY` 已设置；本次未发起网络请求。
- Godot 系列：知识型 Skill 可加载；`godot`/`godot4` 不在 PATH，未验证引擎 CLI。`godot-monte-carlo-balancer` 所需 `cargo`/`rustc` 也不在 PATH。
- 系统 `python` 指向不可用的 Microsoft Store 别名；上述 Python 验证均使用 DSH 自带的真实 Python 3.12.14。

## 8. 安全与兼容性检查

- 只复制本地已知来源目录；未上传 Skill 内容或密钥，未执行远程安装。
- 复制过滤器排除 `.env`、凭据/token、日志、缓存、虚拟环境、`node_modules` 及未知二进制可执行文件；本次已安装项没有触发额外文件遗漏。
- 所有原始目录保持原位。没有修改全局 Kimi 配置。
- DSH 通用 Skill 未检测到 `DSH_HOME`、`DSH_SKILLS_DIR`、DSH MCP 或内部命令硬依赖；其重复副本已由 Kimi 原生目录提供。
- Codex 专用 Skill 按原用途保留，未伪装成 Kimi 专用工作流；Kimi 可加载并不等于其目标产物格式变成 Kimi 格式。

## 9. 实际验证命令与结果

1. **官方目录/帮助**：执行 `kimi --help`，结果为 `command not found`；执行完整路径 `dsh.cmd --help` 成功并确认无 Skill 清单命令。通过上述官方文档确认安装目录与格式。
2. **磁盘扫描与冲突比较**：使用 Glob 递归枚举各来源 `SKILL.md`，再用 DSH Python 内联盘点脚本计算过滤后的逐文件 SHA-256。结果 276 项、必需 frontmatter 字段均有效；重复与冲突按报告处理。
3. **复制后逐字节/规范化比较**：对 12 个新装目录重新计算源/目标哈希；普通文件逐字节一致，仅 `SKILL.md` 的换行和冲突处理要求的 `name` 字段允许规范化差异。最终 12/12 `CONTENT_OK + REGISTERED`，0 错误。
4. **Kimi 实际自动发现**：Kimi Code Desktop 实时 Skill catalog 自动刷新，逐一列出新装的 12 项及原有 125 项，共 137 个用户级 Skill；未重启或修改配置。最新目录也包含 `godot-master-imported-2`。
5. **真实调用**：调用 `Skill(skill="cocoloop")` 与 `Skill(skill="office")` 均成功，返回内容的路径分别位于新目标目录；不是仅做导入或文件存在检查。
6. **frontmatter/名称唯一性**：内联 Python 验证两个官方用户目录的顶层 `*/SKILL.md`，结果 `DISCOVERED_TOP_LEVEL 137 UNIQUE 137 ERRORS 0`，目录名与注册名一致。
7. **Python 语法**：用 `compile(path.read_bytes(), str(path), "exec")` 检查两个用户目录全部 218 个 `.py`，全部通过；该检查不生成缓存、不执行脚本。
8. **JavaScript 语法**：对全部 5 个 `.js/.mjs/.cjs` 执行 `node --check <path>`，全部通过。
9. **Shell 语法**：对全部 11 个 `.sh` 执行 `E:/MyTools/Git/bin/bash.exe -n <path>`，全部通过。
10. **本地资源引用**：检查非代码块 Markdown 相对链接，结果 `REFERENCE_WARNINGS 0`。初次出现的 6 个警告均为 `skill-creator` 代码块中的示例文件，排除代码块后确认并非真实缺失引用。
11. **依赖探测**：用 DSH Python `importlib.util.find_spec` 检查库；DOCX/PPTX/XLSX/Pillow 依赖存在，PyYAML/openai/xai_sdk 缺失。`git/node/npm/npx/codex/tvly/curl` 可用；`uv/jq/dsoffice/godot/cargo/rustc` 不在 PATH。密钥只检查是否设置，未读取或输出其值。

验证脚本语法通过不代表所有外部服务或 Skill 的完整业务工作流已经执行；本报告明确区分“可发现/可调用”与“外部依赖全部满足”。

## 10. 需要用户决定的事项

- 若需要 Office 渲染、PDF 导出或公式重算：确认是否授权下载 LibreOffice Kit sidecar，然后再适配这 3 项。
- 若需要 `imagegen`：选择适配 Kimi 的图像工具，或自行配置 OpenAI CLI 回退依赖；当前未安装该 Skill。
- 若要运行 Codex 验证 helper：安装 PyYAML 到选定的任务环境；若要 xAI SDK 路径，安装 `xai-sdk`（`jq` 可选）。
- 决定三份 `godot-master` 是否都长期保留；当前为防丢失全部保留。
