---
name: multica-review-test
description: Test-artifact dedicated review framework—T1 case Block/Revise/Pass, T2 coverage evaluation check, T3 report PASS/FAIL/BLOCKED three-phase review; outputs conclusion and fix list to Leader. Mount for TestReviewer.
---

# Test Artifact Professional Review (TestReviewer)

Structured review framework for **test artifacts**. Integrated from `test-case-review-squad`.

## When to use

| Phase | Review target | Conclusion model |
| --- | --- | --- |
| **T1 Phase A** | `test_cases.json` + `test_cases_{KEY}.xmind` + design traceability | **Block / Revise / Pass** |
| **T2** | `multica-test-t2-coverage` output | evaluation complete / evaluation BLOCKED |
| **T3** | Merge report + UI mapping + Apifox JSON | **PASS / FAIL / BLOCKED** (Leader gate) |

**Pass ≠ import-to-tracker authorization.** This role **never** calls `import_to_tracker.py`.

Copyable agent instructions: [`references/agent-instructions.md`](references/agent-instructions.md).

---

## T1 Review (Block / Revise / Pass)

### Inputs (missing main deliverable → Block)

| Required | Description |
| --- | --- |
| Functional case JSON | `jira_key` + `functional[]` |
| XMind | `test_cases_{ISSUE_KEY}.xmind` |
| Requirement basis | Issue AC / collected PRD |

**Acceptable source (any one suffices to reconstruct `functional`):**
- Functional case JSON (`jira_key` + `functional`), or
- XMind: `test_cases_{ISSUE_KEY}.xmind` (including Issue attachment), or
- Case set already imported to JIRA / test-management platform (steps + expected)

**Both case source and requirement basis missing** → Block, list missing items and stop.

### Review order (no skipping)

1. **Lock materials** — Key matches XMind filename; missing material → Block
2. **Mechanical check** — steps/expected same length; no P0; no wiki/TBD/missing-Figma/XXX placeholders; module uses `/` hierarchy
3. **Requirements alignment** — AC coverage table; false coverage; **binary usage** (operational steps go into steps, rule statements must not become expected)
4. **Executability** — **P1 full review**; P2/P3 **sampling** (at least 1 P2 + 1 P3 per module, larger modules increase sample); check: entry path, permission semantics, data setup, verifiable expected, priority P1/P2/P3
5. **Conclusion** — Block | Revise | Pass + mandatory output template

### Severity levels

| Level | Typical examples |
| --- | --- |
| **Critical** | Missing deliverable; structural collapse; widespread placeholders; KB rule used as AC; hardcoded passwords |
| **Major** | AC gap; false coverage; no entry path; P0 or disordered priority |
| **Minor** | Verbose titles; individual expected results could better match copy |

| Conclusion | Condition |
| --- | --- |
| **Block** | Critical issue exists or materials insufficient |
| **Revise** | No Critical, but has Major |
| **Pass** | No Critical; Major = 0 (or user accepts in writing); Minor allowed |

Revise + user authorizes fix → edit JSON → `multica-test-t1-design`'s `generate_xmind.py` → **re-review one round**; still do not import.

### T1 Output Template (mandatory)

```markdown
# Case Review Report — {ISSUE_KEY}

## Conclusion
**{Block|Revise|Pass}** — {one sentence}

## Materials
- JSON: {path}
- XMind: {path}
- Requirement basis: {summary}
- Functional case count: {n}

## Critical / Major / Minor
- …

## AC Coverage Mapping
| AC item | Covering case | Status |
| --- | --- | --- |

## Knowledge base / history usage spot-check
- Operational bucket written into steps: yes / no / partial
- Rule expansion: none / present

## Import recommendation
- Block/Revise: import prohibited; revise and regenerate XMind first
- Pass: may submit for human confirmation; **this skill does not execute import**. After confirmation, instruct Tester "review passed, import to tracker"
```

---

## T2 / T3 (Leader gate style)

### T2 additional checks

- [ ] All 5 required materials traceable in comments
- [ ] Output not worded as "test report PASS/FAIL"
- [ ] "Implementation not delivered" and "cases to supplement" listed separately

### T3 additional checks

- [ ] G2.5 + deploy_url are consistent
- [ ] UI: `functional` count = pytest collected count
- [ ] Apifox report path exists
- [ ] Merge report has evidence for each AC item

### T2/T3 Output Format

```text
[Test Artifact Review] <phase T2|T3> <link or path>
Conclusion: PASS / FAIL / BLOCKED
Blocking items:
- ...
Suggestions:
- ...
Round: N / 3
```

---

## Boundaries

- Review test artifacts only; do not review implementation code
- Does not replace Leader `multica-verification`
- If still FAIL at round 3 → escalate to human
- **Even if** the user instructs this Agent to "import to JIRA", **prohibited** from executing import
