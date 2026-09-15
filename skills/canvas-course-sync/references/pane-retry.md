# Pane retry helper — drive_preview / desktop_preview flakiness

Known flake modes (documented in three skills before this file existed):
'arguments is not valid JSON', 'pointer input never reached the page',
elements list silently stale, click "acted" but page didn't move, tab showing
the wrong URL after an `open`.

## Retry ladder (cheapest first)
1. Re-run `elements()` for fresh refs — refs die on navigation; a stale ref is
   almost always the cause. Then re-read the page text.
2. Wait ~2s after any navigation (`wait_for_load`-style pause), then
   `desktop_preview read` again — async pages render late.
3. Verify the pane's current URL matches intent; if a click "acted" but nothing
   moved, the click opened a NEW tab — close the tab by URL and re-open, or
   navigate the pane's address directly.
4. `reload`, then re-inventory. If the page is mid-redirect, wait then re-read.
5. If a link keeps routing to the wrong target (external-URL item vs its
   attachment), use the direct `/courses/<ID>/...` path instead of the click.

## When to hand back to the human
- Download controls that only appear on hover (Canvas ⤓): the pane cannot
  synthesize the mouse. Give the user the exact hover → ⤓ step; do NOT burn
  minutes on the pane.
- Login walls on third-party tools (Achieve, Pearson): user self-checks anyway.
- Chrome-profile locks: never kill the user's tabs; ask before driving a
  local browser session that requires Chrome to be quit.

## Guardrail
Never claim "scanned" from the pane without one successful fresh read of the
target page — an empty or stale read is not evidence.