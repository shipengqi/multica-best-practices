---
name: multica-technical-design
description: Produce a minimal technical design based on PRD and existing code. Used for architecture analysis, impact assessment, and implementation-plan design; draft handed to multica-artifact-architect for landing after completion.
---

# Technical Design

## Purpose

Based on the PRD (or Issue) and the existing codebase, produce the **smallest viable** technical design (governs "what to write", not "which platform to land to").

> Division of labor with `multica-artifact-architect`: **technical-design produces structure and content; artifact-architect validates the artifact and calls platform skills to publish**.
> Used with `multica-review-architect`: **draft → review → revision → re-review** (up to 3 rounds); each revision must increment the version and fill in the "Review Response".

This skill only produces a local `design.md`; credentials and publish CLI are in the platform skill.

## Process

1. Read PRD / Issue and acceptance criteria (AC-/FR-/BR-).
2. Inspect the current implementation (prefer codegraph / existing patterns; do not broad-scan the repo).
3. Identify relevant modules and existing patterns.
4. Determine the smallest viable change; write **non-goals** clearly.
5. Identify data/interface/non-functional impacts and dependencies (RISK-, DECISION-).
6. Define verification method (aligned with AC-); fill the **requirement traceability** table.
7. Write the **document header** (creator, date, version, status).
8. Insufficient information → BLOCKED, write into "Open Questions", do not guess.

## Principles

```text
Existing patterns > new abstractions
Small changes     > big refactors
Reuse             > new dependencies
Verifiable        > unverifiable assumptions
Reversible        > one-way irreversible changes
```

## Local Draft Path

```text
docs/design/<ISSUE-KEY>/design.md
```

## Document Header (Required, placed under the H1 title)

The **first block** of the design body must be a metadata table, so ArchReviewer can track versions and responsibility:

| Field | Rule |
| --- | --- |
| **Creator** | `Architect-<member-id>` (consistent with Squad member) |
| **Created** | `YYYY-MM-DD HH:mm` (team's agreed timezone) |
| **Version** | Semantic `v0.1` start; **increment for each review revision** (v0.2, v0.3 …) |
| **Status** | `Draft` → `In Review` → `Approved`; deprecated: `Deprecated` |
| **Issue** | Issue Key (JIRA or platform equivalent) |
| **Upstream PRD** | Requirement document link (resolved from Issue; do not leave blank) |

Example:

```markdown
# Technical Design — PROJ-1813 Chunked Upload

| Field | Value |
| --- | --- |
| **Creator** | Architect-u1024 |
| **Created** | 2026-08-26 15:30 |
| **Version** | v0.1 |
| **Status** | Draft |
| **Issue** | PROJ-1813 |
| **Upstream PRD** | https://your-wiki/pages/viewpage.action?pageId=... |
```

## Output (must include)

| Section | Required | Content |
| --- | --- | --- |
| **Document Header** | Yes | Creator, created, version, status, issue, upstream PRD |
| **Understanding** | Yes | What the system currently does; aligned with PRD scope |
| **Non-Goals** | Yes | Explicitly what is not being done; prevents scope creep |
| **Proposed Change** | Yes | Smallest viable solution; optionally brief "alternatives and trade-offs" |
| **Affected Components** | Yes | File / module / service · change type · notes |
| **Data and State** | When applicable | Entity/field/state changes; consistency requirements |
| **Interface and Contract Boundary** | When applicable | Frontend/backend/UI boundary; error and auth conventions |
| **Implementation Steps** | Yes | Executable steps for @FrontendDev / @BackendDev |
| **Non-Functional Requirements** | As needed | Performance, security, availability, observability |
| **Migration and Rollback** | As needed | Data migration, feature flags, rollback steps |
| **Verification Plan** | Yes | Verification items · method · corresponding AC- |
| **Requirement Traceability** | Yes | AC-/FR-/BR- → design decision → implementation step |
| **Risks and Constraints** | Yes | RISK-n · risk · mitigation |
| **Open Questions** | If any | DECISION-n; BLOCKED items |
| **Review Response** | On re-review | Response to each item in ArchReviewer's change list |
| **Revision Log** | Yes | Date · version · author · change summary |

## Architect's Review Perspective (easily missed)

Design reviews commonly probe these angles; cover them in the first draft:

| Angle | Self-check question |
| --- | --- |
| **Scope** | Is non-goal written clearly? Is scope silently expanded? |
| **Data** | Who writes, who reads? Consistency/transaction boundary? What about historical data? |
| **Concurrency and Idempotency** | Are duplicate submission, race conditions, and retries considered? |
| **Failure and Degradation** | What happens if a dependency goes down? Is partial failure acceptable? |
| **Security** | Is auth, sensitive data, and audit logging addressed? |
| **Performance** | Volume assumptions? Hot paths? Need async/cache? |
| **Testability** | Can implementation steps map to executable verification? |
| **Operations** | Deployment order, config items, monitoring/alerting, rollback? |
| **Cross-platform Consistency** | Does it conflict with UI/API contract? Are error codes/state machines unified? |
| **Traceability** | Can every AC- be found in the design? |

## Review-Revision Flow (with multica-review-architect)

1. Read the **ArchReviewer change list** forwarded by Leader (includes blocking item IDs).
2. **Version +1** (e.g. v0.1 → v0.2), status changes to `In Review`.
3. Fill in the **Review Response** table item by item: modified / not adopted (must give reason).
4. Update affected sections; append a row to **Revision Log**.
5. Self-check again → `multica-artifact-architect` → publish via platform skill (Confluence upsert by same title will update the version).
6. Notify Leader of revision; enter next ArchReviewer re-review round (up to 3 rounds).

Blocking items not adopted require Leader arbitration; Architect may not close the review unilaterally.

## Handoff

```text
First use multica-technical-design to write docs/design/<ISSUE-KEY>/design.md (with document header),
then use multica-artifact-architect to self-check and publish, returning the link.
```

## Why it works

Document header + version + review response makes multi-round ArchReviewer reviews auditable and diff-able; the section coverage over data/non-functional/traceability angles reduces rework during downstream implementation.
