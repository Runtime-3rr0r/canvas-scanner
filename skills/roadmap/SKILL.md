---
name: roadmap
description: "Create and manage a self-contained multi-session roadmap."
version: 0.1.0
author: <USER_NAME> (<GITHUB_USER>), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [roadmap, planning, goals, bugs, multi-session]
    related_skills: [plan, wayfinder, to-tickets, srec-project-planning]
---

# Roadmap

Create and manage a **self-contained roadmap** for this profile/session space:
every goal is a loadable work-package that carries its own context — the
originating prompt, the goal statement, and a bugs/problem log in its own file
or folder — so any session (or a later one) can open one item and have the full
context to act on it.

Type /roadmap to invoke. You can pass items to append ("/roadmap add X"), or
name what the roadmap is about ("/roadmap for the homelab rebuild").

## When to Use

- <USER_NAME> says "let's make a roadmap", "/roadmap", or "add X to the roadmap"
- Starting a multi-session effort that should be loadable later
- You want a durable, referenceable work-tracker where each goal file carries
  its own bugs + prompt context (unlike a flat bullet list)

**Don't use for:** single-session plans (use the `plan` skill, writes a one-off
plan doc), or the GitHub issue-tracker boards (`github-project-kanban` +
`triage` own those). This roadmap is the durable cross-session list-of-goals.

## Invocation — read the argument and ACT (the #1 rule)

When the user types `/roadmap ...`, the rest of that line is an **argument you use
now, in this turn** — not something to wait for or ask about. The slash command
carries everything. Do exactly this:

- `/roadmap` alone or `/roadmap view` → read the index (`ROADMAP.md`) and **report
  it to the user** (statuses, paths). Confirm you're showing the current state.
- `/roadmap add <anything after "add">` → **create a new goal folder now** from
  that text: make `goals/<NNN>-<slug>/`, write `GOAL.md` (goal + that exact text as
  Originating prompt), `BUGS.md` (None known yet), `STATUS.md` (not-started), and
  **append a row to `ROADMAP.md`**. Reply confirming the goal number + path.
- `/roadmap <NNN>` or "work on X" → load that goal folder's GOAL.md + BUGS.md +
  STATUS.md and resume it.
- `/roadmap <text without an action word>` → treat the whole text as a goal to add,
  same as `/add`.

Never load the skill and do nothing. Loading the skill with an argument **must**
produce a concrete outcome (a created goal, a report, or a loaded goal) and a
confirming reply. If you run it with no argument and no content, create
`ROADMAP.md` if missing and confirm the index is ready, then ask what to add.

## Structure

```
Documents/Projects/Plans/
├── ROADMAP.md                     ← the live index: ordered goals, each with status
└── goals/
    └── <NNN>-<slug>/
            ├── GOAL.md                ← goal statement + originating prompt(s) + refs
            ├── BUGS.md                ← open/problems/blockers for this goal
            ├── STATUS.md              ← state, worked-log, decisions, next-step pointers
            └── (any related assets)
```

Each goal folder is the **single source of truth** for that goal's context. The
index (`ROADMAP.md`) stays a lightweight pointer list — it never duplicates the
goal folder content, only links to it (writing-for-agents: the index is a
pointer, not a store).

### GOAL.md skeleton

```markdown
# <slug> — <one-line goal>

## Goal
<what "done" looks like, from the user's perspective>

## Originating prompt
> <the exact prompt / conversation context that spawned this goal>

## References
- <paths/URLs/skills that give context>

## Status: <not-started | in-progress | done | blocked>
```

## Procedure

### Create / open a roadmap (/roadmap, /roadmap add ...)

1. If no `ROADMAP.md` exists, create it at `Documents/Projects/Plans/ROADMAP.md`
   (create the `goals/` dir alongside).
2. For each goal the user names (or that's already in this session), ensure it
   has a folder under `goals/<NNN>-<slug>/` with GOAL.md, BUGS.md, STATUS.md.
   Capture: the **originating prompt** (their words), the "done" statement,
   constraints, and related references.
3. Update `ROADMAP.md`: add/refresh the index row (title, slug, status, link to
   the goal folder). Keep it an index, not inline content.
4. If an item references the current session's work, quote any bugs/known issues
   you already hit into that goal's `BUGS.md` (don't let them sit unlogged).

### Rolling a goal (/roadmap <NNN> or "work on X")

1. Read the goal's folder: `GOAL.md` (context + prompt), then `BUGS.md` (open
   problems). This loads the session fully — no re-explaining.
2. As you work, append to `STATUS.md` (progress, decisions) and keep `BUGS.md`
   current (open/closed problems).
3. When the goal's done, mark `GOAL.md` status `done` with a one-line summary and
   update the index.

### Bug/problem rule

Every roadmap goal **must** have its bugs/problems logged in its `BUGS.md` (or
a folder), never silently carried in chat memory. A bug found during work = an
edit to that goal's BUGS.md. Cross-references to sessions/URLs allowed.

## Pitfalls

- **Turning ROADMAP.md into a store.** It's an index. The goal folders hold the
  content. An index that grows fat defeats the whole point (writing-for-agents).
- **Losing the originating prompt.** Capture the user's exact words — it
  restores intent in a later session better than a reworded summary.
- **Letting bugs live in memory.** They belong in the goal's BUGS.md, not memory
  (memory is for user/environment facts, not task state).
- **Empty BUGS.md file.** If a goal has no known bugs, write "None known" rather
  than an empty file, so a future load doesn't wonder if it was never touched.
- **Unlinked goals.** Every index row must link to its folder.
- **Status drift.** Update status in GOAL.md + the index when state changes.

## Verification

- `Documents/Projects/Plans/ROADMAP.md` exists; `goals/` alongside it.
- Every row in the index resolves to a real goal folder.
- Every goal folder has GOAL.md (with originating prompt), BUGS.md, STATUS.md.
- BUGS.md captures every known open problem from this session (not in chat
  memory).
- Index stays an index: no bloated inline content, only links + status.

## Related

- `plan` — one-off plan that lives under `.hermes/plans/`, no execution.
- `github-project-kanban` + `wayfinder` — living issue-tracker boards, for goals
  that should run on a repo tracker instead of a file roadmap.