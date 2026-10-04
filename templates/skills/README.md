# Skills Index

This directory contains shared Skills ready to mount in [Multica](https://github.com/multica-ai/multica), **grouped by role** (`architect/` / `backend/` / `designer/` / `devops/` / `frontend/` / `leader/` / `platform/` / `product-manager/` / `reviewer/` / `shared/` / `tester/`). Each skill is a subdirectory; `SKILL.md` is the instruction the agent reads. Skills with scripts also include a human-facing `README.md`.

Role grouping is **a filing convention only** — it has nothing to do with the four capability layers. Mounting only uses the `name` in `SKILL.md`. A single group can span layers (`platform/` is all platform-layer; `tester/` spans content + orchestration).

Four-layer model (see [`docs/en_US/role-skills-architecture.md`](../../../docs/en_US/role-skills-architecture.md)): **content** (what "good" looks like) + **orchestration** (land artifacts to team platforms) + **platform** (the only layer touching external systems) + **review** (executed by non-producers).

## Platform layer (shell templates — fill URL/credentials in `.env`)

| Skill | Purpose |
|---|---|
| `multica-platform-jenkins` | Trigger Jenkins builds / deploys / promotions |
| `multica-platform-github-actions` | Trigger GitHub Actions workflow dispatches, poll run status, fetch job logs |

**All platform skills are optional enhancers.** Content-layer skills work without them — agents read from Leader-provided links directly. Mount a platform skill when you want automatic fetch/publish.

## Orchestration layer (call platform layer to land artifacts and return stable links)

| Skill | Purpose |
|---|---|
| `multica-pm-artifact-publish` | PRD / requirement → team requirement platform |
| `multica-artifact-architect` | Technical design → document platform / Git |
| `multica-artifact-backend` | API contract → team API platform |
| `multica-design-ui-impl` | UI spec → team design platform |
| `multica-artifact-frontend` | Frontend implementation notes → document platform |
| `multica-artifact-cicd-sync` | Code review conclusion → trigger CI (Jenkins / GitHub Actions when mounted), return deploy URL |

## Content layer (define what "good" means)

| Skill | Purpose |
|---|---|
| `multica-pm-requirement-spec` | Requirement analysis: structure requirement into a numbered PRD |
| `multica-technical-design` | Technical design draft (with metadata and revision log) |
| `multica-backend-impl` | Backend implementation: contract-first + TDD |
| `multica-frontend-impl` | Frontend implementation: experience and state completeness |
| `multica-verification` | Leader generic gate: evidence complete, AC aligned |
| `multica-test-orchestration` | Cross-phase test routing (T1/T2/T3) and adjudication |
| `multica-test-t1-design` | T1 functional cases: traceability matrix + coverage dimensions |
| `multica-test-t2-coverage` | T2 coverage evaluation (against T1 and implementation diff) |
| `multica-test-t3-ui-automation` | T3 UI automation (1 CASE = 1 test) |
| `multica-test-t3-api-automation` | T3 API automation batch run |

## Review layer (executed by non-producers)

| Skill | Purpose |
|---|---|
| `multica-review-product` | Product / value review |
| `multica-review-architect` | Architecture review |
| `multica-review-designer` | UI / interaction review |
| `multica-review-frontend` | Frontend review |
| `multica-review-backend` | Backend review |
| `multica-review-test` | Test artifact review |
