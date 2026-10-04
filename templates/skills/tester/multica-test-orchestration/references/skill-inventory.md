# Test Skill Cross-Reference

> Integrated from `acceptance-verifier-squad/INVENTORY.md`. Multica skills are **mounted by name**; paths in `templates/skills/` category directories.  
> **Do not** hardcode old `-squad` names or local absolute paths in Agent instructions; only reference `multica-*` skill names.

## Mount Order (@Tester)

1. **`multica-test-orchestration`** — cross-phase routing (recommended single mount)
2. Read sub-skills by phase (see table below)
3. Platform / Reviewer skills declared in sub-skill `metadata.orchestrates`

## Phase → Skill Mapping (Original Squad Reference)

| Phase | Skill | Origin Squad | Purpose |
| --- | --- | --- | --- |
| Orchestration | `multica-test-orchestration` | acceptance-verifier-squad | Routing, gates, skill inventory |
| T1 design | `multica-test-t1-design` | test-case-generator-squad + ac-design-trace-squad | Methodology + case templates; no tool scripts |
| T1 review | `multica-review-test` | test-case-review-squad | Reviewer role; design review only |
| T1 platform export | (downstream of orchestration) | (team chooses platform) | Markdown → wiki/issue-tracker (not in Multica) |
| T2 coverage | `multica-test-t2-coverage` | ac-coverage-t2-squad | Gap evaluation |
| T3 UI | `multica-test-t3-ui-automation` | functional-ui-auto-squad | pytest UI execution |
| T3 API | `multica-test-t3-api-automation` | software-development | Orchestration + execution + validation |

## T1 References (Key Files)

| File | Purpose |
| --- | --- |
| `multica-test-t1-design/references/test-case-template.md` | Functional + API case structure and fields |
| `multica-test-t1-design/references/design-trace.md` | AC ↔ design ↔ case traceability |
| `multica-test-t1-design/references/coverage-dimensions.md` | Dimension taxonomy (happy path, boundary, state, permission, etc.) |
| `multica-test-t1-design/references/coverage-checklist.md` | Pre-generation self-check list |
| `multica-test-t1-design/references/multimodal-content.md` | Reading text, tables, diagrams, UI mockups |
| `multica-review-test/checklist.md` | Review evaluation criteria |

## Don't Mix

- T1 import: **only** via your team's platform integration (not in Multica core)
- T1 review: **only** `multica-review-test` (TestReviewer role; never imports)
- T3 UI: **do not use** xmind-ui-automation / playwright.git / req-figma-ui-automation
- **Do not mount** legacy squad names (e.g., `test-case-generator-squad`); use `multica-*` skill names only

## Agent Instructions Entry Points

| Skill | Copyable Instructions |
| --- | --- |
| Orchestration | `multica-test-orchestration/references/agent-instructions.md` |
| T1 design | `multica-test-t1-design/SKILL.md` (integrated) |
| T1 review | `multica-review-test/references/agent-instructions.md` |

