---
name: verification-before-completion
description: "Back completion claims with fresh verification evidence."
version: 0.1.0
author: obra/superpowers, Hermes Agent (ported by <USER_NAME>)
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [verification, evidence, completion, quality, testing]
    related_skills: [test-driven-development, requesting-code-review, tdd]
---

# Verification Before Completion

## Overview

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this turn, you cannot claim it
passes.

## When to Use

- About to claim work is "complete", "fixed", or "passing"
- Before committing, pushing, or opening a PR
- After running a test, build, or linter — before declaring the result
- Any time you're tempted to write "done", "all good", "should be fine"

Don't use for: brainstorming, design discussion, exploration (no completion claim
to verify).

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim
```

Skipping any step is lying, not verifying.

## Common Failures

| Claim | Requires (sufficient) | NOT sufficient |
|-------|------------------------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command exit 0 | Linter passing, logs look good |
| Bug fixed | Re-test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags — STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!")
- About to commit/push/PR without verification
- Trusting another agent's "success" report — run it yourself
- Relying on a partial check (only some lines of a test run)
- Thinking "just this once"
- Any wording implying success without having run the verification

## Procedure

1. **Identify the claim** you're about to make (tests pass / build ok / bug fixed).
2. **Choose the exact command** that would falsify the claim if it failed.
3. **Run it fresh, in full.** No caching mentally, no assuming.
4. **Read the raw output**: exit code, stderr, failure count.
5. **Decide honestly**: does this confirm the claim?
   - Yes → state the outcome with the evidence (e.g. "pytest: 42 passed").
   - No → state the actual status with evidence; don't paper over it.
6. Confirm. Your narration states claims only after step 5.

**In Hermes tools:** the verification command is `terminal(command=...)`. Run the
command bare — never pipe its output into a truncating filter (that can mask the
real exit code) and don't wrap it with success-echo hacks that swallow failures.

## Pitfalls

- **Reporting a success from memory** — evidence must be from this turn's run.
- **Truncating output that hides a failure** — run the full command, read the
  real exit code.
- **`cmd || echo done` masks failure** — the pipeline reports the pipeline's last
  command exit code; run bare.
- **Trusting a subagent's "success"** — require raw evidence from it, else re-run.
- **"Should pass"** — not a verification.

## Verification

Every "done" claim you make is backed by a `terminal(command=...)` you ran in
this turn whose output you actually read.