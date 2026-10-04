# Contributing / 贡献指南

感谢你帮助改进 Multica Best Practices。Thank you for helping improve Multica Best Practices.

## 欢迎什么 / What we welcome

- 更清晰的模板（Agent / Squad / Skill / Issue Instructions）/ clearer templates
- 脱敏后的真实案例研究（放到 `docs/` 或对应的 Starter 下）/ desensitized real case studies (into `docs/` or the matching Starter)
- 技术栈特定的验证命令对照表（Node、Go、Python 等）/ stack-specific verification command tables
- 修复过时的 Multica 行为描述（注明官方文档或版本）/ fixes to outdated Multica behavior descriptions (cite official docs or versions)
- 翻译 / translations（中文文档为源文档，双语修改必须同 PR 提交 / Chinese docs are the source; bilingual changes must land in the same PR）

## 避免什么 / What to avoid

- 硬编码的 workspace ID、token 或私有 URL / hardcoded workspace IDs, tokens, or private URLs
- 声称对所有人存在唯一「正确」的 Agent 数量 / claiming a single "correct" agent count for everyone
- 替代 Multica 产品文档——请链接到官方文档 / replacing Multica product docs — link to the official docs instead
- 没有充分理由的大体积二进制文件 / large binaries without good reason

## 如何贡献 / How to contribute

1. 从 `main` 创建分支 / branch from `main`.
2. 保持改动聚焦（每个 PR 只动一个 Starter 或一个文档主题）/ keep changes focused (one Starter or one doc topic per PR).
3. 在 `CHANGELOG.md` 加一条简短记录（中英结合）/ add a short entry (Chinese + English) to `CHANGELOG.md`.
4. 提 PR 时说明 / describe in the PR:
   - 解决什么问题 / what problem it solves
   - 如何验证（即使只是「文档审查」）/ how it was verified (even "doc review")
   - 是否有 Multica 版本假设 / any Multica version assumptions

## 模板风格 / Template style

- 优先提供可直接复制的 Markdown 代码块 / prefer directly copyable Markdown code blocks.
- Agent 模板写明 **职责 / 禁止 / 交付格式** / agent templates state responsibilities / prohibitions / delivery format.
- 可选内容明确标注 / mark optional content explicitly.
- 避免假设单一模型供应商 / avoid assuming a single model vendor.

## Starter 风格 / Starter style

- `templates/squad/software-development` 是本仓库的 MVP，改动需保持「复制即用」/ it is the repo MVP; changes must keep it copy-paste-run.
- 每个模板旁应尽量附「为什么有效」和「常见失败」/ ship "why it works" and "common failure modes" next to each template.
- 新增 Starter 前，先在真实任务上验证，再提交（参考 README 的贡献标准：问题 / 场景 / 完整模板 / 真实示例 / 已知失败案例）/ validate new starters on real tasks before submitting (see the README contribution bar: problem / scenarios / complete template / real example / known failure cases).
