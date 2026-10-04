---
name: multica-test-t3-api-automation
description: T3 API automation—only after G2.5 PASS; run API test scenarios by contract, join overall verdict with UI side. Requires deploy environment + manifest complete.
version: 1.1.0
metadata:
  layer: content
  upstream:
    - multica-test-orchestration
---

# API Automation (T3 · API)

T3 only after **G2.5 PASS**; an AC can only be verified by API → run this skill alone; if it also has a UI channel → run both, orchestration merges one report.

> Integrated from `api-automation-squad`. **Material assembly + BLOCKED see `multica-test-orchestration`.**

## Required Items (stop + interruption list if missing; summary from comments)

| Required | How it counts as complete |
| --- | --- |
| G2.5 PASS | Leader/DevOps explicit G2.5 PASS (or "G2.5 N/A" but deploy_url + Leader written authorization) |
| deploy_url | Reachable environment URL |
| contract | API contract link (OAS / Postman / Apifox / API docs), or **N/A (reuse xxx)** |
| scenario manifest | API manifest path from MULTICA.md §2 (defines which endpoints/scenarios to test) |

## Flow

1. Read contract + deploy URL
2. Load scenario manifest from MULTICA.md §2 (or T1 spec)
3. Run scenarios against deploy_url:
   - Use your API testing tool (Postman / Apifox / custom client)
   - Save results as JSON (status, latency, assertions, logs)
4. Write report (see Output below)

## Output and merge

```markdown
# T3 API Automation — {ISSUE_KEY}
- G2.5: PASS @ {sha}  deploy: {url}
- contract: {link}
- scenarios: {count} total / {pass} pass / {fail} fail / {error} error
- per scenario: id / name / status / latency / assertion / log
- conclusion: PASS | FAIL | BLOCKED
```

`multica-test-orchestration` merges with UI side: **one side only** verifies a given AC, missing that side → **whole ticket cannot be PASS**; errors → triage (see orchestration references).

## Platform Collaboration

**Optional**: If an API testing platform skill is mounted, use its tooling to run scenarios and export results. Otherwise, use your team's standard API testing tool.

## Rules

- **No local mock** as substitute for the deployed environment; no environment → BLOCKED.
- All scenarios must have explicit expected results before execution (no "wait and see")
- Failed assertions must include the actual vs. expected values in the log

## Why it works

API verification is independent of UI; running after G2.5 ensures automated evidence is trustworthy; manifest-driven approach avoids platform lock-in.
