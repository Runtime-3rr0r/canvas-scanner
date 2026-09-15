# Skill Mechanics

The skill-specific branch of `writing-for-agents`: what changes when the document
is a skill (frontmatter, the invocation choice, and router skills). Everything
else about writing it is the universal reference in SKILL.md.

## Invocation

Two choices, trading the two loads:

- **Model-invoked**: keep a `description` so the agent can fire it autonomously
  and other skills can reach it. You can still type its name — model-invocation
  always *includes* user reach; a description only ever adds agent discovery,
  never removes the human's. The description is the skill's top-level context
  pointer, forced to stay loaded: permanent context load in exchange for
  discoverability. This is also one home for shared reference — another model
  invoked skill can reach you, so reference needed by several skills lives in
  one place. Mechanics: omit `disable-model-invocation`, write a model-facing
  description carrying the trigger branches.

- **User-invoked**: strip the description from the agent's reach — only the human
  typing its name can invoke it, and no other skill can. Zero context load, but
  it spends cognitive load (you are the index that must remember it exists).
  Mechanics: set `disable-model-invocation: true`; the `description` becomes
  human-facing (a one-line summary, triggers stripped).

Pick model-invocation only when the agent must reach the skill on its own, or
another skill must. If it only ever fires by hand, make it user-invoked and pay
no context load.

Shared reference that two user-invoked skills both need can live in neither (no
descriptions mean neither can fire the other). Push it to a plain file outside
the skill system — external reference any skill can point at.

## Splitting by invocation

The invocation cut of the splitting decision (the sequence cut lives in
SKILL.md): split off a model-invoked skill when you have a distinct leading word
that should trigger it on its own (a trigger word you actually use in your
prompts), or when another skill must reach it. You pay context load for the new
always-loaded description, so that independent reach has to be worth it.

## Router skills

When user-invoked skills multiply past what you can remember, that piled-up
cognitive load is cured by a **router skill**: one user-invoked skill that lists
the others and when to reach for each, so the human has one skill to remember
instead of many. It can only hint, never fire them — user-invoked skills have no
description, so nothing but the human can reach them.