---
name: suite-update
description: "Use when checking the canvas-scanner repo for updates."
---

# Suite Update (auto-sync from the parent repo)

The parent repo **canvas-scanner** (https://github.com/<GITHUB_USER>/canvas-scanner) is the single source of truth for this suite: skills, scripts, docs, README. Users do NOT need their own GitHub account or repo; the parent is checked anonymously (public repo).

## When to Use

- On session start (or weekly), unless the user opts out
- When the user says "check for updates", "pull the suite", "is there a new version"
- After the user edits files in this suite that deserve publishing (see below)

## Check procedure (no login required)

1. Get the latest commit SHA publicly:
   ```bash
   curl -s https://api.github.com/repos/<GITHUB_USER>/canvas-scanner/commits?per_page=1 | grep -o '"sha": "[a-f0-9]*' | head -1
   ```
   (public API: 60 req/hr anonymous throttle; fine for weekly checks)
2. Compare against the LOCAL `VERSION` file (shipped with the suite: `version:` + `git_sha:` lines).
3. If newer:
   - **Git-clone installs**: `git -C <suite dir> fetch origin && git -C <suite dir> pull --ff-only`
   - **Zip/folder installs**: tell the user to re-download the repo zip (https://github.com/<GITHUB_USER>/canvas-scanner/archive/refs/heads/main.zip) and swap folders, OR re-clone.
4. Report: version before → after, what changed (read the diff log), and whether any new skill needs the next-session catalog refresh.

## Publishing from a fresh machine (only if the user HAS a GitHub account + wants to contribute)

- The parent repo is the origin's; changes are contributions. Prompt the user for GitHub setup ONLY if they ask to publish: `gh auth login` (or a PAT with repo scope), fork → PR, or request collaborator access.
- Never publish secrets. If a scan of the suite finds credentials, redact first.

## Pitfalls

- Anonymous GitHub API is rate-limited (60/hr) — never loop it; weekly is plenty.
- `git pull` requires the suite to BE a git clone. Folder installs get manual zip updates by design.
- Local edits to suite files will conflict on pull; `git stash` or ask the user which copy wins.
- After pulling new skills, they appear in the catalog next session (session cache).
