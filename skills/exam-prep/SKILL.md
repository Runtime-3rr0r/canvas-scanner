---
name: exam-prep
description: "Use when planning an exam-prep sprint from Mastery-Log."
---

# Exam Prep Sprint

Turn Mastery-Log + Question-Bank + the Roadmap into a focused, load-balanced sprint for one exam. Reuses existing systems; nothing new to invent.

## Inputs
- Course + exam date (from the user or COURSE-BRAIN key dates)
- `<Course>/Notes/Mastery-Log.md` (statuses) · `<Course>/Notes/Question-Bank.md` (drill material) · `Roadmap.md` (available load)

## Procedure
1. **Rank weak topics**: 🔴 first, then stale 🟡 (untouched ~3 weeks). Sort by: foundational weight (a broken prerequisite cascades — fix it first), past-exam point value if known, confidence decay (older 🔴 > newer).
2. **Build the sprint**: a 3 / 7 / 10-day plan (pick by time-to-exam), day-by-day targets, each with a time estimate and a "drill this" pointer into Question-Bank, practice sets, or Key Points.
3. **Auto-add as Roadmap study blocks** in the sprint window, load-balanced (🔴 topics get heavier blocks, never stacked onto an already-🔴 day).
4. **Track**: after every drill session update Mastery-Log (`topic | status | date`).
5. **Post-exam feedback**: user reports the score + which topics appeared → write ground truth into Mastery-Log so the next exam's ranking learns.

## Pitfalls
- Don't plan more hours than exist — respect the Roadmap's load tags.
- Refresh Mastery-Log the same day you build the sprint; stale statuses mis-prioritize.
- One sprint per exam; re-run only when new weak topics appear.
