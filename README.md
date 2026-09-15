# Canvas Scanner Suite

A fully self-contained Hermes skill suite that turns any Canvas account into a personal school-advisor setup: live course scanning, a load-balanced study roadmap, lecture-video transcription, note processing, and homework-submission PDFs. Runs on a **fresh machine with zero dependencies** after following this README.

**Parent repo (single source of truth):** https://github.com/<GITHUB_USER>/canvas-scanner
> Replace `<GITHUB_USER>` with the repo owner (the parent public repo) or with your fork if you self-host. The `suite-update` skill checks this URL anonymously — a fresh user needs no GitHub account to use it.
Users do **not** need their own GitHub account or repo. Updates are pulled anonymously from this public repo (see "Updating").

---

## What's inside

```
canvas-scanner/
├── README.md                        ← you are here
├── VERSION                          ← version + git sha (used by the updater)
├── templates/
│   └── school-inbox-soul.md      ← seeded into the Inbox on first run
├── docs/
│   ├── DESIGN-PHILOSOPHIES.md       ← the operating philosophy (SREC, verification, memory hygiene)
│   └── SCHOOL-WORKFLOW.md           ← how the pieces wire together end to end
└── skills/                          ← copy these into your Hermes skills dir
    ├── canvas-course-sync/          ← the weekly Canvas sweep (+ kaltura_pipeline.sh)
    ├── photos-to-pdf/               ← homework photos → clean submission PDF
    ├── study-notes-workflow/        ← notes: format → gap-fill → check → clarify → report
    ├── course-knowledge-base/    ← per-course COURSE-BRAIN index (ask-anything doc)
    ├── note-formatting-rules/      ← hard formatting/onboarding rules (split from class-notes-processing)
    ├── course-study-session/        ← guided study session prep
    ├── email-drafting/           ← email style + Outlook compose workflow
    ├── meetings-and-clubs/       ← Wispr Flow meetings + org context
    ├── grade-calculator/         ← 'what do I need on the final' scenarios
    ├── exam-prep/                ← Mastery-Log → exam sprint plan
    ├── homework-checklist/       ← pre-submit rubric diagnosis
    ├── suite-update/                ← auto-check the parent repo for updates (no login)
    ├── roadmap/                     ← goal folders + bug ledger for multi-session projects
    ├── categorizer/                 ← Inbox/Lost drop system (Projects + school modes)
    ├── verification-before-completion/ ← no "done" without fresh evidence
    └── writing-for-agents/          ← how to write/keep skills cheap and reliable
```

**No secrets live in this suite.** No API keys, no tokens, no passwords. Your provider keys belong in `~/.hermes/.env` (Hermes convention) and nothing here reads them.

---

## 1. Requirements (fresh machine)

| Tool | Why | Windows | macOS |
|---|---|---|---|
| Python 3.10+ | faster-whisper, pymupdf, pillow | https://python.org (tick "Add to PATH") | `brew install python@3.12` |
| Git | install/update the suite | https://git-scm.com | `brew install git` |
| Hermes Agent | the agent itself | see step 2 | same |
| yt-dlp (+ bundled ffmpeg) | video downloads | `pip install yt-dlp` | `pip3 install yt-dlp` |
| pip packages | transcription + PDF | `pip install faster-whisper pymupdf pillow` | `pip3 install ...` |

## 2. Install Hermes

```bash
# Windows (git-bash or WSL) and macOS: same single-line installer
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# Configure your provider + get a health check
hermes setup        # first-run wizard: pick provider, model, interface
hermes model        # (re)pick model/provider later
hermes doctor       # verify the install
```

Recommended: run `hermes desktop` (or `hermes gui`) — the suite's Canvas scanner drives the **preview pane** built into the desktop app.

## 3. Install the suite

```bash
# Recommended (enables one-command updates later):
git clone https://github.com/<GITHUB_USER>/canvas-scanner.git
# ...or download the zip: https://github.com/<GITHUB_USER>/canvas-scanner/archive/refs/heads/main.zip

# Copy the skills into your Hermes skills directory
# Windows (default):
cp -r canvas-scanner/skills/* ~/AppData/Local/hermes/skills/
# macOS (and any profile: $HERMES_HOME/skills/):
cp -r canvas-scanner/skills/* ~/.hermes/skills/
```

Everything is Hermes-native (frontmatter + metadata included); no conversion needed. New skills appear in the catalog from your **next** session.

## 3b. Drop-point provisioning (first run)

When you first use the categorizer, it **asks where** you want your school drop-points (defaults: `~/Desktop/Inbox` and `~/Desktop/Lost`), creates them, and seeds the Inbox with its learning "soul" (`templates/school-inbox-soul.md`). Drop files/folders into the Inbox anytime; ambiguous items go to Lost where a glance is enough to describe or rename them back into the system.

## 4. One-time login (required, takes 60 seconds)

The scanner reads Canvas through your logged-in browsing session, so log in once in the desktop app's preview pane: open **https://<your-school>.instructure.com** in the pane and sign in (SSO is fine). The session persists between sessions.

## 5. Config for your school (ONE file, one time)

1. `cp school-config.example.md ~/.hermes/school-config.md`
2. Fill in YOUR values there (student ID, school domain, course IDs, instructor/org names, platform URLs, `CLASSES_ROOT`). ~10 lines.
3. Done — the skills read from that file; you never edit a SKILL.md with personal data.

- Keep the config **out of the repo** (`.gitignore` covers it). If you fork and self-host, the config lives in your **private** fork.
- Platform split note: the agent scans Canvas itself; **Achieve/Pearson-style third-party homework sites can't hold a pane login**, so the user self-checks those weekly and the agent reminds them (built into the habit layer).

## 6. First run

1. Create the `Classes/` folder and a `Roadmap.md` (or ask your Hermes to scaffold it).
2. Tell Hermes: *"run the canvas course sync"* → it sweeps announcements/modules/assignments and logs everything to the Roadmap.
3. Ask for the *"evening briefing"* anytime: *"what's my week?"* — the agent answers from the Roadmap.

---

## Using it (cheat sheet)

| Ask Hermes | What happens |
|---|---|
| "run the canvas sync" | sweep every course: announcements → modules → assignments → log to Roadmap |
| "what should I work on?" / "what's next?" | load-balanced day-by-day plan from the Roadmap |
| "transcribe this lecture" | `kaltura_pipeline.sh`: download + transcribe + Key Points (needs a fresh video URL from the browser) |
| "make a submission PDF from my photos" | `photos_to_pdf.py`: EXIF-fixed, full-res, captioned, staged in Downloads |
| "process my notes" | study-notes-workflow: format → gap-fill vs slides → understanding check → clarify → progress report |
| "check for suite updates" | `suite-update`: anonymously compares the parent repo, pulls if newer |

---

## Updating (no GitHub account needed)

The suite checks the **public** parent repo anonymously (60 req/hr anonymous limit — once a week is plenty):

```bash
# Compare local VERSION with the repo's latest commit:
curl -s https://api.github.com/repos/<GITHUB_USER>/canvas-scanner/commits?per_page=1
```

- If you installed via `git clone`: `git pull` updates everything in place.
- Folder/zip installs: re-download the zip and swap folders.
- The `suite-update` skill automates all of this — just say *"check for updates."*
- Publishing changes **back** is the only step that needs GitHub: `gh auth login`, then fork → PR or request collaborator access.

---

## FAQ

- **Do I need a GitHub account to USE this?** No. Cloning/pulling a public repo needs none.
- **Will scanning touch my grades or submit anything?** No. It is read-only: pane reads + local files. Submissions are always yours.
- **Rate limits?** GitHub API 60 req/hr anonymous (fine weekly). Kaltura video tokens expire in hours — always use a fresh copied URL.
- **My school doesn't use Canvas/Kaltura?** The sweep mechanics still apply to any LTI-style LMS; swap URLs and the same read paths work. The transcript pipeline targets Kaltura (common in higher ed).