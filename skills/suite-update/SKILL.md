---
name: suite-update
description: "Use when checking the canvas-scanner repo for updates."
---

# Suite Update (auto-sync from the parent repo)

The parent repo **canvas-scanner** (https://github.com/Runtime-3rr0r/canvas-scanner) is the single source of truth for this suite: skills, scripts, docs, README. Users do NOT need their own GitHub account or repo; the parent is checked anonymously (public repo).

## When to Use

- On session start (or weekly), unless the user opts out
- When the user says "check for updates", "pull the suite", "is there a new version"
- After the user edits files in this suite that deserve publishing (see below)

## Where the local VERSION lives

- **Git-clone install**: `VERSION` at the clone root.
- **Zip/folder install**: `VERSION` at the unzipped folder root.
- **setup.sh install**: copied to `$HERMES_HOME/canvas-scanner-version`
  (`~/.hermes` on macOS/Linux, `%LOCALAPPDATA%\hermes` on Windows).

## Check procedure (no login required)

First determine the install type: does the suite folder contain a `.git` directory?

### Git-clone installs

The clone knows its own position relative to the parent branch; no API call needed:

```bash
git -C <suite dir> fetch origin
git -C <suite dir> rev-list --count HEAD..origin/main
```

- `0` → up to date (report the local version).
- `> 0` → update available; apply with `git -C <suite dir> pull --ff-only`,
  then read what changed: `git -C <suite dir> log --oneline HEAD@{1}..HEAD`.

Do NOT compare the parent's latest commit SHA against the local `VERSION`
`git_sha` line: the parent's HEAD is always the "stamp VERSION" commit, which
sits one commit AFTER the content commit that `git_sha` records. Comparing
SHAs therefore reports a phantom update on every check, even when current.
`git_sha` is provenance only; updates are decided by branch position or
version number.

### Zip/folder installs

Compare version NUMBERS, local vs parent. The parent's VERSION is served as a
raw file, so this uses no GitHub API quota:

```bash
grep '^version:' "$HERMES_HOME/canvas-scanner-version" 2>/dev/null \
  || grep '^version:' <suite dir>/VERSION       # local
curl -s https://raw.githubusercontent.com/Runtime-3rr0r/canvas-scanner/main/VERSION | grep '^version:'   # parent
```

Compare the two `version: x.y.z` values numerically (three dotted ints):

```bash
python3 - <<'EOF'
import re, urllib.request
def ver(t):
    m = re.search(r"version:\s*([\d.]+)", t)
    return [int(x) for x in m.group(1).split(".")[:3]]
local = ver(open("<suite dir>/VERSION", encoding="utf-8").read())
parent = ver(urllib.request.urlopen(
    "https://raw.githubusercontent.com/Runtime-3rr0r/canvas-scanner/main/VERSION"
).read().decode())
print("update available" if parent > local else "up to date")
EOF
```

If newer: re-download the repo zip
(https://github.com/Runtime-3rr0r/canvas-scanner/archive/refs/heads/main.zip),
swap the folders, then re-run `bash scripts/setup.sh --no-install` (re-copies
skills + templates + refreshes the version file), or re-clone.

Report: version before → after, what changed, and whether any new skill needs
the next-session catalog refresh.

## Publishing from a fresh machine (only if the user HAS a GitHub account + wants to contribute)

- The parent repo is the origin's; changes are contributions. Prompt the user for GitHub setup ONLY if they ask to publish: `gh auth login` (or a PAT with repo scope), fork → PR, or request collaborator access.
- Never publish secrets. If a scan of the suite finds credentials, redact first.

## Pitfalls

- `git pull` requires the suite to BE a git clone. Folder installs update by swapping the folder + re-running setup; they do not need git.
- Local edits to suite files will conflict on pull; `git stash` or ask the user which copy wins.
- The parent HEAD is always the "stamp VERSION" commit; never decide updates from it for folder installs (see above).
- After pulling new skills, they appear in the catalog next session (session cache).
- `raw.githubusercontent.com` is not the GitHub API, so it is not rate-limited like the API (60 req/hr anonymous); daily checks are fine.