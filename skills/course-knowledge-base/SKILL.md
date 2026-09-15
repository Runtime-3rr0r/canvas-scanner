---
name: course-knowledge-base
description: "Use when maintaining the per-course COURSE-BRAIN index."
---

# Course Knowledge Base (COURSE-BRAIN)

Maintain a **single synthesized knowledge doc per course** — `<Course>/COURSE-BRAIN.md` — an index over the authoritative source files (syllabus, README, notes, materials, announcements) so "ask almost anything about a class" can be answered from one file instead of re-scanning folders.

**The index is a pointer, not a store** (writing-for-agents): COURSE-BRAIN summarizes + links; it never replaces the source files.

## Structure of COURSE-BRAIN.md

```markdown
# <Course> — COURSE-BRAIN
_Last refreshed: <date> · sources: README, syllabus, Notes/, Announcements/_  ([^1]: ...)

## Snapshot
- Instructor, meeting time/place, grading weights (table), current letter estimate
- Course-specific AI policy + late/attendance policy (one line each)

## Key dates (next 30 days)
| Date | Item | Weight | Where |

## Lectures covered (running index)
| Date | Topic | Notes section | Transcript? |
- append one row per lecture; link `Notes/<file>#<section>` and any transcript/Key Points

## Assignment patterns
- types, cadence, submission channel (e.g. "weekly problem sets, Canvas upload, Fri 11:59 PM")
- the professor's grading quirks (sig figs, show work, no make-ups...)

## Open flags
- study flags with open questions, unresolved to-dos (mirror Roadmap, kept current)
- links out: exam prep maps, formula-sheet provided-vs-memorize notes

## Syllabus change log
- every detected syllabus/policy diff + date (see pitfall)
```

## When to refresh

1. **During the weekly Canvas sweep** (after canvas-course-sync finishes) — update key dates, grades, new announcements, policies.
2. **After any study-notes-workflow run** that touches the course — new lecture row, flags, mastery changes.
3. **When the user asks a course question** — read COURSE-BRAIN first; open linked sources only when the brain doesn't answer.
4. **On syllabus/policy change** — diff the current Canvas syllabus vs the stored one; append to the change log instead of silently overwriting.

## Submission norms (per course, inside COURSE-BRAIN)

- Record per course: submission format (PDF/docx/online form), naming convention, size limits, deadline timezone, late policy, and quirks (e.g. "no email submissions, Canvas only").
- Auto-remind before each submission window ("HW due Fri 11:59 PM — PDF, `HW3_<LastName>.pdf`, Canvas upload") and catch format errors before upload — see `homework-checklist`.
- This block is part of the COURSE-BRAIN structure above (add under "Snapshot" or as its own section).

## Pitfalls

- COURSE-BRAIN is an index: bloating it with full notes defeats the point (see writing-for-agents two-load principle).
- Refresh AFTER sweeps/note-runs, never before — stale brain is worse than no brain.
- Grading-policy changes must land in the change log, not silently edited into the snapshot.
- Keep one file per course; never a per-week brain.

## Verification

- Every course folder has a COURSE-BRAIN.md whose last-refreshed date is newer than the most recent sweep/note run.
- Every "Lectures covered" row has a resolvable source link.
- Change log reflects every detected syllabus diff.
