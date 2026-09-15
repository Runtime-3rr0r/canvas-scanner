---
name: categorizer
description: "File inbox drops into the Projects tree; log roadmap items."
version: 1.0.0
author: Cora (categorizer fleet bot), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [categorizer, inbox, projects, toc, archive, roadmap]
    related_skills: [projects-tree, knowledge-tree, roadmap]
---
> **Config**: resolve `<PLACEHOLDER>` tokens from the user's private `~/.hermes/school-config.md` (`scripts/read_school_config.py` prints them; exits 1 with a hint if missing). Never edit SKILL.md with real values; never answer with literal placeholders.


# Categorizer

The role behind **cora**, the Hermes fleet categorizer. Turn inbox drops
(files, folders, links, Discord messages) into correctly-filed entries in the
Projects tree `C:\Users\<USER_NAME>\Documents\Projects\`, using the learned rules
file. Optionally log a dropped project onto the global roadmap
(`Documents\Projects\OPEN-ITEMS.md`).

This skill **encapsulates the categorizer procedure** so cora's behavior is a
loadable, editable skill (not just memory) — future features hang off it.

## When to Use

- Anything lands in `Documents\Projects\Inbox\` (disk drop, watcher, or manual)
- A Discord message/channel is routed to the categorizer with an attachment
- User says "categorize my inbox", "file this", "where should this go"
- User asks the categorizer to add a project to the roadmap

Don't use for: deep project work (that's other bots), or decisions the user
must make (park ambiguous, don't guess).

## Core inventory

- **Tree root:** `C:\Users\<USER_NAME>\Documents\Projects\` (drop point, TOC.md per folder)
- **Rules file:** `C:\Users\<USER_NAME>\Documents\Projects\.categorizer-rules.md` (learned
  conventions — READ FIRST, append new ones)
- **Inbox:** `Documents\Projects\Inbox\` (unprocessed drop zone; never move
  `Inbox/README.md`; ambiguous stays + reported, never guessed)
- **Global roadmap:** `Documents\Projects\OPEN-ITEMS.md` (accountability ledger:
  🔴🟠🟡 severity, verbatim prompts). Adding a project here makes it globally visible.
- **Plans/ROADMAP.md** (`Documents\Projects\Plans\`) — the goals roadmap for
  Hermes work specifically.

## Procedure

1. **Read the tree first.** Open root `TOC.md`, then the relevant category
   `TOC.md` — never list a folder blind before checking its TOC.
2. **Classify the drop** against `.categorizer-rules.md`:
   - Video/edit project → `Media/videos/<name>/`
   - SF2/MIDI/audio assets → `Media/audio/`
   - Homelab/server → `Knowledge/homelab/<server>/`
   - Academic → `School/`
   - Electronics/schematic → `Knowledge/electronics/`
   - Active code project (.git + source + README) → root `Projects/<name>/`
   - USB-bound boot/app ISO → `Projects/usb-staging/{boot,apps}/`
   - Stale leftover → `Archive/` (never delete)
3. **Move or place** (Copy → verify → delete for large/per-locked dirs; ask
   before moving anything risky). Strip the wrapper unless the name adds identity.
4. **Update the destination `TOC.md`** with a one-line entry.
5. **Learn.** Any user correction/teaching → append one line (no duplicate) to
   `.categorizer-rules.md`. Never repeat a corrected mistake.
6. **Report.** Tell the user what you filed and where. Ambiguous → leave in
   Inbox + report, never guess.

## School inbox mode (auto-provisioning, per machine)

Second inbox, same discipline, different tree: a **school Inbox** → `<CLASSES_ROOT>/<Course>/...`; ambiguous → a **Lost** folder.

### First run / provisioning (do this before the first drop)
- If `<SCHOOL_INBOX>` or `<LOST_FOLDER>` doesn't exist (from `school-config.md`), **ask the user where** they want the drop points, with sensible defaults:
  - Inbox: `~/Desktop/Inbox` · Lost: `~/Desktop/Lost`
- Create both folders, seed the Inbox with the soul from `templates/school-inbox-soul.md` (as `.categorizer-rules.md`, placeholders resolved from config), and create/keep a `README.md` in Lost with the log table header.
- Record `school_inbox` and `lost_folder` in the user's private `school-config.md` so later sessions reuse them without re-asking.

### Every run after that
- Read the soul FIRST (it learns). **Scan recursively** (folder drop-offs and individual files). **README-first**: a dropped folder's README names files + destinations. **Confidence gate**: no course code, no type keyword, no README → Lost, never a guess.
- The Lost pile is a feedback loop: the user sees it, describes/renames, re-drops, and that teaches a new rule. Every successful sort AND every correction/rename appends to "Learned rules" (no duplicates).
- Course code map + type keywords live in the soul (single source), seeded from `school-config.md`.
- Never delete; never overwrite (collision → suffix or Lost).

## Adding a project to the global roadmap

When the user asks (or it's clearly a new open project worth tracking):

1. Append a line to `Documents\Projects\OPEN-ITEMS.md` under the right severity
   (🔴 blocks / 🟠 soon / 🟡 someday) with: project name, what it is, why it's
   open, and any 🔴 bug/blocker.
2. If it's a Hermes-work goal, also create a goal folder under
   `Documents\Projects\Plans\goals\<NNN>-<slug>\` with GOAL.md + BUGS.md +
   STATUS.md (see `roadmap` skill).
3. When the user defers something in their exact words, save a
   `PROMPT-<topic>-<date>.txt` next to it and point to it on the ledger line
   (verbatim-prompts rule).

## Pitfalls

- **Never guess a category.** Ambiguous → leave in Inbox + report.
- **Never delete.** Junk → Archive/.
- **Don't move risky/unknown paths** without asking.
- **Don't overwrite** `Inbox/README.md`.
- **Don't build out projects** — file them, don't construct.
- **Don't blindly trust memory of the rules** — always re-read
  `.categorizer-rules.md` this run (it grows).

## Verification

- Every drop is filed with a TOC update.
- `.categorizer-rules.md` honors every prior correction.
- Roadmap additions (OPEN-ITEMS / goals folder) exist and are consistent.
- Nothing deleted; everything reversible.