---
name: multica-backend-impl
description: Backend implementation—contract-first + TDD; read upstream (Issue/PRD/design), implement API and service layer. The preferred mount for @BackendDev.
version: 1.0.0
metadata:
  upstream:
    - multica-artifact-architect
  downstream:
    - multica-artifact-backend
    - multica-artifact-cicd-sync
---

# Backend Implementation

## Purpose

Within the approved technical design and Issue scope, complete backend implementation with **contract-first + TDD**.

> Division of labor with `multica-artifact-backend`: **backend-impl governs how to read upstream and how to write code and tests; artifact-backend governs the API contract document spec and publishing**.

## Before Starting: Read Upstream (Required)

| Order | Source | How to obtain |
| --- | --- | --- |
| 1 | Issue / Acceptance Criteria | Leader dispatch info or Issue body; if an issue tracker platform skill is mounted: use its fetch tool |
| 2 | **Linked Issues** (dependencies / upstream) | Links provided at dispatch; if an issue tracker platform skill is mounted: use its linked-issues fetch |
| 3 | PRD / Requirement body | Document link provided by Leader (any format); if a wiki platform skill is mounted: use its page-read tool |
| 4 | Architecture design | Design link provided at dispatch; if a wiki platform skill is mounted: use its page-read tool |
| 5 | Existing code | codegraph / local read, following project conventions |

Insufficient information → **BLOCKED**: write out pending clarification items; do not guess interface shape.

## Before G2: Unit Tests (Hard Gate)

**Before merging to deploy branch**, all unit tests must pass locally (or in the project's standard dev container):

```text
1. Run the project's unit test command (e.g. mvn test / npm test / pytest tests/unit)
2. Must be 0 failures; existing tests must not fail due to this change (no regression)
3. New/changed APIs must have corresponding unit tests (Red-Green-Refactor)
4. If failure: fix yourself and re-run until all green
5. Only if local cannot run (missing dependencies/hardware) → BLOCKED: list the environment gap;
   do not push and "wait for CI to check"
```

**Prohibited**: leaving unit test failures for Jenkins/CICD to discover; deleting or skipping existing tests just to pass (unless Architect/Leader has approved in writing).

CI is a **second confirmation**, not the place to run unit tests for the first time.

## TDD Flow (Core)

```text
1. Read AC- / architecture "Implementation Steps (Backend)" → list API-IDs and behaviors
2. Write/update api-contract.md (hand to multica-artifact-backend for publishing, for frontend parallel work)
3. Red   — write failing unit tests (business logic, boundaries, exceptions)
4. Green — minimal implementation to make tests pass
5. Refactor — keep tests green, do not expand scope
6. Integration verification — run project-standard command, attach evidence
```

**Rules**:

- Business logic must have **unit tests**; even pure CRUD needs exception branch and boundary coverage.
- Update contract document before updating implementation; breaking changes require version bump and notification to Leader / @FrontendDev.
- Do not silently rename fields/semantics; any deviation from the architect's design must be explained.

## Coding Rules

1. Read before editing; follow existing layering and naming.
2. Stay focused; no unrelated refactoring.
3. Error handling: implement timeouts, idempotency, and concurrency per design.
4. Report **reproducible** commands and results.

## Completion Evidence

- API contract document link (landed by `multica-artifact-backend`)
- Changed file list
- **Unit tests**: command + **all-green** results (run before merging to deploy branch; 0 failures, no regression)
- Integration tests (if project requires): command + results
- Traceability to API-ID / AC-
- Known limitations

## Mount Order (@BackendDev)

```text
multica-backend-impl → multica-artifact-backend
```

## Why it works

Contract document lets frontend/T1 proceed in parallel; TDD locks acceptance criteria into tests early, reducing rework at the G2 convergence gate.
