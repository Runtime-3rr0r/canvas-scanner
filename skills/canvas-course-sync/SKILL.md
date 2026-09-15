---
name: canvas-course-sync
description: "Use when syncing Canvas course materials and announcements."
---

# Canvas Course Sync

Recurring job: sweep every Fall 2026 course on Canvas and pull anything not already local: module items, assignment attachments, announcements, files. Canvas API tokens are DISABLED at this school, so everything goes through the user's logged-in preview pane.

## School config (READ BEFORE EVERY COURSE SESSION)

The suite ships with `<PLACEHOLDER>` tokens; resolve them from **`~/.hermes/school-config.md`** (copy `school-config.example.md` there and fill in YOUR values once). At the start of any course session, read that file; if it is missing, tell the user to create it and stop — never answer with literal placeholders.

Student ID, school domain, course IDs, instructor/org names, platform URLs, and `CLASSES_ROOT` all come from the config. **Never hardcode real values into any SKILL.md** — that is what the config file is for.

To resolve values quickly, run `python scripts/read_school_config.py` (it reads `~/.hermes/school-config.md` and exits 1 with a hint if missing).

## Course IDs

Your school's IDs go in `~/.hermes/school-config.md` (each course URL shows `/courses/<ID>/`). Keep a row per course, e.g.:

```
course_id_course1: <ID>
course_id_course2: <ID>
course_id_course3: <ID>
```

- The agent sweeps Canvas courses with the IDs from config; add a note next to each for quirks (disabled assignments, external homeworks, lab cadence).

## Fresh-machine config (read me before first sweep)

- **Classes root**: this suite assumes a `Classes/` folder (syllabi, materials, Roadmap.md, Announcements/). On a fresh machine, set `CLASSES_ROOT` (default `C:/Users/<USER_NAME>/Desktop/Classes` on the origin machine) and use it everywhere instead of the literal path.
- The one-time login in the pane (Dashboard → courses) is required; Achieve (Macmillan) and Pearson (MasteringEngineering) cannot be pane-logged — the user self-checks those and the agent reminds them weekly.
- Dependencies: python3 with `faster-whisper pymupdf pillow`, plus `yt-dlp` (+ bundled ffmpeg). See the suite README for install per OS.

## Kaltura recorded lectures (download + transcribe)

Lecture videos are Kaltura `playManifest` URLs; the `ks` token in them EXPIRES within hours, so every video needs a FRESH URL from the user (F12 → Network → filter `m3u8` → play → copy the `a.m3u8`). Never store the token — redact it.

Packaged pipeline (download + faster-whisper transcription, one background call):

```bash
cd "<Course>/Materials/Lectures"  # or wherever the video belongs
bash "$SKILL_DIR/scripts/kaltura_pipeline.sh" "<fresh a.m3u8 URL>" "<Output Base Name>"
```

- Outputs `<Name>.mp4` + `<Name> - transcript.txt` + `<Name> - transcript.md` (timestamped `[MM:SS]` lines).
- Name by entryId lookup in `scripts/kaltura_entries.tsv` (entryId → canonical name); **append new rows as you discover them** so future grabs auto-name. entryId is the `entryId/<id>` segment of the URL.
- Run downloads in background with notify (`terminal` background=true + notify=true): 40–90 min lectures exceed the 420s foreground cap. yt-dlp `-c -N 8` resumes safely across the restart.
- Verify each mp4 with `C:/Program Files/yt-dlp/ffprobe.exe` after download; transcription takes ~10–25 min per hour of audio on CPU (int8). A `DONE <n> segments, <x> min` line means the transcript is written.
- After transcription, skim the transcript for Key Points and file them beside it; log flags to `Roadmap.md`.

## Pane driving (the only read path)

1. `tool_call desktop_preview open` `https://<SCHOOL_DOMAIN>` (user stays logged in; reopen if the pane was closed).
2. `tool_call drive_preview elements` first every page change; act by ref, not guessed selectors. Refs die on navigation — fresh `elements` after every navigate.
3. Read page text with `tool_call desktop_preview read` (wait ~2s after navigating).
4. Per course navigate to: `/courses/{id}/modules`, `/courses/{id}/assignments`, `/courses/{id}/announcements`, `/courses/{id}/files` (files page is often hidden; modules usually carry everything).

## Sweep checklist (per course, in this order)

1. **Announcements** → compare against `Classes/Announcements/<Course>.md` (one md per course, `## YYYY-MM-DD — Title` newest-first, full body). Append anything missing. If disabled (Circuits, Statics — verified), note and skip, don't re-check every time.
2. **Modules** → enumerate items. Files: download anything missing from local `Materials/`; external tools/videos: record existence + link in the course README (don't block the sweep on video extraction — flag for later).
3. **Assignments** → note new due dates for `Roadmap.md` + course README deadline tables. Download attached assignment sheets to `Materials/Homework/`.
4. **Files** → download anything not already local.

## Dedupe + storage rules

- Local compare = same title OR same content; only pull what we don't have.
- Keep the professor's ORIGINAL filenames (they encode lecture order, e.g. `<COURSE_CODE>-4a_`).
- **Multiple formats of the same lecture: keep PDFs only** (user's standing rule for lectures).
- Layout: `<Course>/Materials/` → `Syllabus.*` (original name), `Lectures/`, `Homework/` (`HW{n}.pdf`), `Homework Solutions/`; textbooks at `Materials/` root as `<Author> - <Title> (<ed> ed).pdf`.
- **Student work + AI guides**: `<Course>/Materials/Homework/HW{n}/` holds the user's own work (scanned JPGs/PDF) plus any AI-chat export (e.g. `Circuits HW1 AI Guide.md` — Gemini) as a reference; file them there so every attempt/verification is recoverable next to the problem sheet.
- Downloads land in the user's Downloads folder via the pane; move them into the right course folder as part of the sweep. Never auto-process `~/Downloads` for categorization, but class-material moves out of Downloads are expected.

## Other grading platforms (user self-checks — assistant REMINDS)

The user checks both sites in their own browser (the pane can't hold those logins — confirmed 9/12). The assistant's job is the weekly reminder (Sunday review + before due windows) and logging what the user reports/screenshots. Read-only; never submit or change anything.

- **Achieve (Macmillan) — homework platform.** Course URL: `https://<ACHIEVE_COURSE_URL>/mycourse` (from config). The week view lists each HW with due dates + point values, review assignments, and adaptive quizzes.
  - Pane login does NOT work for Achieve (confirmed 9/12) — the user checks the week view in their own browser and reports/screenshots; log to `Chemistry/README.md` + `Roadmap.md`.
  - Capture: weekly HW names/due dates/point values + completion status → `Chemistry/README.md` + `Roadmap.md` (the Achieve assignment list mirrors the screenshot the user takes).
- **Pearson MasteringEngineering — homework platform.** Course menu URL: `https://<PEARSON_COURSE_URL>` (from config). Also reachable via Canvas → "MasteringEngineering" external-tool link (SSO via the pane's Canvas session; may need one user login the first time).
  - Pane login does NOT work for Pearson either — the user checks their homework list in their own browser and reports/screenshots; log due dates + scores to the Statics README + Roadmap. Statics Canvas assignments are disabled, so Pearson is the ONLY source of Statics due dates, and the user-check is mandatory, not optional.
- The user will keep taking screenshots of the Achieve week view — treat those as a first-class scan artifact (vision-read them like the 9/11 batch).

## After the sweep

- Update `Classes/Roadmap.md` (deadlines, stress-balanced by-day plan — user wants load-tagged 🟢/🟠/🔴 scheduling, not raw deadline lists) and the course README deadline table.
- Report what was new vs already-local per course, and any videos/external tools that need follow-up.
- Ask the user to run this weekly or when Canvas shows unread/new-content counts.

## Pitfalls

- **Pane flakiness**: use the retry ladder in `references/pane-retry.md` (elements refresh → wait → URL check → tab handling → hand to human for hover-⤓ downloads / third-party logins).
- Kaltura `ks` tokens die within hours — a URL that 404'd means it expired; ask the user for a fresh one. A URL from yesterday NEVER works.
- Automating the URL grab (browser_exec local=true) requires Chrome fully quit first — never kill the user's tabs; ask first.
- `drive_preview` intermittently fails with 'arguments is not valid JSON' or 'pointer input never reached the page' — navigation usually still happened; re-run `elements()` for fresh refs and re-read the URL before retrying.
- The user may close the preview pane mid-sweep; reopen it. If they close it in the middle of a critical flow, say so.
- AI policy varies by course (one course may allow AI with acknowledgement, another forbids it on graded work). Never ghostwrite graded written work.
