---
name: school-advisor
description: "Use when asked anything about classes or the school week."
---
> **Config**: resolve `<PLACEHOLDER>` tokens from `~/.hermes/school-config.md` (see `canvas-course-sync` → School config). Never edit SKILL.md with real values.


# School Advisor (front door)

Front-door router for the school suite. When the user asks anything class-related ("what's next", "catch me up", course questions, "remind me about..."), route instead of guessing:

1. **Course question** → read that course's `COURSE-BRAIN.md` first (see `course-knowledge-base`). Only open source files (README/Notes/Materials/Announcements) if the brain doesn't answer. Never re-scan folders by default.
2. **"What's my week / today / next"** → answer from `Roadmap.md` (load-tags 🟢/🟠/🔴, balanced by day, pre-shifts). Roadmap IS the calendar — assignments and study blocks live there, no .ics/Outlook (lateralized 9/14).
3. **Stale or unknown data** → trigger `canvas-course-sync` sweep first, refresh COURSE-BRAINs, then answer.
4. **Notes / studying** → `study-notes-workflow` (pipeline incl. Gemini comparison + mastery log) or `course-study-session` for a session.
5. **Homework photos** → `photos-to-pdf` → stage submission PDF in Downloads.
6. **Canvas-only platforms** (Achieve/Pearson) → remind the user to self-check (they can't hold a pane login); log what they report.
7. **Dropped files / lost pile** → the `categorizer` skill (school-inbox mode): file the drop, or report the Lost pile waiting for descriptions.

## Always

- Auto-log changes to Roadmap.md as they happen, no matter how small.
- **Weekly digest (Sunday anchor)**: render the digest from `docs/weekly-digest-template.md` — what changed, next-7-days from the Roadmap, weak spots from Mastery-Log, pending decisions (incl. Achieve/Pearson self-checks). It becomes the Sunday-review agenda; keep it conversational on top of the one file.

## Pitfall

- If asked something the brain can't answer from its index, refresh from sources once, answer, then note the gap to refresh in COURSE-BRAIN refresh rules — never answer from stale memory.
