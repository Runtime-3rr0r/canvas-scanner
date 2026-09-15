#!/usr/bin/env python3
"""photos_to_pdf.py - combine photos/scans into one neatly formatted PDF.
Usage: photos_to_pdf.py <output.pdf> <image1> [image2 ...]

One image per US-Letter page, page orientation follows the image aspect ratio,
EXIF rotation applied, image fit within 0.5in margins and centered, small gray
caption (source filename without extension) under each image.

IMPORTANT: the embedded image keeps its FULL native resolution (no resize -
resizing to the page size is what makes output look pixelated). The PDF just
scales where it draws; viewers downsample only for display.
"""
import sys, os, io
from PIL import Image
import pymupdf

MARGIN = 36       # points = 0.5 in
PAGE_W, PAGE_H = 612, 792  # US Letter portrait
CAPTION_SIZE, CAP_GRAY = 8, 0.40


def normalize(path):
    im = Image.open(path)
    o = (im.getexif() or {}).get(274)
    if o in (3, 6, 8):
        im = im.rotate({3: 180, 6: 270, 8: 90}[o], expand=True)
    return im.convert("RGB")


def add_page(doc, path):
    im = normalize(path)
    w, h = im.size
    landscape = w > h
    pw, ph = (PAGE_W, PAGE_H) if not landscape else (PAGE_H, PAGE_W)
    scale = min((pw - 2 * MARGIN) / w, (ph - 2 * MARGIN) / h)
    dw, dh = int(w * scale), int(h * scale)   # draw size only - pixels stay native
    page = doc.new_page(width=pw, height=ph)
    x, y = (pw - dw) // 2, (ph - dh) // 2
    buf = io.BytesIO()
    im.save(buf, format="JPEG", quality=92)   # re-encode keeps EXIF-normalized pixels, no downscale
    page.insert_image(pymupdf.Rect(x, y, x + dw, y + dh), stream=buf.getvalue())
    cap = os.path.splitext(os.path.basename(path))[0]
    cap_rect = pymupdf.Rect(MARGIN, ph - 24, pw - MARGIN, ph - 8)
    page.insert_textbox(cap_rect, cap, fontsize=CAPTION_SIZE,
                        align=pymupdf.TEXT_ALIGN_CENTER, color=(CAP_GRAY,) * 3)


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    out, paths = sys.argv[1], sys.argv[2:]
    doc = pymupdf.open()
    for p in paths:
        add_page(doc, p)
    doc.save(out)
    print(f"WROTE {out}: {len(paths)} page(s)")


if __name__ == "__main__":
    main()
