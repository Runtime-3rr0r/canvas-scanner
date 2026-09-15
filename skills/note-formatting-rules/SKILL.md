---
name: note-formatting-rules
description: "Use when cleaning up class notes: clarify markers."
---
> **Config**: resolve `<PLACEHOLDER>` tokens from `~/.hermes/school-config.md` (see `canvas-course-sync` → School config). Never edit SKILL.md with real values.


# Note Formatting Rules

Recurring job: user takes raw class notes (usually from lecture slides) into `C:/Users/<USER_NAME>/Desktop/Classes/Notes/` and wants them cleaned up: confusions clarified, equations reformatted, structure improved.

## Folder architecture (per-course folders, top level)

- `<Course>/` — one self-contained folder per class at the top level:
  - `Materials/` — syllabus (keep prof's original filename), `Lectures/` (keep prof's filenames; `<COURSE_CODE>-4a_` / `2_Vector_Force` prefixes encode lecture order), `Homework/` as `HW{n}.pdf`, `Homework Solutions/`
  - `Notes/` — user's processed notes, one `<Course Code> - <Course Name>.md` per course (EXCEPTION example: per-chapter files `<COURSE_CODE> - <Course Name> Ch. N.md` + a study-guide companion with `<details>` answers — keep that layout where the user prefers it)
- `<Course>/README.md` — course quick-reference (grading, dates, instructor) from the syllabus; root `README.md` holds the shared conventions.

## Slide-vs-notes gap check (Statics workflow)

Statics slide decks live in `Statics/Materials/Lectures/` as numbered PDFs; the user's real class notes go in `Statics/Notes/`. When asked, compare a lecture's slides against the user's notes for that session and report anything missed or fuzzy, then suggest study/note improvements. Slides = source of truth; notes = user's capture of it.

## Processing rules (hard constraints)

1. **Triple-asterisk markers**: `***item to clarify***` = user question → clarify/expand it in place (e.g. a `> **Clarification**` block). Never delete markers silently.
2. **Math → LaTeX**: `$$i = \frac{dq}{dt}$$`, `$\int_{-\infty}^{t} i\,dt$`, `$8t^2 - 4t\ \text{A}$`. Use symbol tables (meaning + unit) at first appearance.
3. **Never lose or change an idea.** Preserve every fact, value, unit, convention. OK to: fix typos, dedupe repeated lines, reorganize headings, paraphrase definitions. NOT OK: drop details, reword meaning-carriers, add new technical claims beyond clarification.
4. **Don't solve the user's exercises** unless explicitly asked — they're self-tests.
5. **Structure**: `# Course` → `## <date>` → `### Topic` → `#### Sub-topic`.

## Video transcription (for analysis-ready transcripts)

When the user drops a video in Materials (e.g. lecture/instructions MP4) and wants a transcript for querying:

1. Check `ffmpeg -version` (ffmpeg lives at `/c/Program Files/yt-dlp/ffmpeg` on this machine) and `python -c "import faster_whisper"`.
2. Extract mono 16 kHz audio: `ffmpeg -y -i <video> -ar 16000 -ac 1 <temp>/audio.wav`.
3. Transcribe with faster-whisper, `WhisperModel("small.en", device="cpu", compute_type="int8")` (fall back to `base.en`), `vad_filter=True`, timestamps `[MM:SS]` per segment.
4. Save as `<VideoName>-Transcript.md` next to the source video; header notes source + auto-generated. Keep the script in temp; the recipe lives here.

- Video transcription (for analysis-ready transcripts)

When the user drops a video in Materials (e.g. lecture/instructions MP4) and wants a transcript for querying:

1. Check `ffmpeg -version` (ffmpeg lives at `/c/Program Files/yt-dlp/ffmpeg` on this machine) and `python -c "import faster_whisper"`.
2. Extract mono 16 kHz audio: `ffmpeg -y -i <video> -ar 16000 -ac 1 <temp>/audio.wav`.
3. Transcribe with faster-whisper, `WhisperModel("small.en", device="cpu", compute_type="int8")` (fall back to `base.en`), `vad_filter=True`, timestamps `[MM:SS]` per segment.
4. Save as `<VideoName>-Transcript.md` next to the source video; header notes source + auto-generated. Keep the script in temp; the recipe lives here.

## Course onboarding (new class added to the folder)

When the user says they're adding a new class:

1. Look for the course material docs they've already downloaded (often in `~/Downloads` — slide decks, syllabus PDFs, intro PPTX). Read those to extract: course code/name, instructor, grading weights, deadlines, platform links, office hours, policies.
2. Create `<Course>/` with `Materials/{Lectures, Homework, Homework Solutions}`, `Notes/`, and a `<Course>/README.md` quick-reference (instructor, grading table, key dates, links, office hours, policies). Mirror the style of the existing `Statics/README.md`.
3. Textbooks: keep in the course's `Materials/` root under the course, not in a `Textbook/` subfolder. If the user downloaded a textbook PDF from `~/Downloads`, move+rename it as "<Author> - <Title> (<ed> ed).pdf" (verify contents first — e.g. render page 1 to PNG and vision-check the cover).
4. Course notes: create `Notes/<Course Code> - <Course Name>.md` with the scaffold (table of contents + first lecture skeleton) when they ask.
5. **Labs**: a lab attached to a course is a separate Canvas card → give it its own `<Course>/Lab/` subtree (own README + `Materials/` + `Notes/`), linked from the course README. Labs often differ from the main course (e.g. CHE115L submits on Blackboard, directed-inquiry, pre-lab quizzes).
6. **Lab card pattern (e.g. `<COURSE_CODE>L`)**: some labs appear as full new course cards, NOT subfolders — create `<Course> Lab/` as a top-level folder (e.g. `Circuit Theory Lab/`), with its own README documenting: instructor (often first-name only, e.g. "<LAB_INSTRUCTOR>"), meeting time/room, full per-lab assignment table (prelab credit + report credit, note same-Wed double deadlines), grading side items (attendance, proficiency exam), and materials-from-Modules links. Add it to the Announcements archive + memory course-ID list.
7. Ask the user to paste Canvas + platform course URLs once they have them — put in the README's Links section.
8. Update memory with the new course (name, instructor).

## Announcements archive (standing behavior)

Keep `Classes/Announcements/` current — it's the local store of every Canvas announcement so planning/answers don't require re-pulling Canvas. Convention (see `Announcements/README.md`): one md per course, `## YYYY-MM-DD — Title` newest-first, full body text, posted date. If a course's announcements page is disabled (Circuits <COURSE_ID_CIRCUITS>, Statics <COURSE_ID_STATICS> — verified), record that so we don't re-check.

Pull when: dashboard shows new unread counts, user asks, or during the weekly Sunday review. URLs: `https://<SCHOOL_DOMAIN>/courses/{id}/announcements`.

## Canvas / assignment-sync (standing behavior)

Follow the `canvas-course-sync` skill — pane-driven sweep of modules/assignments/announcements/files per course, dedupe vs local `Materials/`, update Roadmap + course READMEs.

- User does NOT share Canvas or email credentials (by choice). Canvas API tokens are DISABLED at this school — no API integration possible; use the logged-in preview pane.
- **Prompt the user weekly** (or when a course says "new assignments posted") to run the Canvas check; then update course README deadline tables + `Roadmap.md`.
- AI-policy varies BY COURSE: some courses allow AI with acknowledgement; others forbid it on journals + written responses. Never ghostwrite graded written work — help with study, structuring, and understanding instead.

Study flow: `study-notes-workflow` skill = format → gap-fill → understanding check → clarify/correct → progress report.

## Calendar — LATERALIZED to the Roadmap (9/14: no .ics, no Outlook)

- **The Roadmap IS the calendar**: assignments, study blocks, and life items (hangouts, club events, "take the break" windows) are planned there with 🟢/🟠/🔴 load tags; daily/weekly briefings read from it. No `.ics` generation, no Outlook import (decision 9/14 — replaces BOTH the old .ics workflow and the study-session-.ics idea). The `Calendar/` folder only holds already-imported class blocks for reference.
- User prefers STRESS-MINIMIZED scheduling: balance load per day (🟢 light/🟠 med/🔴 heavy) in the roadmap's "Balanced calendar" and pre-shift pileups (e.g. HW1B off Wed 9/16 to Tue 9/15) — don't just list deadlines.

## Calendar / briefings (post-9/10 pivot) — [ARCHIVED] superseded by 'Calendar — LATERALIZED to the Roadmap' above

User does NOT want assignments added to Outlook via .ics anymore. Keep assignments local-only: Roadmap.md + course READMEs are the source of truth. When the user asks 'what's tomorrow / what's my week / what should I expect', give a balanced day-by-day briefing from the Roadmap (load-tags 🟢/🟠/🔴, effort stars, pre-shifted pileups). Don't generate assignment .ics files; the Calendar/ folder only holds class blocks already imported.

## Session scoping (user preference)

When the user starts going deep on one topic/class/club (lots of specific questions about Circuits, the AI Club, a specific homework problem, etc.), suggest continuing that topic in its own session (or a fresh one) instead of blending it into the general school session. Keeps sessions clean and focused.

## Pitfalls

- The preview-pane driver (drive_preview) intermittently drops calls with 'arguments is not valid JSON' or 'pointer input never reached the page' — navigation often still happens. Retry with fresh refs from elements(); the transport glitch is transient, not the page. User may close the preview pane — reopening it is allowed (re-open with desktop_preview open).
- When navigation "succeeds" but the click errors, the page DID navigate — read the new URL before retrying the click.
- Scratch lines from other projects can appear in files (e.g. root README once held `<SREC> scan all return val` — project junk, not a rule). Ignore obviously foreign lines.
- Filenames in Materials/ may contain typos (e.g. "Tevenin Eq Dependant"). Leave original filenames alone.
- User is an engineering student: Canvas for HW submission (Friday 11:59 PM), MATLAB + Multisim, AI permitted on HW with documentation, prohibited on quizzes/exams.
- Empty folders (like `Homework Solutions/`) may exist waiting for content — document them, don't delete.
