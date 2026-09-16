# Canvas Scanner Suite

A self-contained Hermes Agent skill suite that turns any Canvas account into a
personal school assistant: live course scanning, a load-balanced study roadmap,
lecture-video transcription, note processing, and homework-submission PDFs. It
runs entirely on your machine, costs nothing to use (free OpenRouter model), and
needs **no Python, no Git, no GitHub account** to get started.

**New here? Drop this folder (or the downloaded zip) into any AI chatbot and ask
it to follow `AI-SETUP-GUIDE.md`, or just run the script below.**

**Parent repo:** https://github.com/Runtime-3rr0r/canvas-scanner
(If you self-host a fork, swap the URL in the `suite-update` skill.)

---

## Quick start (about 2 minutes)

You need one thing first: a **free OpenRouter API key** from
https://openrouter.ai/keys (login, create key, copy it).

### macOS / Linux

Open Terminal:

```bash
cd <the folder you unzipped this repo into>
bash scripts/setup.sh
```

That is it. The script installs Hermes Agent if needed, asks for your OpenRouter
key, points Hermes at the free Nemotron 550B model, copies in the suite skills,
and runs `hermes doctor` to verify.

### Windows

Unzip the repo and **double-click `setup.bat`**. It installs Hermes (via
PowerShell) if needed, then runs the same setup and asks for your API key.

### Non-interactive (power users, or AI-guided setups)

```bash
OPENROUTER_API_KEY=sk-or-... bash scripts/setup.sh
```

Re-running the script is always safe (idempotent: it skips what already exists).

### Step 2 (both platforms): one-time Canvas login

In the desktop app's preview pane, open `https://<your-school>.instructure.com`
and sign in once (SSO is fine). The scanner reads this session and it persists
between sessions.

---

## Let an AI set it up for you

The repo ships `AI-SETUP-GUIDE.md`, written so any chatbot (ChatGPT, Claude,
Gemini, and so on) can walk this exact setup step by step:

1. Upload this repo folder or zip to the chat.
2. Say: "Help me set this up. Read AI-SETUP-GUIDE.md and tell me what to run."
3. Follow its instructions.

The guide covers both operating systems, the free-model configuration, the
one-time school config, verification, and troubleshooting. This is also the
place to paste `hermes doctor` output if anything goes wrong.

---

## What's inside

```
canvas-scanner/
├── README.md                    ← you are here
├── AI-SETUP-GUIDE.md            ← machine-readable setup instructions for AI chatbots
├── setup.bat                    ← Windows double-click installer
├── VERSION                      ← version + git sha (used by the updater)
├── scripts/
│   ├── setup.sh                 ← macOS/Linux/Windows-GitBash setup automation
│   ├── read_school_config.py    ← config loader
│   └── sanitize.py              ← publish-time PII guardrail (maintainers only)
├── templates/
│   └── school-inbox-soul.md     ← seeded into the Inbox on first run
├── docs/
│   ├── DESIGN-PHILOSOPHIES.md   ← the operating philosophy (SREC, verification, memory hygiene)
│   └── SCHOOL-WORKFLOW.md       ← how the pieces wire together end to end
└── skills/                      ← copied into your Hermes skills dir by setup.sh
    ├── canvas-course-sync/      ← the weekly Canvas sweep (+ kaltura_pipeline.sh)
    ├── photos-to-pdf/           ← homework photos → clean submission PDF
    ├── study-notes-workflow/    ← notes: format → gap-fill → check → clarify → report
    ├── course-knowledge-base/   ← per-course COURSE-BRAIN index (ask-anything doc)
    ├── note-formatting-rules/   ← hard formatting/onboarding rules
    ├── course-study-session/    ← guided study session prep
    ├── email-drafting/          ← email style + Outlook compose workflow
    ├── meetings-and-clubs/      ← meeting notes + org context
    ├── grade-calculator/        ← 'what do I need on the final' scenarios
    ├── exam-prep/               ← Mastery-Log → exam sprint plan
    ├── homework-checklist/      ← pre-submit rubric diagnosis
    ├── suite-update/            ← auto-check the parent repo for updates (no login)
    ├── roadmap/                 ← goal folders + bug ledger for multi-session projects
    ├── categorizer/             ← Inbox/Lost drop system (Projects + school modes)
    ├── verification-before-completion/ ← no "done" without fresh evidence
    └── writing-for-agents/      ← how to write/keep skills cheap and reliable
```

**No secrets live in this suite.** No API keys, no tokens, no passwords. Your
OpenRouter key belongs in `~/.hermes/.env` (`%LOCALAPPDATA%\hermes\.env` on
Windows) and `setup.sh` puts it there for you.

---

## Requirements

Nothing to install by hand. The Hermes installer provisions Python, Git, and
Node automatically on both platforms.

| You need | Why |
|---|---|
| A computer (macOS 12+, Windows 10/11) | runs Hermes natively |
| An OpenRouter account | free at openrouter.ai; the default model is free |
| Your school's Canvas URL | the scanner's login target |

Optional extras (only if you use transcription or PDF generation):

```bash
pip install faster-whisper pymupdf pillow   # transcription + PDF
pip install yt-dlp                          # video downloads (bundles ffmpeg)
```

Requires Python 3.10+ (Hermes's bundled Python works). These extras do not
affect the core school-assistant features.

---

## Manual install (if you would rather not use the script)

```bash
# 1. Install Hermes Agent
# macOS / Linux:
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
# Windows (PowerShell):
iex (irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1)
# open a NEW terminal, then:

# 2. Add your key + pick the free model
hermes config set model.provider openrouter
hermes config set model.default "nvidia/nemotron-3-ultra-550b-a55b:free"
echo 'OPENROUTER_API_KEY=sk-or-...' >> ~/.hermes/.env                     # macOS/Linux
echo 'OPENROUTER_API_KEY=sk-or-...' >> ~/AppData/Local/hermes/.env        # Windows (Git Bash)

# 3. Copy the suite skills (data dir = ~/.hermes on macOS/Linux,
#    %LOCALAPPDATA%\hermes on Windows)
cp -R skills/* ~/.hermes/skills/
cp -R templates ~/.hermes/
```

Everything is Hermes-native (frontmatter + metadata included); no conversion
needed. New skills appear in the catalog from your **next** session.

## Drop-point provisioning (first run)

When you first use the categorizer, it **asks where** you want your school
drop-points (defaults: `~/Desktop/Inbox` and `~/Desktop/Lost`), creates them,
and seeds the Inbox with its learning "soul" (`templates/school-inbox-soul.md`).
Drop files/folders into the Inbox anytime; ambiguous items go to Lost where a
glance is enough to describe or rename them back into the system.

## Config for your school (ONE file, one time)

1. `setup.sh` creates it for you; otherwise copy the example:
   `cp school-config.example.md ~/.hermes/school-config.md`
2. Fill in YOUR values there (student ID, school domain, course IDs,
   instructor/org names, platform URLs, `CLASSES_ROOT`). ~10 lines.
3. Done. The skills read from that file; you never edit a SKILL.md with
   personal data.

- Keep the config out of the repo (`.gitignore` covers it). If you fork and
  self-host, the config lives in your **private** fork.
- Platform split note: the agent scans Canvas itself; Achieve/Pearson-style
  third-party homework sites cannot hold a pane login, so you self-check those
  weekly and the agent reminds you (built into the habit layer).

## First run

1. Create the `Classes/` folder and a `Roadmap.md` (or ask your Hermes to
   scaffold it).
2. Tell Hermes: *"run the canvas course sync"* → it sweeps
   announcements/modules/assignments and logs everything to the Roadmap.
3. Ask for the *"evening briefing"* anytime: *"what's my week?"* — the agent
   answers from the Roadmap.

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

Just say *"check for updates"* inside Hermes and the `suite-update` skill
compares the parent repo against your local version. Details:

- Git-clone installs: `git -C <suite dir> pull --ff-only` at the clone root.
- Zip/folder installs: re-download the zip
  (https://github.com/Runtime-3rr0r/canvas-scanner/archive/refs/heads/main.zip),
  swap the folders, then re-run `bash scripts/setup.sh --no-install`, which
  refreshes skills, templates, and the version file.
- setup.sh installs: your suite version is recorded at
  `$HERMES_HOME/canvas-scanner-version`; the update check compares it against
  the parent's `VERSION` file.
- Publishing changes **back** is the only step that needs GitHub:
  `gh auth login`, then fork → PR or request collaborator access.

---

## FAQ

- **Do I need a GitHub account to USE this?** No. Downloading a zip needs none.
- **Does it cost anything?** The default model
  (`nvidia/nemotron-3-ultra-550b-a55b:free`) is free on OpenRouter. Your API key
  enables it; no billing.
- **Will scanning touch my grades or submit anything?** No. It is read-only:
  pane reads + local files. Submissions are always yours.
- **Rate limits?** GitHub API 60 req/hr anonymous (fine weekly). Kaltura video
  tokens expire in hours — always use a fresh copied URL.
- **My school doesn't use Canvas/Kaltura?** The sweep mechanics still apply to
  any LTI-style LMS; swap URLs and the same read paths work. The transcript
  pipeline targets Kaltura (common in higher ed).