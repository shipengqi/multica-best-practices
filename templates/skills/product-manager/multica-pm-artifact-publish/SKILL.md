---
name: multica-pm-artifact-publish
description: Land product requirement / PRD artifacts to the requirement knowledge platform. Used by @ProductManager to publish PRD and return a link for downstream design / dev / test consumption. Swappable platform.
---

# PM Artifact Publish (Orchestration)

## Purpose

**PRD-dedicated orchestration** — call platform skills to **create and update** knowledge-base pages and issue-tracker stories, return stable links. Does not re-implement REST scripts.

> Content structure is governed by `multica-pm-requirement-spec`; this skill only governs "where to publish and how to update".

## Platform Collaboration

| Platform skill | Used for |
| --- | --- |
| wiki platform skill (optional) | Create/update PRD page; return page link |
| issue tracker platform skill (optional) | Create/update Story with PRD link in description |

If no platform skill is mounted: provide the draft PRD directly to Leader (any format), who posts it to the team channel.

## @ProductManager Standard Flow

```text
1. multica-pm-requirement-spec  — structured PRD + revision log
2. multica-pm-artifact-publish  — this skill: knowledge platform + issue tracker + optional notification
```

## Workflow A: First Submission (Create)

1. **Knowledge platform** — create page under the PRD parent page:
   - Via a wiki platform skill if mounted (see platform skill for CLI details)
   - Otherwise: share the Markdown/HTML draft with Leader directly

2. **Issue tracker story** — description includes the knowledge-platform link:
   - Via an issue tracker platform skill if mounted (see platform skill for CLI details)

3. Optional notification (team channel / DingTalk / etc.) via the relevant platform skill.

4. **Return to Leader**: knowledge-platform URL, issue key, creation time, revision version.

## Workflow B: Post-Review Re-submission (Update)

> **Prohibited**: creating a duplicate issue for the same requirement; revisions after review follow the update path.

1. **Knowledge platform** — **upsert/update** the existing page (keep page ID; write revision log into body).
2. **Issue tracker** — update the existing story's description (include "Revision vN" and knowledge-platform link); **do not** create a second story to replace the revision.
3. Return the updated link + revision version for **ProductReviewer re-review**.

## Workflow C: Status Transition

Update issue tracker status to reflect the current review stage (e.g., "In Review", "Approved") via the issue-tracker platform skill.

## Workflow D: Scheduling

Add sprint / milestone to the issue tracker story once scope is confirmed; via the issue-tracker platform skill.

## Workflow E: Knowledge-Platform Unavailable (Fallback)

If the knowledge-platform skill is not mounted or returns an error: write the full PRD text into the issue tracker story description (include all G-/FR-/BR-/AC- ids). Mark the PRD as "pending knowledge-platform publish" in the revision log.

## Configuration

- `config.yaml` in this directory: team PRD defaults and notification mappings (backward compatible).

## Usage (role side)

```text
First use multica-pm-requirement-spec to structure the PRD,
then use multica-pm-artifact-publish to land it and return the link;
after review FAIL, revise PRD, then use publish Workflow B to update (do not re-create the story).
```

## Swap Platform (no role-prompt change)

Replace this skill's "Platform Collaboration" section with your tool (Yuque / Feishu / Notion / internal Wiki), keeping the "upload + return stable link" interface unchanged.

## Why it works

Issue tracker and knowledge platform share platform skills; **create vs update** are separate, avoiding duplicate stories during review iterations; content and platform are decoupled so switching platforms requires no changes to the role prompt or requirement spec skill.
