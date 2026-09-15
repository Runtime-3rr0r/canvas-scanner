# School Workflow — how the suite wires together

The loop that makes this feel like a live school advisor, not a file cabinet.

```
Canvas (pane, logged in)          Achieve / Pearson (user self-checks)
        │                                   │
        ▼                                   ▼
   canvas-course-sync  ──── sweep ───►  ROADMAP.md (single advisor drop point)
        │                                   │
        ├─ announcements → Announcements/   │  auto-log EVERYTHING (habits layer)
        ├─ modules/files → Materials/       │  load tags 🟢🟠🔴, pre-shifts
        └─ deadlines/points → course READMEs▼
                                    evening briefings ("what's my week?")
                                              │
Notes (photos/iPad) ──► study-notes-workflow ─┘  study flags → Roadmap
        ▼                                          │
   Physics/chem flags, *** questions,              ▼
   gap-fills, progress reports          weekly review (Sunday) → reprioritize
                                              │
Videos (Kaltura) ──► kaltura_pipeline.sh ──────┤  transcripts + Key Points → Materials/Lectures
Homework photos ──► photos-to-pdf ──► Downloads/ (submit-ready)
Updates ──► suite-update (anonymous parent-repo check, pull)
```

## Ground rules (from DESIGN-PHILOSOPHIES.md, applied here)

1. **Roadmap is an index, not a store** — pointers live there; content lives in course folders + goal folders.
2. **Auto-log everything, no matter how small** — completions, new deadlines, flags, tiny to-dos. Log when it happens, never batch.
3. **Bugs live in BUGS.md files, not memory** — memory stays for user/environment facts only.
4. **Verification before completion** — every "done" carries fresh evidence (file exists, command ran, page read).
5. **Never delete; archive** — anything superseded moves to an archive path, nothing is destroyed.
6. **Cost discipline** — free paths first (yt-dlp, local whisper, public APIs) before paid; whisper on CPU int8 is effectively free.
7. **Date hygiene** — confirm today's date via the live clock (`date`) before dating entries; context lines drift.
8. **Calendar (settled decision)**: the Roadmap.md IS the calendar. No .ics files, no Outlook sync. All 'what's my week/day/next' questions are answered from Roadmap load-tags (🟢/🟠/🔴). This supersedes every earlier .ics workflow.

## Privacy / secrets

- Provider keys: `~/.hermes/.env` only. Never in this suite.
- Kaltura URLs carry short-lived session tokens: never store them; fresh-copy per video (the `ks` dies in hours — 404 means expired, ask for a new one).
- The suite ships with zero credentials; a fresh user supplies only their own school login (in their own browser/pane).