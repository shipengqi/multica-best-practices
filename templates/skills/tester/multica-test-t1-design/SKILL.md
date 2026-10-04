---
name: multica-test-t1-design
description: T1 test design—from requirements and design to test cases, with AC↔design traceability and coverage self-check. Platform-agnostic methodology and templates.
version: 4.0.0
metadata:
  origin:
    - ac-design-trace-squad
    - test-case-generator-squad
---

# Test Design (T1 Test Design · Methodology + Templates)

## Position

**Pure methodology layer**: requirements → design → acceptance criteria (AC) → test case design. Platform-agnostic; no tool-specific workflows, imports, or credentials.

| Layer | Skill | Responsibility |
| --- | --- | --- |
| **T1** | **This skill** | Methodology + universal case templates + AC traceability + coverage self-check |
| T2 | `multica-test-t2-coverage` | Incremental coverage (boundary, state, flow) |
| Orchestration | `multica-test-orchestration` | Routing, publication, and platform integration |
| Review | `multica-review-test` | Design and template correctness review |

## What This Skill Does

### Inputs
- **Requirements** (Issue body, PRD, design document links) — provided by Leader
- **Design artifacts** (UI/API contracts, design mockups) — provided by Leader
- **Acceptance criteria** (AC list from Issue or linked docs)

### Outputs
- **Test case set** (local Markdown: `docs/test/<ISSUE-KEY>/t1-cases.md`)
- **Coverage report** (traceability table, coverage matrix, self-check results)
- **No tool integration**: no JIRA keys, no Confluence publishing, no XMind generation, no platform APIs

### Responsibilities
1. Parse requirements and design into testable elements
2. Link AC ↔ design ↔ test case (end-to-end traceability)
3. Generate functional and API test case templates with correct fields
4. Define coverage dimensions (happy path, error handling, boundary, state, permission, etc.)
5. Self-check against the coverage checklist
6. Deliver the case set as platform-neutral Markdown

### What This Skill Does NOT Do
- Publish to any platform (Confluence, JIRA, XMIND, API testing tools)
- Generate or validate tool-specific formats (JSON, XML, XMind)
- Fetch data from external APIs or platforms
- Manage credentials or authentication
- Execute scripts or imports

## references/ Index

| File | Purpose |
| --- | --- |
| [`test-case-template.md`](references/test-case-template.md) | Functional and API case structure; field definitions; required context |
| [`design-trace.md`](references/design-trace.md) | How to link AC ↔ design ↔ case; traceability table format |
| [`coverage-dimensions.md`](references/coverage-dimensions.md) | Dimension taxonomy (happy path, error, boundary, state, permission, etc.); when to add each |
| [`coverage-checklist.md`](references/coverage-checklist.md) | Pre-generation self-check: scope, AC alignment, case count, executability |
| [`multimodal-content.md`](references/multimodal-content.md) | How to read and fuse understanding from text, images, and design mockups |

## T1 Flow

### Step 0 — Read MULTICA.md

Each repo (or split frontend/backend) has a root `MULTICA.md` declaring:
- Test case path (default: `docs/test/<ISSUE-KEY>/t1-cases.md`)
- Module naming convention
- Build and verify commands

Missing `MULTICA.md` → BLOCKED.

### Step 1 — Design Traceability

Use [`design-trace.md`](references/design-trace.md):
- Extract AC from Issue body or linked requirement document
- Extract design elements from design mockups / API contract
- Build a traceability table: each AC → design element → test case ID
- Record in the coverage report

### Step 2 — Collect Materials

Leader provides links in the dispatch (Issue body, PRD link, design file link, API contract). Read each directly; no platform APIs, no credentials.

For multimodal content (images, mockups): see [`multimodal-content.md`](references/multimodal-content.md).

### Step 3 — Define Coverage Dimensions

Use [`coverage-dimensions.md`](references/coverage-dimensions.md) to select which dimensions apply:
- Happy path (core AC)
- Error scenarios (validation, permission, system errors)
- Boundary values (min/max, empty, overflow)
- State transitions
- Permission rules
- Concurrency / data consistency (if applicable)

Not every dimension applies; filter by requirements.

### Step 4 — Generate Test Cases

By [`test-case-template.md`](references/test-case-template.md):
- Write functional test cases (UI flows, API calls)
- Include API test cases (interface contracts)
- Fill every required field: ID, module, title, precondition, data, type, priority, traceability link
- Precondition: state permission requirements, not account names or passwords
- Traceability: link each case to its source AC

### Step 5 — Self-Check

Use [`coverage-checklist.md`](references/coverage-checklist.md):
- Confirm AC coverage (no AC left untested)
- Confirm case executability (steps are concrete, not vague)
- Confirm permission clarity (no hardcoded usernames/passwords)
- Confirm case count and priority distribution
- Document findings

### Step 6 — Deliver

Write the complete case set to `docs/test/<ISSUE-KEY>/t1-cases.md` (path from `MULTICA.md`).

Include:
- Test case body (every case, every step)
- Coverage report (traceability table, coverage matrix, self-check results)
- Execution notes (any assumptions or edge cases)

No additional formats, no XMind, no JIRA imports, no platform-specific markers.

## Files

```text
multica-test-t1-design/
├── SKILL.md                        (this file)
└── references/
    ├── test-case-template.md       (functional + API case structure)
    ├── design-trace.md             (AC ↔ design ↔ case traceability)
    ├── coverage-dimensions.md       (dimension taxonomy and selection)
    ├── coverage-checklist.md        (pre-generation self-check list)
    └── multimodal-content.md        (reading images and mockups)
```

## Why It Works

**Decoupled from tooling**: collection (step 2) is universal, case structure (steps 4–5) is tool-independent, and delivery (step 6) is a single Markdown file that any platform can consume or ignore.

The T1 Agent is responsible for authoring cases by the checklist, not for writing collection scripts, API clients, or import tools—those are upstream (Leader provides docs) or downstream (Orchestration layer routes files to platforms).

## Key Principles

- **No credentials**: all external materials come from Leader-provided links, read manually
- **No platform coupling**: case format is Markdown; any downstream tool consumes or transforms it
- **Executable by definition**: every precondition, step, and expected result is concrete and runnable
- **Traceable by design**: every case links back to its source AC and design element
- **Self-checked before delivery**: coverage report documents what is tested and what is not
