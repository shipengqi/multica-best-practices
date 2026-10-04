---
name: multica-artifact-backend
description: Backend artifact thin orchestration—API contract document spec and publishing. Used by @BackendDev to publish contracts for frontend/test consumption. Swappable platform.
metadata:
  local_draft: "docs/backend/<ISSUE-KEY>/api-contract.md"
---

# Artifact · API Contract Sync

## Purpose

**Governs only what the API contract must contain and how to self-check before publishing**; the publication target (API platform, wiki, or repo doc) is handled by the mounted platform skill.

> This skill decouples "platform integration" from "role prompt": the role prompt only says "produce API contract", not which platform. Changing companies (Swagger / Postman / Apifox / YApi / internal gateway) means editing only the platform skill, not this skill or the @BackendDev role prompt.

## Platform Collaboration

| Platform skill | Used for |
| --- | --- |
| API platform skill (optional) | Publish to API platform; return project/interface-group link |
| wiki platform skill (optional) | Publish contract doc as child page under the requirement page |

Credentials and CLI details: **only look in the platform skill**.

## @BackendDev Standard Flow

```text
1. multica-backend-impl        — read upstream + TDD implementation
2. Write docs/backend/<ISSUE-KEY>/api-contract.md
3. Self-check (see table below)
4. Publish via mounted platform skill → return artifact link to Leader
```

## Parent Page (Issue Hub)

Same rule as `multica-artifact-architect`: the requirement page for this Issue is the parent; API contract is published as its child page or under the same project grouping.

## API Contract Spec (self-check before publishing)

Local draft: `docs/backend/<ISSUE-KEY>/api-contract.md`

| Section | Required | Content requirement |
| --- | --- | --- |
| **Document Header** | Yes | Creator, date, version, status, issue, upstream PRD, architecture design link |
| **Overview** | Yes | Scope; corresponds to architecture implementation steps |
| **Endpoint List** | Yes | API-ID · method · path · corresponding BR-/AC- |
| **Endpoint Details** | Yes | Request/response schema, error codes, auth |
| **General Conventions** | Recommended | Pagination, idempotency, time format, etc. |
| **Data Model** | When applicable | Entity/field changes |
| **TDD / Test Mapping** | Yes | API-ID → unit test coverage |
| **Revision Log** | Yes | Version increment |

Breaking change → **version +1**, document in revision log, notify Leader and @FrontendDev.

## Usage (role side)

```text
Produce API contract, write api-contract.md per multica-artifact-backend spec,
self-check then publish via mounted platform skill and return the link.
```

## Swap Platform (no role-prompt change)

Replace this skill's "Platform Collaboration" section with your tool (Swagger / YApi / Postman / internal gateway / Confluence), keeping the "upload + return stable reference" interface unchanged.

- **Apifox**: maintain interface definitions, export/sync, return project/interface-group link.
- **Confluence**: create child page under requirement page, return page link.
- **Git repo**: place under `docs/backend/<issue-id>/api-contract.md`, reviewed with code PR.

## Why it works

Thin orchestration + TDD in the impl skill keeps responsibilities clear; API contract attached to the requirement document tree lets frontend and tester consume it via a stable link regardless of the underlying platform.
