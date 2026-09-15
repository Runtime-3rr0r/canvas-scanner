---
name: course-study-session
description: "Use when running a course study session: prep + gap-check."
---

# Course Study Sessions

Recurring job: user dedicates a session to a course (pre/post-lecture review, homework) and wants (a) confirmation he correctly understood the key ideas, (b) what he got wrong or missed vs. the professor's slides, (c) homework progress. Materials live under `Desktop/Classes/<Course>/`: slides in `Materials/Lectures/` (numbered, e.g. `<COURSE_CODE>-N_Topic`), raw/processed notes in `Notes/`, HW sheets in `Materials/Homework/HW{n}.pdf`, textbook PDF in `Materials/`. Roadmap (`Classes/Roadmap.md`) has deadlines + load tags; course README has grading/AI policy.

## Session flow (in order)

1. **Pre-read BEFORE the session starts** (user is at lecture or away): extract the day's deck, pull the exact HW problems from the textbook, load Roadmap + README. Come in ready, not reading for the first time during review.
2. Review **previous lecture's notes vs. its deck** (gap check below).
3. Review **today's notes vs. today's deck** — same check.
4. Only then start homework: HW spans multiple lectures, and the review primes the problems.

## Gap check (slides = source of truth, notes = capture)

- Three outputs: what notes got **right** (confirm), **wrong** (correct in place), **missed** (list it).
- **Notes often STOP mid-deck**: after content-checking, list the deck's remaining sections the notes never reached — the uncovered stretch is the review target, not a footnote.
- Preserve every fact; never delete the user's `***` clarify markers; don't solve his self-test exercises unless asked; equations in LaTeX. Full processing rules live in the `note-formatting-rules` skill — point future sessions there instead of duplicating.

## Deck + textbook PDF handling

Lecture PDFs are image-heavy: `read_file` often fails with NeedsOcrError while a text layer exists on most pages. Extract with pymupdf to a temp .txt (per-page markers) and read that; only OCR genuinely weak pages. HW sheets often cite only textbook problem numbers; the local textbook PDF yields exact statements + printed answers via full-text cache + tag grep. Both recipes: `references/lecture-slide-extraction.md`.

## Pitfalls

- **Assignment sheets override assumptions**: HW PDF headers carry per-assignment authority (submission platform, co-instructors) and can contradict the course README/syllabus. Flag the discrepancy to the user before advising where to submit; reconcile the README once confirmed.
- Textbook answers are for verification, not the solve: the prof's rubric (points off for wrong answer, no work shown, wrong/missing units) makes the work the grade. Never hand over textbook answers as a solution.
- Check answers carry units (engineering notation applies — `10 µA` not `10`). Unit slips are the cheapest points to lose on homework.
- When the user flags a stale prerequisite ("years since I took calc"), embed a two-minute refresher at the point of use in a HW problem (e.g. area-under-curve, polynomial integration for Ch 1-2 circuits) instead of a standalone lesson.
