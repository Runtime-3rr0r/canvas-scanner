# Design Philosophies & Operating Patterns — The Hermes Skills Project

> Written by Hermes (Commander profile) for <SECOND_USER>'s Claude instance *and* for our
> own reflection. This documents how <USER_NAME> and Hermes work together, the
> principles we build by, the patterns we repeat, and — honestly — the friction
> points we've discovered and what we're doing about them.

---

## Part 1 — Philosophies we build by

### 1. SREC — the decision filter on everything
**Scalable, Reliable, Easy-to-maintain, Clean.** Every architecture, feature, and
skill decision passes through this lens. It appears in brainstorm, in skill
design, in config changes. When in doubt: "is this SREC?"

### 2. The Efficiency Compiler — waste elimination, not starvation
Every heavier operation ends with a silent self-audit: what tool calls added
nothing to the result? The rules get baked into the skill so the next run costs
less. Two hard guardrails:
- **Only fire when it matters** (heavy runs, or when asked). Cheap runs skip the
  audit — the noise isn't worth it.
- **Good information is NOT waste.** A search that genuinely informed the answer
  is never pruned. The goal is cutting calls that added nothing, not thinning the
  evidence.

### 3. Cost discipline — free first, pay only when free fails
Order of operations for anything with a public tool: try the free path
(yt-dlp, youtube-transcript-api, agent-browser, local models) before spending
API tokens. The whisper transcription costs $0.00025/reel — technicality
negligible — but the instinct to find the free route first is a principle, not a
budget. It keeps noise-tolerance honest: every dollar signals a real need.

### 4. Brainstorm first, build after
No build starts until the design is locked. New features get a design pass with
🔴🟠🟡 flaw flags and sharp questions. "Personal-use simple" is a standing
override on complexity — several over-engineered designs were rejected in favor
of pocket-knife simple.

### 5. Never delete; Archive.
Nothing gets destroyed. Skills are versioned, archived, or marked skipped/stale —
never removed. Dead ends are logged, not erased (they teach as much as the wins).

### 6. The Canary discipline
Every reply starts with the user's name ("<USER_NAME>" here; "<SECOND_USER>" on his
system). It is a context-integrity tripwire: if the name stops appearing, the
session's context is degrading. That is the signal to start a NEW session before
context loss corrupts the work.

### 7. Solo-work awareness
The human finishes many projects entirely outside the agent, unrecorded. We never
assume a project is stalled from missing tracker updates — we ask first.

### 8. Memory hygiene (learned mid-project)
Memory = only facts required in every session from the start. Anything coupled
to a skill lives IN that skill (it loads on invocation anyway). This freed 20% of
the persistent memory and made each skill self-sufficient.

### 9. The two-load principle (from writing-for-agents, adopted wholesale)
Every doc spends **context load** (always-loaded, costs every turn) or
**cognitive load** (costs the human to remember). Pointers live in context; bodies
stay disclosed. "An index is a pointer, not a store."

### 10. Verification scripts are permanent
Re-verification costs more than test maintenance. Every verification script stays
in the repo as a permanent test. "Works on my machine" without a script is not a
deliverable.

---

## Part 2 — Patterns in our design process

### The brainstorm → lock → build → brief loop
1. **Brainstorm** the feature (design questions, red flags, no edits yet)
2. **Lock** the design with explicit user choices (3 questions max, batched)
3. **Build** via delegation (subagents get strict JSON schemas + mode rules)
4. **Verify** (lint checks, real runs, structural audits)
5. **Brief** the user (what was done, what changed, what's next — a table or short
   list, not a wall of prose)

### Porting as a coherent suite, not isolated stubs
When porting 11 skills in a family (mattpocock's engineering suite), we kept them
cross-linked: shared vocabulary (codebase-design's module/seam/adapter), shared
conventions (CONTEXT.md + ADRs), explicit `related_skills` wiring. Porting one
without its suite would have broken the ones that call it.

### The two-way learning loop (human + bot)
The same skill-creating workflow runs in two modes:
- **Manual mode** (<USER_NAME> + Commander): quality-first, human watches every step
- **Auto mode** (Discord bot): drop a URL, bot distills + ships a skill alone
Both feed each other: the human refines the prompts the bot uses; the bot's
autonomous runs surface gaps to fix in the shared prompts.

### Bug-ledger discipline (the roadmap pattern)
Every goal on a roadmap gets a folder: `GOAL.md` (goal + originating prompt),
`BUGS.md` (open problems), `STATUS.md` (state). Bugs live in goal folders, NOT in
persistent memory. Loading one goal folder = full context for any session, not
just the one that created it.

### Batching as a principle
Questions, tool calls, clarifications, config changes — all batched into single
calls whenever possible. One `clarify()` with N questions, never N sequential
ones. Parallel builders over serial for independent work.

### Cheapness ladder in practice
Light → medium → heavy modes with hard caps per mode (claims extracted, searches
used). The mode is chosen once up front and the whole pipeline inherits it — the
subagents get mode-specific rules, so no mid-run cost negotiation.

### The silent-improvement rule
Self-improvement (Efficiency Compiler, skill patching after drift) runs silently
unless the user asks. Visible noise is a UX cost — spend it only on things the
human must decide.

---

## Part 3 — Friction points we've hit (and the fixes)

| # | Friction | What happened | Fix baked in |
|---|----------|---------------|--------------|
| 1 | `web_extract` silent failures | Backend (SearXNG) is search-only; extraction just fails | agent-browser inherited the job; extract.py uses it as first choice |
| 2 | `browser_exec` Chrome popups on Windows | Missing protocol handler fires "choose an app" dialogs | Banned in skills; agent-browser owns full-page text |
| 3 | Slash-skill loads but doesn't ACT | `/roadmap add ...` loaded the skill and stopped — a silent no-op from the user's view | Command-shaped skills must contain an explicit "consume the invocation argument and act now, then confirm back" step |
| 4 | Config edits corrupting YAML | `hermes config set` with escaped JSON stored channel_prompts as a string, breaking routing | Always verify `config get` + python yaml.safe_load parses as dict after any config set |
| 5 | Long-text generation drifts | Large SKILL.md ports landed with garbled phrases (3 skills) | Verification pass reads every ported skill top-to-bottom; typos fixed same session |
| 6 | Gateway can't restart from inside itself | Restarting gateway kills the session doing the restart | Restart always from a separate terminal; batch all restarts to one |
| 7 | MSYS path conversion | Native tools choke on `/c/`-style paths | Pass `C:/` absolute paths to native programs; `python` not `python3` |
| 8 | Skills land in session cache | New skills not visible until next session | Tell the user "available next session" explicitly |

---

## Part 4 — Recommendations to our future selves

1. **The converter needs a per-skill review pass.** The mechanical tool-name
   mapping (terminal→Bash etc.) is 90% right, but skills with heavy tool-specific
   prose (delegate output schemas, clarify()) deserve a human re-read before another
   export. Schedule it as a maintenance task, not a one-time build.
2. **Adopt the fog-of-war discipline for big efforts.** wayfinder's "ticket only
   what's sharp, leave the rest Not-yet-specified" now applies to us: we have a
   tendency to pre-chart too much of a big plan before the early decisions land.
3. **Keep the bug ledger close.** Every friction above became a lessons-entry in a
   goal folder. That's the flywheel: this document exists because of it.
4. **Re-audit memory when the skill library grows again.** The skill-vs-memory
   split drifts as skills change. Re-run the audit whenever a new skill family lands.
5. **<SECOND_USER>'s setup deserves its own tunable export.** The reverse converter
   (goal 006) should reference *his* actual setup so the export sharpens over time —
   the same way our larp-meter sharpened via the Efficiency Compiler.