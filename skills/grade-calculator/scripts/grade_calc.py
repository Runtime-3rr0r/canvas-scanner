#!/usr/bin/env python3
"""grade_calc.py - what-do-I-need-on-the-remaining-component calculator.

Usage:
  python grade_calc.py --weights "10 15 25 50" --scores "95 90 88" --target 90
  (weights = component weights %; scores = current scores for the FIRST len(scores)
   weights; the remaining weight automatically becomes the 'final' bucket with blanks.)

Prints each component's contribution and the score required in the remaining bucket.
Requires: len(scores) < len(weights). Missing bucket = the exam/what's-left.
"""
import sys

def parse(s):
    return [float(x) for x in s.split() if x.strip()]

def main():
    args = sys.argv[1:]
    def val(flag):
        return args[args.index(flag) + 1] if flag in args else None
    w = parse(val("--weights"))
    sc = parse(val("--scores")) if val("--scores") else []
    target = float(val("--target"))
    if not w or len(sc) >= len(w):
        print("usage: grade_calc.py --weights '10 15 25 50' --scores '95 90' --target 90\n(len(scores) must be < len(weights))")
        sys.exit(1)
    contrib = sum(wi / 100.0 * s for wi, s in zip(w, sc))
    remaining_w = sum(w[len(sc):]) / 100.0
    for wi, s in zip(w, sc):
        print(f"  {wi:>4.0f}% weight | score {s:>5.1f} | contributions {wi/100*s:>6.2f} pt")
    print(f"  current total        : {contrib:6.2f} pt  (target {target} → need {target-contrib:+.2f} more)")
    if remaining_w <= 0:
        print("  no remaining components — adjust a score, not a gap")
        return
    needed = (target - contrib) / remaining_w
    verdict = "reachable" if 0 <= needed <= 100 else ("already banked (need <=0)" if needed <= 0 else "NOT reachable (>100)")
    print(f"  remaining weight     : {remaining_w*100:.0f}% (one bucket)")
    print(f"  NEEDED in remaining  : {needed:6.2f}  → {verdict}")

if __name__ == "__main__":
    main()