# Issue Template

> Copy into a new Issue, fill it in, then hand it to the Squad.

```markdown
# Bug

## Issue source (required, pick one)
<!-- With "External link", only fill link + repro summary + impact area, skip the rest and reference the KEY in References; full details live in Jira/Tapd etc. -->
- [ ] External link (lightweight): only fill "link / one-line repro summary / impact area"
      - Link: https://jira.example.com/browse/<ISSUE-KEY>
      - Summary: <!-- one line on the symptom -->
- [ ] Fully self-contained (default): this Issue is the requirement; fill in all sections below

## Repro steps
1.
2.
3.

## Expected behavior
<!-- What should happen -->

## Actual behavior
<!-- What actually happened -->

## Impact area
- Affected ends (check; unchecked means no role dispatched):
  - [ ] Frontend
  - [ ] Backend
- Affected users / modules / versions:

## Root-cause hypothesis
<!-- If known, write it here -->

## Fix requirements
- [ ] Locate the root cause
- [ ] Minimal-scope fix
- [ ] Regression test (or explain why it can't be automated)

## Acceptance criteria
- [ ] The issue no longer reproduces with the repro steps
- [ ] Existing behavior doesn't regress
- [ ]

## References
<!-- Logs, screenshots, error messages, relevant code locations -->
```

---

## Why it's written this way

The first priority of a Bug Issue is "reproducible." With the repro steps + expected/actual behavior written out, the implementer can locate the root cause without guessing.

## Common failure modes

- **A one-line description with no repro steps**: the implementer can only guess-and-patch; the root cause is never found, and the fix breaks one place while healing another.
- **Repro steps depend on environmental details that were left out** (version, data, auth state): others can't reproduce, so the gate can't reach PASS.
- **Missing expected/actual behavior**: after a change there's no way to tell "it's fixed" — the acceptance criteria become decorative.
- **A "solution" given instead of a root cause**: this template wants a root-cause hypothesis, not a patch written into the Issue; root-cause-less fixes almost always regress.
- **Regression verification skipped**: changing code without adding a regression case means the same trigger will blow up again next time.
