#!/usr/bin/env python3
"""PII sanitizer for the canvas-scanner repo (run from repo root).

Replaces real identifiers with <PLACEHOLDER> tokens so the public repo is a
blank template. Identifier pattern lists are stored base64-encoded and decoded
at runtime only, so this public file never itself exposes the identifiers it
guards against. Skips itself and .github/ (same reason). Add entries as
identifiers appear. Never run on ~/.hermes/ or the live skills directory.

Encode a new pattern for the list below with:
  python -c "import base64; print(base64.b64encode(r'YOUR_PATTERN'.encode()).decode())"

Usage:  python scripts/sanitize.py
"""
import os, re, sys, base64

def _p(s):
    return base64.b64decode(s).decode()

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # repo root (parent of scripts/)
SKIP_FILES = {"sanitize.py"}
SKIP_DIRS = {".git", ".github"}  # pattern lists are sensitive-by-definition there too

REPL = [
    # NOTE: the real repo URL github.com/Runtime-3rr0r/canvas-scanner (and its
    # api.github.com/repos/... update-check form) is public routing info and is
    # intentionally PRESERVED in the repo, never placeholder-replaced (see
    # REPO_URL_OK below).
    (_p("XGJDaHJpc3RpYW4gSlwuIE1pbGxzXGI="), "<USER_NAME>"),
    (_p("XGJDaHJpc3RpYW4gTWlsbHNcYg=="), "<USER_NAME>"),
    (_p("XGJDaHJpc3RpYW5cYg=="), "<USER_NAME>"),
    (_p("XGJDaHJpc1xi"), "<USER_NAME>"),
    (_p("Y2hyaXN0aWFubWlsbHMxN0BpY2xvdWRcLmNvbQ=="), "<USER_EMAIL>"),
    (_p("KD88IWdpdGh1YlwuY29tLykoPzwhcmF3XC5naXRodWJ1c2VyY29udGVudFwuY29tLykoPzwhcmVwb3MvKVJ1bnRpbWUtM3JyMHI="), "<GITHUB_USER>"),
    (_p("XGJKYXNvblxi"), "<SECOND_USER>"),
    (_p("XGI4MTAwMDhcYg=="), "<STUDENT_ID>"),
    (_p("Y2FsYmFwdGlzdFwuaW5zdHJ1Y3R1cmVcLmNvbQ=="), "<SCHOOL_DOMAIN>"),
    (_p("QzovVXNlcnMvQ2hyaXMvRGVza3RvcC9DbGFzc2Vz"), "<CLASSES_ROOT>"),
    (_p("QzpcXFVzZXJzXFxDaHJpc1xcRGVza3RvcFxcQ2xhc3Nlcw=="), "<CLASSES_ROOT>"),
    (_p("XGJKZWZmIENhdGVcYg=="), "<NT_PROF>"),
    (_p("XGJEclwuIENhdGVcYg=="), "<NT_PROF>"),
    (_p("XGJDYXRlXGI="), "<NT_PROF>"),
    (_p("XGJEclwuIFNjaGFjaHRcYg=="), "<CHEM_PROF>"),
    (_p("XGJTY2hhY2h0XGI="), "<CHEM_PROF>"),
    (_p("cHNjaGFjaHRAY2FsYmFwdGlzdFwuZWR1"), "<CHEM_PROF_EMAIL>"),
    (_p("amNhdGVAY2FsYmFwdGlzdFwuZWR1"), "<NT_PROF_EMAIL>"),
    (_p("Y2hhcGVsQGNhbGJhcHRpc3RcLmVkdQ=="), "<SCHOOL_EMAIL>"),
    (_p("XGJTZXRoXGI="), "<LAB_INSTRUCTOR>"),
    (_p("XGJUeXJvbmVcYg=="), "<CLUB_PRES>"),
    (_p("XGJOYXRoYW5cYg=="), "<CLUB_SECRETARY>"),
    (_p("XGJNaWxsc0NcYg=="), "<KAHOOT_USERNAME>"),
    (_p("YWNoaWV2ZVwubWFjbWlsbGFubGVhcm5pbmdcLmNvbS9jb3Vyc2VzL2p4Mjg0Yw=="), "<ACHIEVE_COURSE_URL>"),
    (_p("bXlsYWJtYXN0ZXJpbmdcLnBlYXJzb25cLmNvbS9jb3Vyc2VzLzE0NDI4ODkxL21lbnUvODI3ZDRiYmMtNWM5Yi00MzRlLWJmNjctZGVmYjEwOWI3NDRj"), "<PEARSON_COURSE_URL>"),
    (_p("XGIxMjkxMFxi"), "<COURSE_ID_CHEM>"),
    (_p("XGIxNzA3Mlxi"), "<COURSE_ID_CHEM_LAB>"),
    (_p("XGIxMzY2NVxi"), "<COURSE_ID_CIRCUITS>"),
    (_p("XGIxMzY2N1xi"), "<COURSE_ID_CIRCUITS_LAB>"),
    (_p("XGIxMzQ3Nlxi"), "<COURSE_ID_NT>"),
    (_p("XGIxMzY3OVxi"), "<COURSE_ID_STATICS>"),
    (_p("XGIxNjAzNVxi"), "<COURSE_ID_CHAPEL>"),
    (_p("XGJFTkdSMjMxMExcYg=="), "<CIRCUITS_LAB_COURSE_CODE>"),
    (_p("XGJFTkdSMjMxMFxi"), "<CIRCUITS_COURSE_CODE>"),
    (_p("XGJFTkdSMjQxMFxi"), "<STATICS_COURSE_CODE>"),
    (_p("XGJDSEVNMTE1MExcYg=="), "<CHEM_LAB_COURSE_CODE>"),
    (_p("XGJDSEVNMTE1MFxi"), "<CHEM_COURSE_CODE>"),
    (_p("XGJDSFNUMTMwMFxi"), "<NT_COURSE_CODE>"),
    (_p("XGJHTlNUMDUwMFxi"), "<CHAPEL_COURSE_CODE>"),
    (_p("XGJDQlVcYg=="), "<SCHOOL>"),
]

LEAKS = re.compile(_p("ODEwMDA4fGNhbGJhcHRpc3R8QzovVXNlcnMvQ2hyaXN8U2NoYWNodHxKZWZmIENhdGV8XGJDYXRlXGJ8XGJTZXRoXGJ8XGJUeXJvbmVcYnxcYk5hdGhhblxifFxiTWlsbHNDXGJ8Y2hyaXN0aWFubWlsbHMxN3xjaHJpc3RpYW5taWxsc3xcYkNocmlzXGJ8XGJDaHJpc3RpYW5cYnxcYkphc29uXGJ8YWNoaWV2ZVwubWFjbWlsbGFubGVhcm5pbmd8bXlsYWJtYXN0ZXJpbmdcLnBlYXJzb258XGJDQlVcYnxcYkNIU1RcZHs0fVxifFxiR05TVFxkezR9XGJ8XGJFTkdSXGR7NH1bQS1aXT9cYnxcYkNIRU1cZHs0fVtBLVpdP1xi"), re.I)
REPO_URL_OK = re.compile(r"(?:github\.com|raw\.githubusercontent\.com|api\.github\.com/repos)/Runtime-3rr0r/canvas-scanner")

changed = 0
for dirpath, dirs, files in os.walk(ROOT):
    dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
    for fn in files:
        if fn in SKIP_FILES:
            continue
        p = os.path.join(dirpath, fn)
        try:
            with open(p, "r", encoding="utf-8", errors="surrogateescape") as f:
                text = f.read()
        except Exception:
            continue
        orig = text
        for pat, rep in REPL:
            text = re.sub(pat, rep, text)
        if text != orig:
            with open(p, "w", encoding="utf-8", errors="surrogateescape") as f:
                f.write(text)
            changed += 1
            print("SANITIZED:", os.path.relpath(p, ROOT))

print(f"\n{changed} file(s) changed")

bad = []
for dirpath, dirs, files in os.walk(ROOT):
    dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
    for fn in files:
        if fn in SKIP_FILES:
            continue
        p = os.path.join(dirpath, fn)
        try:
            for i, line in enumerate(open(p, "r", encoding="utf-8", errors="surrogateescape"), 1):
                if REPO_URL_OK.search(line):
                    continue  # the real parent-repo URL is intentional
                for m in LEAKS.finditer(line):
                    bad.append(f"{os.path.relpath(p, ROOT)}:{i}: {m.group(0)}")
        except Exception:
            continue
if bad:
    print("LEAKS REMAINING:")
    [print("  ", b_) for b_ in bad]
    sys.exit(1)
print("VERIFY: CLEAN - no real identifiers left outside skipped files")
