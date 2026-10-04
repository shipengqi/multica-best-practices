# AC ↔ Design Traceability (T1 Step 1)

> Establishes the connection between acceptance criteria, design elements, and test cases **before** generating cases. The traceability table is included in the coverage report.

## Inputs

- **Acceptance Criteria (AC)**: From the Issue body, PRD, or requirement document (preferably with AC numbers like AC-1, AC-2, etc.)
- **Design**: From design mockups, API contracts, or architecture documents (provided by Leader as links; read directly)

If no design exists: note in the report "no design provided; T1 generated from AC only" — do not invent design points.

If AC is incomplete or vague: list what you have, note the gaps, and ask Leader for clarification before proceeding — do not guess AC or widen scope.

## Rules

- **Coverage denominator = AC only**: Design elements that have no corresponding AC go into "design observations" section, not into the coverage count
- **Conflict resolution** (if AC and design disagree): AC statement > linked PRD > design document > team knowledge base
- **Operational information** (menu paths, permission names) can be extracted from design and used in test case steps; avoid expanding operational details into new ACs

## Output Template

Record in the coverage report:

```markdown
## AC ↔ Design Traceability

### Traceability Table

| AC ID | AC Text | Design Section | Test Coverage | Mapped Cases |
|-------|---------|-----------------|---|---|
| AC-1 | {brief} | § Design > {section} | ✓ {dimension} | TC-F-xxx, TC-I-yyy |
| AC-2 | {brief} | § Design > {section} | ✓ {dimension} | TC-F-zzz |
| AC-3 | {brief} | (no design) | ✓ {dimension} | TC-F-aaa |

### Design Elements Not Covered by AC

- {Design point X}: {why not in AC} → recorded as observation, not coverage requirement
- {Design point Y}: {why not in AC}

### Coverage Scope

- **In scope (AC + design)**: Total AC count = {N}
- **Test cases planned**: {M} functional + {K} API = {M+K} total
- **At-risk AC** (no design detail yet): [none / AC-X, AC-Y]
```

## Why Separate Traceability

Locking the AC denominator before case generation prevents scope creep (e.g., design documents suggesting additional edge cases not in AC). This keeps coverage focused and ensures agreed-upon scope is tested.
