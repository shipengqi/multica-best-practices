---
name: multica-artifact-architect
description: Architect artifact thin orchestration—validate design draft spec then publish. Used by @Architect to publish design documents. Swappable platform.
metadata:
  local_draft: "docs/design/<ISSUE-KEY>/design.md"
---

# Artifact · Technical Design Sync

## Purpose

**Governs only what the architect artifact must contain and how to self-check before publishing**; knowledge-platform upload, parent-page resolution, and Issue write-back are all handled by the platform skill.

> This skill decouples "platform integration" from "role prompt": the role prompt only says "produce technical design", not which platform. Changing companies means editing only the platform skill, not this skill or the @Architect role prompt.

## Platform Collaboration

| Platform skill | Used for |
| --- | --- |
| wiki platform skill (optional) | Publish design doc; upsert by title updates version |

Credentials and CLI details: **only look in the platform skill**.

## @Architect Standard Flow

```text
1. multica-technical-design       — write docs/design/<ISSUE-KEY>/design.md
2. Self-check (see table below)
3. Publish via mounted platform skill → return link to Leader
```

## Parent Page Rule (Issue Hub)

The Issue carries a reference to the upstream requirement document (via Leader dispatch, issue description, etc.). That requirement document is the **documentation root** (PRD Hub) for this requirement.

| Rule | Explanation |
| --- | --- |
| Default parent page | The requirement/PRD page for this Issue (provided by Leader at dispatch; or resolved via an issue tracker platform skill if mounted) |
| Child page | Technical design and all subsequent document artifacts are published as **child pages** of that requirement page |

## Architect Artifact Spec (self-check before publishing)

Local draft: `docs/design/<ISSUE-KEY>/design.md`.

| Section | Required | Content requirement |
| --- | --- | --- |
| **Document Header** | Yes | Creator, created, version, status, issue, upstream PRD |
| **Understanding** | Yes | Aligned with PRD/Issue, no scope expansion |
| **Non-Goals** | Yes | Explicitly what is not being done |
| **Proposed Change** | Yes | Smallest viable solution |
| **Affected Components** | Yes | Table: component/file/service · change type · notes |
| **Data and State** | When applicable | Entity/field/state changes |
| **Interface and Contract Boundary** | When applicable | Frontend/backend/UI boundary |
| **Implementation Steps** | Yes | Executable steps for @FrontendDev / @BackendDev |
| **Verification Plan** | Yes | Table: verification item · method · corresponding AC- |
| **Requirement Traceability** | Yes | AC-/FR-/BR- → design decision → implementation step |
| **Risks and Constraints** | Yes | Table: RISK-n · risk · mitigation |
| **Review Response** | On re-review | Response to each ArchReviewer REV-n item |
| **Revision Log** | Yes | Date · version · author · change |

Self-check FAIL → fix the draft first, do not call the platform skill.

## Usage (role side)

```text
First use multica-technical-design to write docs/design/<ISSUE-KEY>/design.md,
then use multica-artifact-architect to self-check, publish via platform skill, and return the link.
```

## Swap Platform (no role-prompt change)

Replace this skill's "Platform Collaboration" section with your tool (internal Wiki / Notion / Feishu / Git repo doc), keeping the "upload + return stable reference" interface unchanged.

- **Upload A (Git repo)**: place under the repo's agreed doc dir (e.g. `docs/design/<issue-id>.md`), reviewed together with the code PR — traceable.
- **Upload B (Wiki)**: create / update a design page, return the link.

## Why it works

Artifact skill stays thin: spec and flow in artifact, capabilities and scripts in platform; the Issue's requirement document link naturally groups subsequent documents under the same requirement tree, without needing a hardcoded global page ID.
