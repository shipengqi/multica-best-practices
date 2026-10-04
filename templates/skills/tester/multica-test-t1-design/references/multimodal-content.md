# Multimodal Content Handling (Text, Tables, Diagrams, UI Mockups)

> Ensure no requirements are lost: handle text, tables, diagrams, screenshots, data dictionaries, flow charts embedded in requirements.

## Types of Multimodal Content

Requirement documents often contain:
- **Structured tables**: feature matrix, permission matrix, response codes
- **Lists & hierarchies**: numbered steps, nested processes, role-based access
- **Diagrams**: flow charts, state machines, sequence diagrams, deployment diagrams
- **Screenshots**: UI mockups, error messages, state examples
- **Data dictionaries**: field definitions, value ranges, constraints
- **Code samples**: API examples, configuration templates

## Key Rule: Preserve Structure

Never flatten structured content into plain text. Preserve:
- **Table rows/columns** and header meanings
- **List hierarchy** and ordering
- **Diagram semantics** (nodes, edges, decision points)
- **Screenshot labels** and interactive element states

Example:
- ❌ Wrong: "Table rows 1, 2, 3 contain status values"
- ✅ Right: Preserve the table in coverage report, referencing exact row/column

## Reading Requirements (Step 1–2)

When Leader provides materials (Issue body, PRD link, design file link, API contract):

1. **Download / Access**: Retrieve the document or file from the provided link
2. **Read multimodal content**: Use the Read tool on images, screenshots, PDFs
3. **Extract structure**: For tables, preserve row/column mapping; for diagrams, note nodes and edges; for mockups, identify interactive elements
4. **Cross-check**: If requirement mentions "status A → B" AND diagram shows state machine, verify they align
5. **Mark conflicts**: If text says "field X is required" but diagram shows it optional, flag the conflict

## Handling Specific Types

### Tables (Requirement Matrix, Permission Matrix, Status Codes, etc.)

```
❌ Lose structure → "permission levels are admin, user, guest"
✅ Keep structure →
| Role | Read | Write | Delete |
|------|------|-------|--------|
| Admin | ✓ | ✓ | ✓ |
| User | ✓ | ~ | ✗ |
| Guest | ✓ | ✗ | ✗ |
```

### Diagrams (Flow Charts, State Machines, Sequences)

Extract:
- Decision points and branches
- State transitions (which states follow which)
- Role interactions or system boundaries
- Error paths vs. happy paths

```
❌ Lose semantics → "flow has 5 steps"
✅ Keep semantics → 
  User Login
    ↓ [success]
  Dashboard (admin: show admin panel)
    ↓ [user clicks report]
  Report Page
    ↓ [error]
  Error Message → Retry
```

### UI Mockups / Screenshots

Identify and note:
- Layout grid and responsive breakpoints
- Form fields (type, validation, placeholder)
- Button placement and labels
- Interactive states (hover, disabled, loading)
- Error message placement
- Empty / loading / error page variants

### Data Dictionaries / Field Definitions

Preserve:
- Field name, type, format, constraints
- Valid value ranges or enums
- Null handling rules
- Relationships to other fields

## Conflict Resolution (Priority Order)

If requirement text conflicts with design or diagram:

1. **AC (Acceptance Criteria)** — Always primary
2. **Current PRD / Requirement document** — Supersedes design
3. **API Contract** — For interface specs
4. **Design mockups / diagrams** — Visual reference, not prescriptive
5. **Historical notes / knowledge base** — Context only, not spec

If conflict found: **Flag it** in the coverage report and ask for clarification (do not guess).

## Checkpoints Before Test Case Generation

- [ ] All tables read and structure preserved
- [ ] All diagrams understood (states, flows, roles)
- [ ] All screenshots analyzed for UI elements and states
- [ ] All data dictionaries mapped to preconditions (permissions, data setup)
- [ ] All conflicts between text/diagram/design noted and escalated
- [ ] Visual information translated into test-executable steps (e.g., "field X is shown as optional in mockup" → test both with and without X)
- [ ] Coverage report includes source of information (text / table / diagram / screenshot / API contract)
