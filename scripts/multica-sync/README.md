# Multica 工作区同步 / Multica workspace sync

统一的 Shell 脚本，一键同步整个工作区（skills、agents、squads、成员）—— 基于官方 `multica` CLI，全程幂等。

Unified shell script for managing workspace resources (skills, agents, squads, members) in your Multica workspace. Built on the official `multica` CLI, fully idempotent operations.

> 想手动操作？直接用 [`../../templates/squad/software-development`](../../templates/squad/software-development) 模板即可。
>
> Prefer manual setup? Use the starter templates directly — no script needed.

## 前置条件 / Prerequisites

### 1. 安装 Multica CLI

```bash
npm install -g multica
# 或 / or: brew install multica
```

官方文档 / [Official CLI docs](https://multica.ai/docs/zh/cli)

### 2. 一次性认证 / One-time authentication

```bash
export MULTICA_SERVER_URL="https://api.multica.ai"
multica login --token mul_xxx
# 或交互式登陆 / or interactive:
multica login
```

认证信息保存到 `~/.multica/config.json`，之后无需重复输入。

### 3. 验证 / Verify installation

```bash
multica version
multica workspace list
```

---

## 快速开始 / Quick Start

```bash
cd scripts/multica-sync

# 列出工作区中的所有小队
./multica-sync.sh list

# 导出整个工作区配置（agents、squads、skills 及所有关系）
./multica-sync.sh export

# 一键同步整个工作区（先预览）
export MULTICA_DRY_RUN="true"
./multica-sync.sh sync-skills
./multica-sync.sh sync-agents
./multica-sync.sh init
./multica-sync.sh sync-squad

# 真正执行（不加 DRY-RUN）
unset MULTICA_DRY_RUN
./multica-sync.sh sync-skills
./multica-sync.sh sync-agents
./multica-sync.sh init
./multica-sync.sh sync-squad
```

---

## 命令详解 / Commands

### `list` — 列出小队 / List squads

```bash
./multica-sync.sh list
```

输出工作区中的所有小队及其 UUID：
```
📋 Squads in workspace '9e4ed7cd-...-991f75d93b7c':
software-development (a3690013-3cb5-4aed-a12d-c1fb6adda1fe)
bug-fix (37444ecd-23d2-41dd-a212-a4ea18e54327)
```

### `export` — 导出工作区配置 / Export workspace config

```bash
./multica-sync.sh export
# → workspace-export-20261003-120530.json
```

导出整个工作区的完整配置，包含：
- ✅ 所有 agents（ID、名称）
- ✅ 所有 squads（ID、名称、成员）
- ✅ 所有 skills（ID、名称）
- ✅ **Agent-Squad 绑定**：哪个 agent 在哪个 squad 中、担任什么角色
- ✅ 统计摘要（agents、squads、skills 数量）

**导出文件结构**：
```json
{
  "workspace_id": "9e4ed7cd-...",
  "exported_at": "2026-10-03T12:05:30Z",
  "summary": {
    "agents_count": 15,
    "squads_count": 3,
    "skills_count": 28
  },
  "agents": [...],
  "squads": [...],
  "skills": [...],
  "agent_squad_bindings": [...]
}
```

**用途**：
- 📊 备份、审计工作区配置
- 🔄 跨工作区迁移参考
- 📋 查看所有 agents、squads、skills 的完整关系

### `sync-skills` — 同步所有 skills / Sync all skills

```bash
export MULTICA_DRY_RUN="true"
./multica-sync.sh sync-skills

# 执行同步（无 DRY-RUN）
unset MULTICA_DRY_RUN
./multica-sync.sh sync-skills [config-file]
```

从 `skills-config.json` 读取所有 skill 名称，根据模板文件同步内容：

1. 读取 `skills-config.json` 中的 skills 列表
2. 对每个 skill：
   - 从 `templates/skills/{skill-name}/SKILL.md` 读取内容
   - 若 skill **不存在**在工作区 → 创建（含所有文件）
   - 若 skill **已存在** → 强制更新（模板 → 工作区）
3. 上传所有辅助文件（config.yaml、references/、等）

**输出示例**：
```
✓ Already exists: multica-backend-impl
[DRY-RUN] Would create skill: multica-pm-artifact-publish
  → file: config.yaml
  → file: SKILL.md
```

**特点**：
- ✅ 幂等：已存在的 skill 会被强制更新到最新模板
- ✅ 完整：上传所有文件（SKILL.md、config.yaml、references/）
- ✅ 可预览：用 `MULTICA_DRY_RUN=true` 先看会发生什么

### `sync-agents` — 同步所有 agents + 绑定 skills / Sync agents and bind skills

```bash
export MULTICA_DRY_RUN="true"
./multica-sync.sh sync-agents

# 执行同步
unset MULTICA_DRY_RUN
./multica-sync.sh sync-agents [config-file]
```

从 `agents-config.json` 读取所有 agents 和各自的 skills，同步指令和绑定：

1. 读取 `agents-config.json` 中的 agents 列表（name、stem、skills）
2. 对每个 agent：
   - 从 `templates/agents/{stem}.md` 读取 agent 指令
   - 若 agent **存在** 在工作区 → 更新指令
   - 绑定配置中指定的 skills（若已绑定则跳过）
3. 若 agent **不存在** → 跳过（agent 创建需通过 UI 或 API）

**输出示例**：
```
[DRY-RUN] Would update agent: BackendDev
  → update instructions from: templates/agents/backend-developer.md
  → bind skill: multica-backend-impl
  ✓ Already bound: multica-artifact-backend
```

**特点**：
- ✅ 更新指令：从最新模板同步 agent 文本
- ✅ 绑定 skills：增量绑定（不删除已有的）
- ✅ 可预览：清楚显示哪些 skills 需要新绑、哪些已绑定

### `init` — 创建所有 squads / Create all squads

```bash
./multica-sync.sh init [config-file]
```

从 `squad-config.json` 读取所有 squad 名称，在工作区创建：

1. 读取 `squad-config.json` 中的 squads 列表
2. 对每个 squad：
   - 若已存在 → 跳过
   - 若不存在 → 创建（仅名称和描述）

**输出示例**：
```
🚀 Creating all squads from 'squad-config.json'...
  ✅ Created squad: software-development
  ⚠️  Squad may already exist: bug-fix
✅ Squad creation complete (created: 1)
```

**特点**：
- ✅ 幂等：已存在的小队不会重复创建
- ✅ 安全：只创建，不删除或修改

### `sync-squad` — 为所有 squads 添加成员 / Add members to all squads

```bash
export MULTICA_DRY_RUN="true"
./multica-sync.sh sync-squad

# 执行同步
unset MULTICA_DRY_RUN
./multica-sync.sh sync-squad [config-file]
```

从 `squad-config.json` 读取所有 squads 和各自的成员，为每个 squad 添加或更新成员：

1. 读取 `squad-config.json` 中的 squads 及 members（agent_name、role）
2. 对每个 squad：
   - 查询工作区中的 squad ID（通过 name 匹配）
   - 对每个 member：
     - 通过 agent_name 查询 agent ID
     - 若 agent 已是成员、role 相同 → 跳过
     - 若 agent 已是成员、role 不同 → 更新 role
     - 若 agent 不是成员 → 添加为成员并设 role

**输出示例**：
```
[DRY-RUN] Would add: Mika as Leader
✓ Already member: Mika (role: Leader)
[DRY-RUN] Would update: BackendDev role from '' to 'BackendDev'
```

**特点**：
- ✅ 幂等：已有成员不重复添加
- ✅ 可更新：成员存在但 role 不同时会更新
- ✅ 容错：不存在的 agent 会被跳过并警告

### `sync` — 查看 squad 内容 / View members or skills

```bash
./multica-sync.sh sync <squad-id> members
./multica-sync.sh sync <squad-id> skills
./multica-sync.sh sync <squad-id> all
```

列出现有的成员和 skills。

### `clone` — 跨工作区复制小队 / Clone squad

```bash
./multica-sync.sh clone <source-squad-id> <target-workspace-id> [squad-name]
```

当前仅作为参考流程。推荐：

1. 导出源小队：`./multica-sync.sh export <squad-id> > squad-backup.json`
2. 切换工作区：`export MULTICA_WORKSPACE_ID="<target-id>"`
3. 在目标工作区手动重建或用 multica CLI 创建

---

## 配置 / Configuration

### `config.local.json` — 工作区和认证

```json
{
  "base_url": "https://api.multica.ai",
  "workspace": "9e4ed7cd-a8b8-4a5b-9549-991f75d93b7c",
  "token": "mul_xxx"
}
```

| 字段 | 说明 |
|-----|------|
| `workspace` | 默认工作区 UUID |
| `token` | API Token（可选 — multica CLI 已登陆时不需要） |
| `base_url` | API 基址（通常无需修改） |

⚠️ **此文件不提交 Git**（`.gitignore` 已配置）— 包含 token。

### `skills-config.json` — Skills 清单

```json
[
  { "name": "multica-backend-impl" },
  { "name": "multica-artifact-backend" },
  { "name": "multica-pm-requirement-spec" },
  ...
]
```

**字段说明**：
- `name`：skill 的名称（必须与 `templates/skills/{name}/SKILL.md` 对应）

**用途**：
- `sync-skills` 命令读取此文件来同步所有 skills

### `agents-config.json` — Agents 清单 + Skill 绑定

```json
{
  "agents": [
    {
      "name": "BackendDev",
      "stem": "backend-developer",
      "skills": ["multica-backend-impl", "multica-artifact-backend"]
    },
    {
      "name": "Architect",
      "stem": "architect",
      "skills": ["multica-technical-design", "multica-artifact-architect"]
    }
  ]
}
```

**字段说明**：
- `name`：agent 的显示名称（在工作区中的 agent 名）
- `stem`：agent 的标识符，用于查找模板文件 `templates/agents/{stem}.md`
- `skills`：该 agent 应绑定的 skills 列表（skill 名需与 Multica 工作区中的 skill 名一致）

**用途**：
- `sync-agents` 命令读取此文件来同步 agent 指令和绑定 skills

### `squad-config.json` — Squads 清单 + 成员

```json
{
  "squads": [
    {
      "name": "software-development",
      "description": "This Squad turns an Issue into an accepted, shippable deliverable.",
      "members": [
        { "agent_name": "Mika", "role": "Leader" },
        { "agent_name": "BackendDev", "role": "BackendDev" },
        { "agent_name": "FrontendDev", "role": "FrontendDev" }
      ]
    },
    {
      "name": "bug-fix",
      "description": "Minimal fix combination for bug resolution.",
      "members": [
        { "agent_name": "Mika", "role": "Leader" },
        { "agent_name": "Reviewer", "role": "Reviewer" }
      ]
    }
  ]
}
```

**字段说明**：
- `name`：squad 的名称
- `description`：squad 的描述
- `members`：该 squad 的成员列表
  - `agent_name`：agent 的显示名称（必须与 `agents-config.json` 中的 name 一致）
  - `role`：该 agent 在该 squad 中的角色

**用途**：
- `init` 命令读取此文件来创建所有 squads
- `sync-squad` 命令读取此文件来添加/更新成员

---

## 环境变量 / Environment Variables

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `MULTICA_WORKSPACE_ID` | 工作区 UUID（覆盖 config.local.json） | — |
| `MULTICA_DRY_RUN` | 设为 `true` 预览不执行操作 | `false` |
| `MULTICA_CONFIG_FILE` | 配置文件路径 | `config.local.json` |

### 示例

**预览而不执行**：
```bash
export MULTICA_DRY_RUN="true"
./multica-sync.sh sync-skills
./multica-sync.sh sync-agents
./multica-sync.sh sync-squad
```

**切换工作区**：
```bash
export MULTICA_WORKSPACE_ID="9e4ed7cd-a8b8-4a5b-9549-991f75d93b7c"
./multica-sync.sh list
```

**自定义配置文件**：
```bash
export MULTICA_CONFIG_FILE="/path/to/custom-config.json"
./multica-sync.sh list
```

---

## 工作流示例 / Workflow Examples

### 场景 1: 第一次初始化工作区

假设已登陆 Multica 但工作区是空的，要一键导入所有资源。

```bash
# 1. 检查配置文件有工作区 ID
cat config.local.json  # 确认 workspace 字段

# 2. 先预览（强烈推荐！）
export MULTICA_DRY_RUN="true"
./multica-sync.sh sync-skills
./multica-sync.sh sync-agents
./multica-sync.sh init
./multica-sync.sh sync-squad

# 3. 检查输出无误后，真正执行
unset MULTICA_DRY_RUN
./multica-sync.sh sync-skills
./multica-sync.sh sync-agents
./multica-sync.sh init
./multica-sync.sh sync-squad

# 4. 验证
./multica-sync.sh list
```

### 场景 2: 更新 skills 内容

模板中的 skills 内容更新了，需要推送到工作区。

```bash
# 只需执行 sync-skills，会自动更新已存在的 skills
./multica-sync.sh sync-skills

# 或预览
export MULTICA_DRY_RUN="true"
./multica-sync.sh sync-skills
```

### 场景 3: 更新 agent 指令

某个 agent 的指令模板更新了，需要推送到工作区。

```bash
# 只需执行 sync-agents，会自动更新已存在的 agents 指令
./multica-sync.sh sync-agents

# 或针对特定 agent（当前脚本同步所有，未来可考虑 --only 选项）
```

### 场景 4: 添加新 squad 及成员

需要创建新的 squad 并添加成员。

```bash
# 1. 编辑 squad-config.json，添加新 squad 定义
vi squad-config.json

# 2. 预览
export MULTICA_DRY_RUN="true"
./multica-sync.sh init
./multica-sync.sh sync-squad

# 3. 执行
unset MULTICA_DRY_RUN
./multica-sync.sh init
./multica-sync.sh sync-squad
```

---

## 常见问题 / FAQ

**Q: 如何获取工作区 UUID？**

A: 运行 `multica workspace list` 或在 [Multica Dashboard](https://multica.ai) → Settings → Workspace 查看。

**Q: 脚本会删除现有的 skills、agents 或 squads 吗？**

A: 不会。脚本仅创建或更新，从不删除。已存在的资源会被更新到最新模板。

**Q: 如何只同步某些 skills 或 agents？**

A: 编辑对应的配置文件（skills-config.json 或 agents-config.json），移除不需要的条目，然后执行同步。

**Q: 预览和执行有什么区别？**

A: `MULTICA_DRY_RUN=true` 预览所有操作（不实际修改）；`MULTICA_DRY_RUN=false` 或不设置时真正执行。

**Q: sync-squad 失败是什么原因？**

A: 常见原因：
- squad 不存在（先执行 `init`）
- agent_name 在 agents-config.json 中找不到对应 agent
- 网络连接问题

运行 `MULTICA_DRY_RUN=true ./multica-sync.sh sync-squad` 查看具体会执行哪些命令。

**Q: 如何重新认证？**

A: 
```bash
multica auth logout
multica login --token mul_xxx
```

**Q: skill 模板中的 config.yaml 或 references/ 文件会被同步吗？**

A: 是的，`sync-skills` 会上传所有文件（SKILL.md、config.yaml、references/）。

---

## 依赖 / Dependencies

- **Multica CLI** v0.6.1+ ([安装](https://multica.ai/docs/zh/cli))
- **Bash** 4.0+
- **jq** 用于 JSON 处理（macOS 需 `brew install jq`）

验证依赖：
```bash
multica version
jq --version
bash --version
```

---

## 官方文档 / Official Docs

- 🔗 [Multica CLI 文档](https://multica.ai/docs/zh/cli)
- 🔗 [Multica API 参考](https://api-docs.multica.ai/)
- 🔗 [本项目 README](../../README.md)

---

**版本历史 / Version History**

- **v0.4.0** (2026-10-04) — `init` 命令升级为一键四步工作流（skills → agents → squads → members）；支持分步执行或一次性初始化
- **v0.3.0** (2026-10-04) — 完整的四步工作流：sync-skills（创建/更新 skills + 所有文件）、sync-agents（更新 agent 指令 + 绑定 skills）、init（创建 squads）、sync-squad（添加/更新成员）；支持 DRY-RUN；配置文件精简（无 ID）
- **v0.2.0** (2026-10-03) — 新增 `sync-members` 和 `sync-skills` 命令，支持批量同步；更新 README 文档
- **v0.1.0** (2026-10-03) — 初版，基于官方 Multica CLI，替代旧的 Python 脚本组
