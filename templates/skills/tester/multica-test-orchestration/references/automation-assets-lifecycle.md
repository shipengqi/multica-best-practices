# Automation Assets Lifecycle (UI e2e + API Testing + Git)

Works with `docs/test-automation-in-repo.md`; @Tester accumulates materials in T1/T2, executes in T3.

---

## Overview

```text
T1  Local test cases (Markdown) + API contract analysis
    ↓ Review + decision
T2  Coverage delta + e2e script skeleton (per MULTICA §2) into repo
    ↓ G2 PASS commit
T3  Run e2e scripts (pytest) + API tests against deployed environment → fix & commit
```

---

## UI E2E (Playwright)

| When | Action |
| --- | --- |
| T1 | In case set: write CASE-ID, steps, expected results (**no script code**) |
| T2 | For cases marked "must automate": create script skeleton in `{e2e_dir}/test_{case_id}.py` (locator can be TODO → T3 BLOCKED if still missing) |
| T3 | Run `pytest {e2e_dir}/` against `deploy_url`; FAIL → triage → fix script → commit |

Framework: Use `multica-test-t3-ui-automation/references/framework-template.md`. **Target directory = MULTICA.md §2 e2e path** (do not create temp directories each time).

---

## API Testing

| When | Action |
| --- | --- |
| T1 parallel | After API contract published: analyze contract → identify test scenarios |
| T2 | Add/update test scenario coverage; record in manifest or automation plan |
| T3 | Execute API tests against deployed environment; validate responses |

Method depends on your team's API testing platform (Postman, Apifox, pytest, etc.) — not specified in Multica core.

---

## Git Integration

- **Path**: per-repo root **MULTICA.md** §2 (each split repo reads its own MULTICA)
- **Branch**: match Issue deploy branch; commit before G2 sign-off
- **Commit**: e2e scripts, manifest; do not commit `.env` or secrets

---

## Case Format Continuity

T1 deliverable (local Markdown case set) flows directly into T2/T3:
- Case IDs and steps become automation targets
- Expected results guide assertion logic
- Traceability (case → AC) remains intact through automation
