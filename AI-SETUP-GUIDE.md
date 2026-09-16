# AI-SETUP-GUIDE.md
# Read me first when setting up the canvas-scanner suite, by hand or with an AI chatbot.

You are an AI assistant helping a person set up the **canvas-scanner suite**: a
Hermes Agent skill collection that turns a Canvas school account into a personal
school assistant (course sync, study roadmap, note processing, homework PDFs).

This file is written so that either

1. a human reads it and runs the commands, or
2. a user drops this repo (as a zip or folder) into an AI chat and you, the
   chatbot, follow it to tell them exactly what to run.

## What the user needs before starting

- A computer: **macOS** (Terminal app) or **Windows 10/11** (this works natively;
  no WSL needed).
- An internet connection.
- A free OpenRouter account. The model used here,
  `nvidia/nemotron-3-ultra-550b-a55b:free`, currently costs **$0** to use.
  Get an API key at https://openrouter.ai/keys (login, create key, copy it).
- Their school's Canvas URL, e.g. `https://yourschool.instructure.com`.

No Python, no Git, and no GitHub account are required: the Hermes installer
provisions Python and Git automatically, and everything in this repo runs
locally.

## Your job as the setup assistant

1. Ask which OS they are on (macOS or Windows).
2. Collect these values (do NOT invent them; if unknown, ask before running):
   - the OpenRouter API key (`sk-or-v1-...`)
3. Hand them the exact commands below for their OS. Prefer `scripts/setup.sh`
   (or `setup.bat` on Windows): it automates install, API key, provider/model,
   skills, and config.
4. If commands output errors, use the troubleshooting table at the bottom.
5. Privacy: never ask the user to paste their API key into the chat if it can
   be avoided. The setup script asks for it in the terminal directly. If the
   user does paste it into chat anyway, do not repeat it back.

## Method A: automated (recommended)

### macOS / Linux

Open Terminal and run these one by one:

```bash
# 1. Copy the suite to a permanent place (the folder you already unzipped to
#    works too). Example:
mkdir -p ~/canvas-scanner && cp -R <this-folder>/* ~/canvas-scanner/ && cd ~/canvas-scanner

# 2. Run the setup script. If an interactive wizard opens, Ctrl+C to skip it.
bash scripts/setup.sh
```

The script asks for the OpenRouter key, installs Hermes if missing, sets the
free Nemotron model, copies the skills, and runs a health check.

### Windows

Unzip the repo, then **double-click `setup.bat`**. It installs Hermes (via
PowerShell) if needed, then runs the same setup and asks for the API key.

If you prefer the terminal on Windows (PowerShell or Git Bash):

```powershell
# install Hermes (if not already installed):
iex (irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1)
# then, in Git Bash, from the repo folder:
bash scripts/setup.sh --no-install
```

### Non-interactive (or when an AI is running the commands)

Preset the key so the script never prompts:

```bash
OPENROUTER_API_KEY=sk-or-... bash scripts/setup.sh
```

The script is idempotent: re-running it is safe and skips what already exists.

## Method B: manual (everything step by step)

### Step 1. Install Hermes Agent

macOS / Linux:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

Windows (run in PowerShell):

```powershell
iex (irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1)
```

Then open a NEW terminal window so the `hermes` command is on PATH.

### Step 2. Add the OpenRouter key

The key file lives at:
- macOS / Linux: `~/.hermes/.env`
- Windows: `%LOCALAPPDATA%\hermes\.env` (i.e. `C:\Users\<you>\AppData\Local\hermes\.env`)

Append this line (or let setup.sh do it for you):

```bash
echo 'OPENROUTER_API_KEY=sk-or-...' >> ~/.hermes/.env
```

Never commit or share this file. It is your private key.

### Step 3. Point Hermes at OpenRouter + the free Nemotron model

```bash
hermes config set model.provider openrouter
hermes config set model.default "nvidia/nemotron-3-ultra-550b-a55b:free"
```

### Step 4. Install the suite skills

```bash
# macOS / Linux:
cp -R skills/* ~/.hermes/skills/
# Windows (Git Bash):
cp -R skills/* ~/AppData/Local/hermes/skills/
cp -R templates ~/AppData/Local/hermes/     # or ~/.hermes/ on macOS
```

New skills appear from your NEXT Hermes session.

### Step 5. School config (one file, once)

```bash
cp school-config.example.md ~/.hermes/school-config.md   # macOS/Linux
# Windows: copy it to your Hermes data dir as school-config.md
```

Open that file and replace every example value with the user's real ones:
student ID, Canvas domain, course IDs (the number in each course URL),
instructor names, platform URLs and `classes_root`. Roughly 10 lines. This
file is private and stays on their machine.

### Step 6. First run

1. `hermes desktop` (opens the app).
2. In the app's preview pane, open `https://<their-school>.instructure.com`
   and sign in once. The scanner reads this logged-in session; it persists.
3. Create a `Classes` folder wherever `classes_root` points.
4. Tell Hermes: "run the canvas course sync".

## Verify it worked

```bash
hermes doctor          # ends with no blocking errors
hermes --version       # prints a version line
```

A good sign: `hermes doctor` shows the provider as openrouter and no missing
API key warnings. Ask the user to run "run the canvas course sync" and confirm
the first course sweep lists announcements/assignments.

## Optional: always-on background gateway

The desktop app manages its own background process, so most users never need
this. If they want Hermes's gateway to start automatically at login (e.g. to
use it from chat apps later):

```bash
hermes gateway install
hermes gateway start
```

Check with `hermes gateway status`. On Windows this uses a Scheduled Task
(no admin needed); on macOS a launchd service; on Linux systemd.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `hermes: command not found` | Open a NEW terminal/PowerShell window (PATH refreshes then). Or use the full path: `~/.local/bin/hermes` (mac/Linux) or `%LOCALAPPDATA%\hermes\bin\hermes.exe` (Windows). |
| `hermes doctor` says the API key is missing | Confirm `OPENROUTER_API_KEY` is present in the correct `.env` file (Step 2). Watch for the file being at `~/AppData/Local/hermes/` on Windows vs `~/.hermes` elsewhere. |
| 401 / auth errors on first chat | The key was mistyped or has leading/trailing spaces. Re-add it with setup.sh (it trims whitespace) and restart Hermes. |
| Skills do not show up | They load at session start; start a new session. Verify the folders ended up directly under `skills/` (each with its own `SKILL.md`). |
| Interactive wizard appears during install | Press Ctrl+C. The setup script re-applies the correct provider and model right after. |
| PowerShell installer fails with "The assignment expression is not valid" | A BOM slipped into the downloaded script. Re-run the plain one-liner: `iex (irm <url>)` |
| Scans work but no Canvas content appears | The user must sign into their school's Canvas URL once in the desktop preview pane. |
| Anything else | Run `hermes doctor`, copy its output into the chat, and paste this file's troubleshooting table alongside. |

## Files in this repo that matter for setup

- `scripts/setup.sh`: the automation (macOS/Linux/Windows Git Bash).
- `setup.bat`: Windows double-click entry point.
- `school-config.example.md`: template for the user's private school config.
- `skills/`: the suites (copied into Hermes by setup).
- `templates/`: seeded support files.
- `README.md`: the same instructions, human-friendly.
- `docs/`: background reading (design philosophy, workflow).

## Notes

- This suite is public and clean by design: no real names, IDs, school
  domains, or course codes appear anywhere in it. Do not ask the user to edit
  any file inside the repo with personal data; those values belong only in
  their private `~/.hermes/school-config.md` (or equivalent).
- Updating the suite later needs no GitHub account: run the check via the
  `suite-update` skill ("check for updates" inside Hermes) or re-download the
  repo zip from https://github.com/Runtime-3rr0r/canvas-scanner.