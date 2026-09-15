# School-inbox SOUL (template)

Copy into the Inbox folder as `.categorizer-rules.md` on first run (the
categorizer provisions it the first time it sees a drop point). This file is
the categorizer's living brain: read at the start of EVERY inbox run, and it
learns by appending a rule from every successful sort and every user
correction. Replace every `<PLACEHOLDER>` from your `school-config.md`.

## Inputs & outputs
- **Inbox:** `<SCHOOL_INBOX>` (default the user-declared drop folder, e.g. Desktop/Inbox)
- **Output:** `<CLASSES_ROOT>/<Course>/...`
- **Lost:** `<LOST_FOLDER>` (e.g. Desktop/Lost)

## Protocol (run in order)
1. **Scan recursively** — folders arrive as full drop-offs; files may arrive individually.
2. **README-first:** a dropped folder's `README.md`/`README.txt` is the user's map — it may
   name files individually with destinations. Follow its references.
3. **Classify** by course code + type keyword in filename/path:
   - Course codes: whatever is in `school-config.md` (e.g. `PHYS2000`/`Physics` → Physics,
     `MATH1010`/`Calc` → Calculus, a `LAB` variant → its lab folder).
   - Type: `Syllabus` → course root · `HW#` → `Materials/Homework/HW#/` · `Lab` →
     `Materials/` · `Notes` → `Notes/` · `Lecture`/`Transcript` → `Materials/Lectures/` ·
     `Announcement` → `Announcements/` · `Exam`/`Formula` → `Materials/Homework/`.
4. **Confidence gate:** no course code, no type keyword, no README → Lost. Never guess.
5. **Move safely:** copy → verify → delete for large/locked items; preserve a bundle's
   internal structure. Never delete; never overwrite (collision → `-2` suffix or Lost).
6. **Learn:** append one rule line to "Learned rules" for every successful file and every
   user correction/rename (no duplicates). Consolidate the list if it passes ~50 rules.

## Lost protocol
- Move ambiguous items to `<LOST_FOLDER>`; append `name | why | date` to its `README.md`.
- The user sees the pile, describes (often just renames) and re-drops — their description
  is ground truth; record a Learned rule so it never gets lost the same way twice.

## Learned rules (append-only — the brain grows here)
- _(seed with 3 starter rules from your first test run, e.g. `HW# Work.*` → Circuit
  Theory/Materials/Homework/HW#/, a README-mapped lab bundle → the lab materials folder,
  and unnamed scans → Lost.)_