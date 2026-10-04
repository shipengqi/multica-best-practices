# Coverage Dimensions (T1 Step 3)

> Integrated from `test-case-generator-squad` Steps 1–2. Used with [`coverage-checklist.md`](coverage-checklist.md).

## Dimension Selection (per Module)

| Dimension | When Required | When Can Skip |
| --- | --- | --- |
| **Happy path & branches** | Always for functional requirements | No (core AC coverage) |
| **Error scenarios** | When spec defines error handling, validation, permission rules | Pure backend with no validation |
| **Boundary values** | When there are inputs, filters, numbers, uploads, thresholds | Pure display, no input constraints |
| **State transitions** | When there are status changes, workflows, stateful operations | Stateless operations |
| **Permission rules** | When there are role-based access or permission gates | No permission model in scope |
| **UI/UX checks** | When there are new UI components, layouts, or visual changes | Backend-only changes, no UI |

## Scalability by Requirement Size

| Size | Characteristics | Coverage Strategy |
| --- | --- | --- |
| **Small** | 1–2 functional points / single-page change | Core happy path + 1–2 key error cases; boundary optional |
| **Medium** | 3–5 functional points / form-heavy / role-based | Happy path + branches + boundary per input; UI spot checks |
| **Large** | 5+ functional points / multi-module / complex workflow | Happy path + error + boundary + state + permission + UI for each module |

**No case count limits** — coverage is complete when every AC and dimension is tested; don't add cases for hypothetical scenarios not in the requirement, and don't skip known dimensions.

## Happy Path & Branch Scenarios

For each AC or workflow step:
- Normal case (spec success path)
- Alternative branches (if spec lists alternatives: different role, different data, etc.)
- At least one negative per functional point (what happens when AC condition is not met?)

## Error & Exception Scenarios

For each defined error or validation:
- Validation failure (required field missing, format invalid, value out of range)
- Permission denied (user lacks required role or access)
- System error (API timeout, database unreachable, external service fails) — only if spec defines behavior
- Data conflict (duplicate, already exists, constraint violation) — only if spec defines

## Boundary Values

For each numeric, string, date, or file input:
- Minimum value (or smallest valid)
- Maximum value (or largest valid)
- Just above and just below valid range (boundary ± 1)
- Empty / null / zero
- Very large input (overflow-like, but still parseable)
- Special characters or format edge cases (if relevant)

## State Transitions

If there are workflows with multiple states:
- Each state transition defined in AC
- Invalid state transition (jumping across states, or backward if not allowed)
- Concurrent state changes (if applicable)

## Permission & Access Control

If there are role-based or permission-gated operations:
- Admin / normal user / guest / no access for each case
- Permission changes mid-workflow (if spec covers it)

## UI & Layout Checks (Qualitative, Not Pixel-Perfect)

If there are UI changes:
- Element presence (all required fields, buttons, links present)
- Layout consistency (form structure, spacing, alignment)
- State indicators (loading, empty, error, disabled states)
- Responsive behavior (mobile / tablet / desktop if in scope)
- Text and labels (no typos, correct translations, variable substitution)
- Interactive elements (click, hover, focus, keyboard navigation)

**Skip**: exact pixel dimensions, hex color codes, border radius, or animation timing — those are design QA, not functional test coverage.

## Coverage Matrix (Mandatory Pre-Generation)

Build this matrix for each module before writing cases; record it in the coverage report:

```markdown
## Coverage Matrix

### Module: {Module Name}

| Dimension | Status | Notes |
| --- | --- | --- |
| Happy path (AC-X) | ✓ Covered (cases TC-F-xxx) | … |
| Error: validation | ✓ Covered | field A required, field B format |
| Error: permission | ✓ Covered | user without {permission} |
| Boundary: quantity | ✓ Covered | min=0, max=1000, overflow |
| Boundary: date | ✓ Covered | past date, future date |
| State: {state-name} | ✓ Covered | transition paths |
| UI: layout | ✓ Covered | 3 new form fields, responsive |
| **Not in scope** | — | Feature X (separate issue) |

### Module: {Another Module}
…
```

## How to Avoid Redundancy

- Same module + same scenario + same AC + same operation path → one case
- Negative cases with equivalent outcomes can be merged into one case with multiple failure scenarios (optional but cleaner)
- If same case applies to two modules (cross-cutting), put it in the primary module and reference it in the other

## When to Separate Cases vs. Merge

**Separate** (one case per scenario):
- Different ACs
- Different input data (even in same operation)
- Different expected outcomes
- Different priority or risk level
- PRD explicitly calls out a distinct scenario or edge case

**Can merge** (multiple scenarios in one case with branched steps):
- Same AC, equivalent error types (different field validation failures)
- Same operation, equivalent boundary cases (zero, null, empty all produce "invalid input" error)
- Only if the merge doesn't exceed ~5 steps and both outcomes are tested
