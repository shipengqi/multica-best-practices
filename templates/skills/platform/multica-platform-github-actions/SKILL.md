---
name: multica-platform-github-actions
description: Platform-layer skill (placeholder shell): read/write capability for GitHub Actions — trigger workflow dispatches, poll run status, fetch job logs. Credentials injected via runtime env. Concrete repo/workflow list in config.yaml, never in role prompts.
metadata:
  layer: platform
  replaces: any GitHub-hosted or self-hosted Actions runner (github.com or GitHub Enterprise)
  runtime:
    python: ">=3.10"
---

# Platform · GitHub Actions (placeholder shell)

> This is a **platform-layer placeholder shell**. The public multica-best-practices binds to no specific repository URLs or tokens.
> To onboard your own GitHub Actions setup, only edit this skill's `config.yaml` and `scripts/`; all upstream orchestration skills stay untouched.

## Purpose

GitHub Actions **read + write**: trigger `workflow_dispatch` events, poll run status, fetch job logs, return run URLs.

Default GitHub API base and target repos configured in `config.yaml` → `github.api_url` / `github.repos` (placeholders: `https://api.github.com` / `<owner>/<repo>`).

## Agent standard flow (required)

```text
1. Resolve service → repo + workflow file (from issue_service_map in config.yaml)
2. Identify deploy branch (from Issue source + affected ends, not feature branch)
3. trigger: multica-artifact-cicd-sync → trigger script (workflow_dispatch)
4. poll until conclusion = success | failure | cancelled
5. Return run URL to Leader
```

**Input priority**: `--input` > **branch hint** (`ref`, `branch` etc.) > workflow default

## Files (suggested structure)

```text
multica-platform-github-actions/
├── SKILL.md
├── config.yaml
├── .env.example
└── scripts/
    ├── trigger_workflow.py   # dispatch + poll by service/env
    ├── list_workflows.py     # list workflows per repo
    ├── actions_cli.py        # low-level GitHub Actions API
    └── lib/
```

## Install deps (once)

```bash
pip install -r scripts/requirements.txt
```

## List workflows

```bash
python scripts/list_workflows.py --repo owner/repo
python scripts/list_workflows.py --repo owner/repo --env sit
```

## Trigger workflow (workflow_dispatch)

```bash
python scripts/trigger_workflow.py --env sit --service <service> --branch release/<ISSUE>-<slug> --json
python scripts/trigger_workflow.py --env sit --service <service> --branch release/<ISSUE>-<slug> --input deployVersion=1.0.0 --json
```

## Credentials

| Variable | Description |
| --- | --- |
| `GITHUB_TOKEN` | Personal access token or GitHub App token (runtime env, never in role prompts) |
| `GITHUB_API_URL` | GitHub API base URL — `https://api.github.com` (public) or `https://<ghes-host>/api/v3` (GHES) |

## Success criteria

- script exit code `0`
- run `conclusion = success`
- return run URL list

## Relationship to orchestration skill

| Orchestration skill | Calls |
| --- | --- |
| `multica-artifact-cicd-sync` | `trigger_cicd.py` → internally calls this skill's Python scripts |

## Why it works

Workflow dispatch takes `ref` (branch) and `inputs` as explicit parameters, so the Agent triggers exactly the right branch without discovering parameters dynamically. Repo + workflow file mappings live in `config.yaml` → `issue_service_map`. A swappable platform layer is the core of "copy-paste-run".
