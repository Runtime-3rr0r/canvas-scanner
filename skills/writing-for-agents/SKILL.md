---
name: writing-for-agents
description: "Write skills and agent docs for low load, high reliability."
version: 0.1.0
author: Matt Pocock, Hermes Agent (ported by <USER_NAME>)
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [skill-writing, agent-docs, pointers, context-load]
    related_skills: [hermes-agent-skill-authoring, codebase-design]
---

# Writing for Agents

Reference for writing any document an agent consumes: a skill, an `AGENTS.md` /
`CLAUDE.md`, a doc reached by a pointer. The packaging differs; the writing does
not — the same levers make each one predictable, because the agent takes the
same *process* every run rather than producing the same output.

**This is the meta-discipline behind every other skill.** Use it whenever you
write or edit a skill, AGENTS.md, or any agent-facing doc. When the document is
a skill, also read `references/SKILL-MECHANICS.md` for frontmatter, invocation
choice, and router skills.

## When to Use

- Creating or editing a skill (including the ones in this suite)
- Writing or modifying `AGENTS.md` / `CLAUDE.md` / project rules
- Writing any document an agent will read

Don't use for: human-only documentation (specs, READMEs for people) — though the
leading-words and pruning ideas still apply.

## Context pointers

A **context pointer** is a reference held in the agent's context that names some
out-of-context material and encodes the condition for reaching it. A skill's
description is one; a line in `AGENTS.md` naming a doc is the same object. The
pointer's *wording*, not its target, decides when the agent reaches the material.

A pointer does two jobs: state what the material is, and list the **branches**
that trigger reaching it. Every word of an always-loaded pointer costs on every
turn, so prune harder than the body:

- **Front-load the leading word** — the pointer does its triggering work up front
- **One trigger per branch** — collapse synonyms for the same branch
- **Cut identity the body already carries**

## The two loads

Every document and pointer spends one of two budgets:

- **Context load** — the cost of always-loaded material on the agent's window
  (an AGENTS.md line, a skill description). Spends tokens/attention every turn
  whether or not it fires.
- **Cognitive load** — the cost on the *human*: which docs exist and when to
  reach for each. Not a cost to minimise; it is the price of human agency. Spend
  it where human judgement matters, remove it where it does not.

Material behind a pointer escapes context load (pays only the pointer's line);
material with no pointer rides entirely on cognitive load.

## Information hierarchy

A document is built from **steps** (ordered actions) and **reference**
(definitions/rules/facts consulted on demand). Where each sits on the ladder:

1. **In-file step** — primary tier: what the agent does, in order
2. **In-file reference** — consulted on demand
3. **Disclosed reference** — pushed into a separate file, reached by a pointer

Push too little down → the top bloats. Push too much → you hide material the
agent needs. That tension is the whole decision.

- **Progressive disclosure** is moving down the ladder (out of the main file,
  behind a pointer) to keep the top legible. Not primarily token saving — it
  protects the hierarchy. Inline what every branch needs; disclose what only
  some reach.
- **Co-location** decides what sits beside what once there — keep a concept's
  definition, rules, and caveats under one heading so reading part brings its
  neighbors.
- **Sprawl** is the failure mode: a document too long even when every line is
  live. Cure: disclose reference behind pointers, split by branch/sequence.

## Steps and completion criteria

Every step ends on a **completion criterion** — the condition that tells the
agent the work is done. Two properties make it a lever:

- **Clarity** — can the agent tell done from not-done? A vague bound invites
  *premature completion* (ending before genuinely done). Sharpen the bound
  first.
- **Demand** — how much it requires. "Every modified model accounted for"
  forces thorough work where "produce a change list" does not.

The strongest criteria are both **checkable and exhaustive**.

## When to split

Splitting spends one of the two loads, so split only when the cut earns it:
- **By sequence** — split a run of steps where the later, visible steps tempt
  the agent to rush the one in front.
- **By invocation** (skill-specific) — see `references/SKILL-MECHANICS.md`.

## Leading words

A **leading word** is a compact concept already in the model's pretraining that
the agent thinks with while running the document (*lesson*, *fog of war*,
*tracer bullet*). Repeated as a token, it anchors a region of behavior with the
fewest tokens by recruiting priors. Coin your own only if you define it clearly;
a made-up word pays in definition tokens what a pretrained word gives free.

Hunt for restatements to collapse into a single token:
- "fast, deterministic, low-overhead" → *tight*
- "a loop you believe in" → *red* (a *tight loop* that goes *red* on the bug)

**Negation** is the failure mode beside this: steering by prohibition drags the
forbidden behavior into context and makes it *more* available. *Don't think of
an elephant* — the elephant is all there is. Prompt the **positive** (state the
target behaviour), and pair any unavoidable guardrail with the positive target.

## Pruning

- **Single source of truth.** Keep each meaning in one authoritative place.
  *Duplication* costs maintenance + tokens.
- **The environment is a source of truth too.** `package.json` scripts, config,
  directory layout, `--help`. A document that restates the environment is a
  *cache* — earn its load only when the lookup is expensive. Cache only the
  unwritten conventions, reasons, and gotchas config won't confess.
- **Relevance.** Does each line still bear on what the document does? Without a
  pruning discipline the default fate is *sediment* — stale layers that settle.
- **Hunt no-ops sentence by sentence** — an instruction the model already obeys
  by default. The test (does it change behavior vs the default?) is
  model-relative; settle disputes by running the doc. Delete whole sentences,
  not trim words. A weak word is a no-op — use a stronger one.

## Procedure (writing or reviewing an agent-facing doc)

1. **Identify the two loads.** Is this content always-loaded, or behind a
   pointer? What's the human's cognitive cost?
2. **Place each piece on the ladder.** Inline what every branch needs; disclose
   what only some reach. Co-locate related definitions.
3. **Write steps with strong completion criteria** — checkable + exhaustive.
4. **Adopt leading words** for repeated behavior concepts; prompt positively.
5. **Prune.** Single source of truth, let the environment own what it can, drop
   no-ops and stale/relevance-lost lines.

## Related

- `references/SKILL-MECHANICS.md` — skill-specific mechanics: model-invoked vs
  user-invoked, splitting by invocation, and router skills.
- `hermes-agent-skill-authoring` — the repo-standard Hermes frontmatter/struct
  rules (the machine-side requirements this skill's discipline complements).

## Pitfalls

- **A weak pointer for a must-have target** — a reliability bug; sharpen the
  wording or inline the material.
- **Restating the environment** — a cache that goes stale. Let config/help own
  what they own.
- **Scattering instead of co-locating** — fragments one meaning across places.
- **Relying on negation** — prohibitions make the banned behavior more available.
  Prompt positively.
- **A bloated guts with no disclosure** — don't protect the top tier by hiding
  material the agent needs; cut or disclose, don't pad.

## Verification

- Read each line: does it change the model's behavior vs the default? If not,
  it's a no-op — delete it.
- Duplicate meanings collapsed to a single source.
- Environment-owned lookups not restated.
- Completion criteria checkable and exhaustive.
- High-value material stays inline; branch-specific content is behind pointers;
  no sprawl.