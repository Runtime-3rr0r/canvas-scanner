# Changelog

All notable changes to the canvas-scanner suite. Format: [Keep a Changelog](https://keepachangelog.com/).

## [0.5.0] - 2026-09-16
### Added
- **One-command setup**: `scripts/setup.sh` (macOS/Linux/Windows Git Bash) and a
  double-clickable `setup.bat` for Windows. The script installs Hermes if needed,
  collects the OpenRouter key into `~/.hermes/.env`, points Hermes at OpenRouter
  with the free Nemotron 550B model, copies the skills and templates, seeds a
  starter `school-config.md`, and runs `hermes doctor`. Idempotent and
  non-interactive friendly (`OPENROUTER_API_KEY=sk-or-... bash scripts/setup.sh`,
  `--dry-run`, `--no-install`, `--no-doctor`, `--with-gateway`).
- **`AI-SETUP-GUIDE.md`**: machine-readable setup instructions at the repo root
  so anyone can drop the repo zip into an online AI chatbot and be walked
  through setup step by step (installs, key, model, config, verification,
  troubleshooting).
- README rewritten around the 2-minute script path; requirements now list only a
  computer + free OpenRouter account (Hermes provisions Python/Git/Node itself).
- The parent repo URL is now shipped verifiably: README, `AI-SETUP-GUIDE.md`,
  and the `suite-update` skill all carry https://github.com/Runtime-3rr0r/canvas-scanner
    links that work out of the box for zip and clone installs.

### Changed
- `scripts/sanitize.py` and the CI PII gate now treat the real parent-repo URL
  as intentional public routing info (it was already the repo's own address):
  the sanitizer no longer rewrites it to a `<GITHUB_USER>` placeholder, and CI
  whitelists it the same way the sanitizer's verify stage already did.

## [0.4.2] - 2026-09-15
### Security
- Guard files no longer expose the identifiers they protect: `scripts/sanitize.py` (REPL + LEAKS)
  and the CI PII gate ship their pattern lists **base64-encoded — decoded at runtime only**.
- Repository history reset to a fresh clean import; all prior objects retired from the public
  repo (old refs and objects are no longer reachable).

## [0.4.1] - 2026-09-14
### Fixed
- Third-pass audit: `categorizer` gains the config pointer + a cross-platform platform tag;
  school-identity strings (school name + course-code patterns) scrubbed repo-wide and added to
  `scripts/sanitize.py` + the CI PII gate so they can't return; `school-config.example.md`
  header deduped; archived calendar section in `note-formatting-rules` now marked;
  `school-advisor` router gains a dropped-files/lost-pile case; README one-liners refreshed.

## [0.4.0] - 2026-09-14
### Added
- **School Inbox system** (live-tested locally 9/14, now templated): `categorizer` skill gains
  school-inbox mode with **first-run auto-provisioning** — asks the user where Inbox/Lost live
  (defaults ~/Desktop/Inbox, ~/Desktop/Lost), creates them, seeds the Inbox with a learning
  soul (`templates/school-inbox-soul.md`), records `school_inbox`/`lost_folder` in config.
- Soul pattern: append-only Learned rules from every sort and every user rename; README-first
  folder maps; recursive scans; confidence gate → Lost; Lost pile as the teaching feedback loop.

## [0.3.1] - 2026-09-14
### Added
- `exam-prep` skill: Mastery-Log + Question-Bank + Roadmap → load-balanced 3/7/10-day
  exam sprint, post-exam feedback loop.
- `homework-checklist` skill: pre-submission rubric diagnosis (per-problem buckets,
  pattern aggregate, auditable checklist file, repeated-pattern drills).
- `course-knowledge-base`: Submission Norms section (format/naming/timezone/late/quirk
  per course + auto-reminder before submission windows).

## [0.3.0] - 2026-09-14
### Added
- **Config-first wiring** (audit pass 2): `scripts/read_school_config.py` loader; skills resolve `<PLACEHOLDER>` tokens from `~/.hermes/school-config.md` at use time; pointer added to each direct-entry skill; README §5 rewritten config-centric (copy the example once, never edit SKILL.md).

### Changed
- `canvas-course-sync` is now a BLANK template: the school worked-example course list removed; the example lives as comments in `school-config.example.md`.
- CI cleaned: removed the dead cross-reference loops; keeps frontmatter + PII gate only.
- Calendar decision (Roadmap IS the calendar) recorded explicitly in `docs/SCHOOL-WORKFLOW.md`.

## [0.2.1] - 2026-09-14
### Added
- Cross-course prerequisite linking in `course-knowledge-base`: prereq links logged once, weak/stale source concepts surface as refresh-notes in dependent courses, existing drills reused instead of one-off refreshers.

## [0.2.0] - 2026-09-14
### Changed (breaking)
- **`class-notes-processing` → `note-formatting-rules`** (rename): the core now holds
  formatting/onboarding/announcements/calendar-lateral rules only. Cross-references in
  README, study-notes-workflow, course-study-session, and CI updated.
- Email drafting (+ inbox catch-up) extracted to **`email-drafting`** skill.
- Wispr Flow + organization/club context extracted to **`meetings-and-clubs`** skill.

### Added
- **`grade-calculator`** skill + `grade_calc.py` ("what do I need on the final for X").
- Question & error banks with **Anki CSV export** (study-notes-workflow).
- **Weekly digest** template + Sunday-anchor wiring in school-advisor.
- **Pane retry helper** reference (`canvas-course-sync/references/pane-retry.md`) —
  single source for the flakiness workaround previously restated in three skills.

## [0.1.3] - 2026-09-14
### Added
- `school-advisor` router skill: front door (answer from COURSE-BRAIN -> trigger sync ->
  notes/study -> homework PDFs -> platform reminders).
- `study-notes-workflow`: Gemini (AI-chat) export comparison check (notes vs slides vs chat;
  flags verbatim-copy-without-understanding) and per-course Mastery-Log.md persistence
  with decay detection (stale ✅ topics resurface as review candidates).

### Changed
- Calendar **lateralized to the Roadmap** (decision 9/14): no .ics generation and no Outlook
  import, period. The Roadmap IS the calendar (assignments + study blocks + life items,
  load-tagged). Supersedes the 0.1.2 study-session-.ics plan.

## [0.1.2] - 2026-09-14
### Added
- `course-knowledge-base` skill: per-course COURSE-BRAIN.md index (syllabus snapshot,
  key dates, lecture index, assignment patterns, syllabus change log). Refreshed by the
  weekly sweep and after every study-notes run.
- Calendar decision recorded: .ics for STUDY SESSIONS only (assignments stay Roadmap-only).

## [0.1.1] - 2026-09-14
### Changed
- **Blank-slate template**: scrubbed all personal identifiers (student ID, school domain,
  course IDs, instructor/club names, local paths) behind `<PLACEHOLDER>` tokens.
  The public repo is now a generic template for other users.
- Added `scripts/sanitize.py` as a permanent guardrail (run before any publish).
- Personal narrative sections genericized (organization/club context, calendar policy).
- Superseded calendar section marked [ARCHIVED] to resolve the policy contradiction.

### Added
- `LICENSE` (MIT), `.gitignore`, `CHANGELOG.md`, `school-config.example.md`.
- GitHub Actions CI: frontmatter validation + cross-skill reference check + PII gate.

## [0.1.0] - 2026-09-14
### Added
- Initial suite: canvas-course-sync (+ kaltura pipeline), photos-to-pdf,
  study-notes-workflow, class-notes-processing, course-study-session, suite-update,
  roadmap, categorizer, verification-before-completion, writing-for-agents.
- README (fresh Windows/macOS setup, zero-dependency), docs/ (philosophies + workflow),
  VERSION.