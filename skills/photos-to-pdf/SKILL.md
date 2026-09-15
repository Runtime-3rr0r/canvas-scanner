---
name: photos-to-pdf
description: "Use when combining photos/scans into a neat submission PDF."
---
> **Config**: resolve `<PLACEHOLDER>` tokens from `~/.hermes/school-config.md` (see `canvas-course-sync` → School config). Never edit SKILL.md with real values.


# Photos → Neat PDF

Turn one or more photos/scans of written work into a single clean PDF for submissions (Canvas HW drops, lab reports, notes) or archival.

## Script: `scripts/photos_to_pdf.py`

```bash
"C:/Users/<USER_NAME>/AppData/Local/hermes/hermes-agent/venv/Scripts/python.exe" \
  "$SKILL_DIR/scripts/photos_to_pdf.py" "<output.pdf>" "<img1>" ["<img2>" ...]
```

- One image per US-Letter page; **page orientation follows the image** (portrait img → portrait page, landscape img → landscape page).
- Applies EXIF rotation (phone vertical shots), fits the image inside 0.5" margins, centers it, and prints a small gray caption = the source filename (strips the extension) so multi-part submissions stay self-labeled.
- PNG output preserves sharpness; JPEGs/HEIC input fine via PIL.

## Workflow

1. File the user's work JPGs into `<Course>/Materials/Homework/HW{n}/` first (see `canvas-course-sync` skill). If the user also drops an AI-chat export (Gemini guide), it lives beside them as reference.
2. Run the script with all the HW photos → submit-ready PDF in the same folder (name it e.g. `<COURSE_CODE> - HW1 Submission.pdf`).
3. **Copy the finished PDF into `C:/Users/<USER_NAME>/Downloads/`** — the user uploads/submits from Downloads (explicit preference). Keep the archive copy in `HW{n}/` so it's recoverable; refresh the Downloads copy whenever the PDF is regenerated.
4. Verify: render each page to PNG (`page.get_pixmap()` → save) and look at it — confirm nothing is rotated or clipped before telling the user it's ready to submit.
5. If a page turns out sideways or cropped, fix orientation/scale in the script and re-run (then re-copy to Downloads).

## Pitfalls

- PIL + PyMuPDF live in the Hermes venv python (`C:/Users/<USER_NAME>/AppData/Local/hermes/hermes-agent/venv/Scripts/python.exe`), not the system python.
- Check EXIF orientation before trusting pixel dimensions — a "portrait" file may actually be an upright landscape shot.
- **Blurry/pixelated output** = the embed got downsampled; embedded pixels must stay at source resolution (verify `page.get_images()` dims match the source). Display size ≠ pixel size - only resize for display, never for storage.
- Always visually verify the rendered pages (vision_analyze) — a PDF that parses can still contain sideways pages.
