---
name: multica-test-t2-coverage
description: T2 coverage evaluation—after G2 PASS, compare diff, contract and T1 wiki; incremental body + API scenarios + tests/e2e Playwright into repo. No XMind.
version: 1.3.0
metadata:
  orchestrates:
    - (wiki platform)
    - (issue tracker platform)
    - (API testing platform)
---

# Test Coverage T2 (Coverage Evaluation)

Only **after G2 PASS, before T3**. Evaluate "is T1 enough", **do not execute** environment verification.

> Integrated from `ac-coverage-t2-squad`. Material assembly rules see `multica-test-orchestration` "Assemble from Comments".

## 5 Required Items (assemble from comments; stop if any missing)

| # | Required | How it counts as complete in comments |
| --- | --- | --- |
| 1 | Numbered AC- original text | AC pasted in comments/description, or openable issue-tracker/PRD link |
| 2 | T1 wiki link | **t1-cases** wiki URL (preferred); or already-imported issue-tracker case set |
| 3 | G2 PASS evidence | Leader writes G2 PASS |
| 4 | Frontend + backend changes | SHA + file list, or MR/PR link |
| 5 | Post-implementation API contract | API platform/OAS link, or **N/A (reuse xxx)** |

| Optional | Note |
| --- | --- |
| T1 design-trace summary | `multica-test-t1-design` design-trace table |
| T1 case-set link | URL of T1 case set already imported to issue-tracker |
| Leader T1 review conclusion | review Pass record (not import authorization) |

Missing any **required** item → output orchestration "Interrupted: awaiting human to add to Issue comments" table, **do not** write a coverage conclusion.

## Flow

1. Read all comments, assemble the 5 items; if missing → interruption list, stop.
2. **Must read T1 artifact**: T1 wiki `t1-cases.md` link (comments or issue description); T2 **only writes delta relative to T1**.
3. For each AC-: implementation evidence (diff/contract)? Can T1 actually verify it? Need new interface cases?
4. Signal mapping: new path/field → supplement interface case; new page/popup → supplement functional case; pure refactor → regression risk; AC present but diff absent → **implementation gap**.
5. **Wiki landing** + **automation into repo** (see §§ below) → return T2 link.
6. Output the template below. Conclusion only: `evaluation complete` or `evaluation BLOCKED`.

Supplemented cases must be written back to T1 wiki: revise t1-cases → review → republish. After 👤 passphrase, optional XMind/issue-tracker phase C (see t1-design generation-workflow).

## Automation into repo (T2 · Git)

See `docs/test-automation-in-repo.md`. **Read first** the **MULTICA.md §2** of each repo in the Issue matrix.

| Type | Path source |
| --- | --- |
| UI Playwright | MULTICA.md `UI E2E` (usually in frontend repo) |
| API manifest | MULTICA.md `API manifest` (usually in backend repo) |

**Merge into**: deploy branch; Leader comment posts the path in MULTICA + commit SHA.

## Wiki Landing (T2)

**Hard rule**: include **T1 wiki link**; supplemented CASE writes **body** (not just a table); **no XMind**.

**Local draft**: `docs/test/<ISSUE-KEY>/t2-coverage.md`

Publish:
- If a wiki platform skill is mounted:
  ```bash
  python <wiki-platform>/scripts/publish_design.py \
    <ISSUE-KEY> docs/test/<ISSUE-KEY>/t2-coverage.md \
    --append-issue-tracker --json
  ```
- Otherwise: share the local draft link with Leader directly.

Issue-tracker block: `h3. T2 Coverage Evaluation (Coverage T2)`.

## Platform Collaboration

| Platform skill | Used for |
| --- | --- |
| wiki platform (optional) | Read T1 child page; publish `t2-coverage.md` |
| issue tracker platform (optional) | Issue Hub; append link |
| API testing platform (optional) | T2 supplements scenarios by checklist |

T2 material main source is still Issue comment assembly; T1 body uses **wiki t1-cases link** as source of truth. If no platform skill is mounted, obtain materials from Leader-provided links.

## Output Template

```markdown
# T2 Coverage Evaluation — {JIRA_KEY}

## Conclusion
**evaluation complete | evaluation BLOCKED** — {one line}

## Materials
- AC source / T1 case set / G2 SHA / change list / contract or N/A

## AC Coverage
| AC- | T1 case | Implementation evidence | Status |
|-----|---------|-------------------------|--------|
| | | | covered / false-covered / gap / not delivered / conditional case |

## Case Supplement List
| ID | Action | Required? | Note |
|----|--------|-----------|------|

## New interface cases needed
- none / yes (path + reason). Write target: API platform

## Regression risk
- …
```

## Why it works

T2 only does static gap evaluation, separated from T3 runtime verification; automation assets land in T2, execute in T3.
