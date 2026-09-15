---
name: grade-calculator
description: "Use when computing grade scenarios or final-needed scores."
---
> **Config**: resolve `<PLACEHOLDER>` tokens from `~/.hermes/school-config.md` (see `canvas-course-sync` → School config). Never edit SKILL.md with real values.


# Grade Calculator

Answer "what do I need on the final/exam to land X?" from real data, never vibes.

## When to Use
- User asks: "what do I need on the final for a B+", "can I still get an A", "how much is X worth"
- During the weekly sweep, when new grades come in (refresh the scenario then)

## Procedure
1. **Weights**: read the grading table from the course `COURSE-BRAIN.md` (or README) — e.g. participation 10 / homework 15 / quizzes 25 / exams 50.
2. **Current scores**: pull from the last Canvas sweep (assignments page read) or the user; keep placeholders for ungraded items if unknown.
3. **Compute**: run `skills/grade-calculator/scripts/grade_calc.py` with weights/current/target, or do the algebra directly: `needed_component = (target - sum(weight_i * score_i for finished)) / remaining_weight` — the remaining weight is the big exam (or a weighted bucket if multiple open items).
4. **Show it as a small table** (component, weight, score, contribution) + the one-number answer. If the answer is >100 or <0, say plainly "not reachable" / "already banked" — the math is the point.
5. Remember the professor's rounding rules if known (e.g. video-quiz ≥50% → 100%) before finalizing.

## Pitfalls
- Don't guess weights — read them. A missing weight silently changes the answer.
- Scores change mid-semester: the number is only as fresh as the sweep; state the data date.
- If the user only gives "an A", confirm the exact letter boundary (A- vs A) before computing.