---
name: study-notes-workflow
description: "Use when processing and studying class notes for a course."
---

# Study Notes Workflow

Recurring job: turn the user's raw class notes into clean, complete, verified study notes, then analyze his understanding and drive improvement. Runs per course, per lecture-day batch, and is the standard flow before exams and homework sessions. Hard formatting rules live in `note-formatting-rules` — follow them, do not duplicate them here.

## Pipeline (run in this order, all in one pass)

1. **FORMAT** — make notes correct, consistent, and clean without losing anything:
   - Structure: `# Course` → `## YYYY-MM-DD` → `### Topic` → `#### Sub-topic`.
   - Equations → LaTeX (`$...$` / `$$...$$`); symbol tables (meaning + unit) at first appearance.
   - Fix typos, dedupe repeats, reorganize headings, paraphrase to remove transcription noise.
   - NEVER lose or change an idea. Preserve every fact, value, unit, convention.
2. **GAP-FILL** — slides (`Materials/Lectures/`, numbered decks) are the source of truth; the user's notes are his capture:
   - Diff the day's deck against the day's notes.
   - Add anything missed as `> **Added from slides**` blocks so additions are auditable.
   - If notes stopped mid-deck, list the uncovered sections explicitly — that's the review target.
   - (Deck PDFs are image-heavy: use the pymupdf recipe in `course-study-session/references/lecture-slide-extraction.md`.)
3. **UNDERSTANDING CHECK** — read the notes as a grader, not a copy editor:
   - Classify each topic: ✅ solid (correct + connected), 🟡 partial (right idea, shaky details), 🔴 needs work (wrong, missing, or confused).
   - Note root causes: missing prerequisite, symbol confusion, sign/unit slip, unreviewed content.
4. **CLARIFY & CORRECT** — resolve everything flagged:
   - Answer every `***item***` marker / explicit question IN PLACE as `> **Clarification**` blocks.
   - Fix wrong info in place with a visible correction marker. Never delete the user's original text silently.
   - Don't solve the user's self-test exercises unless explicitly asked.
5. **PROGRESS REPORT** — write `<Course>/Notes/Study Rep - <YYYY-MM-DD>.md`:
   - What he got right (confirm — confidence matters), ranked weak areas, per-topic mastery table.
   - Concrete next actions: 2-minute refreshers at point of use (e.g. missing calc), drill topics, what to re-read.
   - Tie to `Roadmap.md` study blocks. Keep updates truthful: progress = verified gains, not completion vibes.

## Action items → Roadmap (advisory duty)

Anything noticed while processing notes that the user should study, fix, or do goes into `Classes/Roadmap.md` — it is the SINGLE "what should I be doing" drop point and the source for daily briefings. Add:
- Corrections the user should re-check (wrong/uncertain values in notes, e.g. a mis-copied prefix table or arithmetic slip) → "Study flags" section.
- Pending grabs (files to download, videos to transcribe) → a to-do list section.
- New/updated due dates found during sweeps → the by-day balanced calendar + week tables.

Act as the user's school advisor: when asked "what should I do today/this week", answer from Roadmap.md (load-tagged, stress-balanced), and proactively surface study flags when they're relevant to today's work.

## Scanned / handwritten notes (photo or iPad)

- User may drop photos (jpg/png) of physical notes, or iPad-exported notes, usually from `~/Downloads/Notes`.
- Save the ORIGINAL file into the course's `Notes/` folder (e.g. `Statics/Notes/Statics Notes 2026-09-11.jpg`) — the image stays the source of truth.
- Transcribe with vision_analyze into the course's markdown notes, FAITHFULLY: keep every fact, number, and equation; mark anything unreadable as `[unreadable]` rather than guessing; convert math to LaTeX per house rules; append as a `## YYYY-MM-DD` section into the course's notes .md.
- Do not silently "fix" handwriting errors in technical content — flag them in the section instead (processing rules apply).
- Then run the normal pipeline on the transcription.
- **Confirm WHICH lecture was actually given before gap-fill**: slide numbering ≠ calendar date. First week is usually syllabus-day. Use the user's notes (or ask) to identify the real deck — e.g. Statics 9/11 covered `1_Unit` (Force & Units), NOT `2_Vector_Force`, despite folder order suggesting "next".

## Standalone requests

- "Format my notes" → stages 1 (+ 4 if markers exist).
- "Compare with slides / did I miss anything" → stage 2.
- "Study with me / prep for this" → `course-study-session` skill for the session flow, then this pipeline for notes.

## Session scoping

After a run, suggest continuing in a per-class session if the user goes deep on one course (see session-scoping in `note-formatting-rules`). This is the remembered standard workflow — offer it by name when he says "study my notes", "clean up notes", or "check my understanding".

## Gemini (AI-chat) export ingestion — comparison check

When the user drops an AI-chat export alongside homework work and notes (existing convention: `<Course>/Materials/Homework/HW{n}/... AI Guide.md`), run the three-way comparison as part of the pipeline:

1. **Notes vs slides** — the existing gap-fill (stage 2).
2. **Homework work vs the chat conversation** — does the written work match what the chat suggested, problem by problem?
3. **Chat vs what landed in the notes** — was the reasoning absorbed, or just the terminal result copied?

**The signal to hunt**: problems where written work mirrors the chat's method almost verbatim while the notes show no independent grasp of WHY that method applies. That is the "looks done but isn't understood" pattern — flag it in the Progress Report and as a Roadmap study flag.

Never rewrite the export; it stays a source file beside the work.

## Mastery tracking (persistence, not snapshots)

- Every understanding check appends per-topic status to `<Course>/Notes/Mastery-Log.md` (append-only table: `topic | status ✅/🟡/🔴 | date | note`).
- Decay detection: topics marked ✅ that have gone untouched for ~3 weeks resurface as 🟡 **review candidates** in the next Progress Report — retention, not just new material.
- Mastery-Log is the trend layer under the dated Study Rep snapshots; keep it one append-only table.

## Question & error bank (+ Anki export)

- **Question bank**: every answered clarification / `***` marker lands in `<Course>/Notes/Question-Bank.md` (per-course self-quiz; test mode = close the file, answer, then check).
- **Error bank**: log each mistake by type (sign/unit/symbol/prerequisite) into `<Course>/Notes/Error-Bank.md`; watch for type repeats across runs (the understanding check reports them).
- **Anki export**: any bank exports as Anki-ready CSV (one row = `front,back`; first row is the header/cards-separator line), saved as `<Course>/Notes/export-anki-<date>.csv` and imported via Anki desktop File → Import. Drills weak topics outside Hermes.
- Exam synthesis (planned): map Mastery-Log weak topics onto the exam-review decks.
