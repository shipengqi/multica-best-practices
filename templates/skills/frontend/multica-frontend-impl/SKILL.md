---
name: multica-frontend-impl
description: Frontend implementation—read upstream (Issue/PRD/design/UI/API), implement UI/interaction/experience and verify API integration. The preferred mount for @FrontendDev.
version: 1.0.0
metadata:
  upstream:
    - multica-design-ui-impl
  downstream:
    - multica-artifact-frontend
    - multica-verification
---

# Frontend Implementation

## Purpose

Within confirmed design and Issue scope, deliver **UI / interaction / experience** as a usable interface and correctly integrate APIs.

> Division of labor with `multica-artifact-frontend`: **frontend-impl governs how to read upstream and how to write components and experience; artifact-frontend governs the impl-spec document standard and publishing**.

## Before Starting: Read Upstream (Required)

| Order | Source | How to obtain |
| --- | --- | --- |
| 1 | Issue / Acceptance Criteria | Leader dispatch info or Issue body; if an issue tracker platform skill is mounted: use its fetch tool |
| 2 | PRD | Document link provided by Leader (any format); if a wiki platform skill is mounted: use its page-read tool |
| 3 | Architecture design | Design link provided at dispatch; if a wiki platform skill is mounted: use its page-read tool |
| 4 | UI design | Link returned by @Designer via `multica-design-ui-impl` |
| 5 | API contract | Link returned by @BackendDev via `multica-artifact-backend` |
| 6 | Existing frontend code | Local read / codegraph |

Contract or UI missing → **mock first** and record the mock strategy; interface semantics unclear → **BLOCKED**, do not invent APIs.

## Experience-First Flow (Core)

```text
1. Read AC- / UI / architecture "Implementation Steps (Frontend)" → list pages and state machines
2. Write/update impl-spec.md (hand to multica-artifact-frontend for publishing, optional but recommended)
3. Implement by state: default → loading → empty → error → no-permission
4. Interaction: immediate feedback, duplicate-submit prevention, human-readable error messages
5. API integration: strictly follow contract; error branch and retry UX written into impl-spec
6. Component/interaction tests + manual walkthrough of critical paths
7. Attach reproducible verification evidence
```

**Rules**:

- **Interaction and experience** are equal priority to functionality: do not only implement the happy path.
- Do not change the API contract; raise issues back to @BackendDev.
- Responsive / accessibility follows project baseline; at minimum ensure key flows are keyboard-navigable.
- No unrelated refactoring; gate judgment is by Leader rerunning `multica-verification`.

## Coding Rules

1. Read UI and contract before writing components.
2. Single responsibility per component; reuse the design system.
3. Use mocks when backend is not ready; switch to real contract when available and remove temporary mocks.
4. Report changed files + commands + results.

## Completion Evidence

- Frontend implementation spec link (if published)
- Page/component code + tests
- Mock description (if used)
- Traceability to AC- / API-ID
- Known issues

## Mount Order (@FrontendDev)

```text
multica-frontend-impl → multica-artifact-frontend
```

## Why it works

Interaction and state completeness are most easily missed in frontend; impl-spec attached to the requirement doc tree lets review and testing compare against the same spec.
