# Lecture slide & textbook PDF extraction (image-heavy but text-layered)

## When read_file reports NeedsOcrError

The document extractor flags pages needing OCR, but lecture decks usually have a PARTIAL text layer (titles/bullets selectable, equations/figures rasterized). Before installing marker-pdf (~3-5 GB), try pymupdf directly — it recovers ~85% of pages for free.

```python
import pymupdf, os

doc = pymupdf.open(path)
out, weak = [], []
for i, page in enumerate(doc):
    t = page.get_text().strip()
    out.append(f"\n===== PAGE {i+1} =====\n{t}")
    if len(t) < 40:
        weak.append(i + 1)
txt_path = os.path.join(os.environ["TEMP"], os.path.basename(path).replace(".pdf", ".txt"))
with open(txt_path, "w", encoding="utf-8") as f:
    f.write("\n".join(out))
print(len(doc), "pages;", len(weak), "weak:", weak)
```

Then read the saved .txt with read_file. Notes:
- Page-marker lines (`===== PAGE N =====`) let you point the user at exact slides and pair missing equations with their slide numbers — equations are typically images, absent from the text layer.
- Only fall back to OCR for the weak pages, and only if their content matters for the review.
- Cache extracted text in %TEMP% so repeat reads don't re-parse the PDF.

## Pulling exact HW problems from the local textbook PDF

HW sheets often cite only problem numbers ("Text P 2.4-5"). When the textbook PDF is in Materials/:

1. Extract the FULL book text once (920 pp took ~5 s) to a temp .txt cache.
2. Grep each problem tag, allowing both spaced and unspaced forms the PDF may print (`P 2.4-5` and `P2.4-5`).
3. Print a window of lines around each hit and verify it's a problem statement line ("P <n>..."), not a cross-reference ("Figure 2.4-5", "Section 2.5-1", later-chapter echoes like "P 11.5-1").
4. Print the "Answer: ..." the book gives right below many P-problems — use it to verify the user's work, never as the solve.

Problem statements live in each chapter's Problems section (Dorf 9e: Ch 1 problems ~pp. 30-40, Ch 2 ~pp. 65-72); hits far outside that range are usually cross-references.
