#!/usr/bin/env python3
"""read_school_config.py - print the resolved school config for the agent.

Usage: python scripts/read_school_config.py            (print all)
       python scripts/read_school_config.py COURSE_ID_CHEM CLASSES_ROOT  (subset)

Reads ~/.hermes/school-config.md (or $HERMES_HOME/school-config.md) which the
user copies from school-config.example.md. Key=value lines and simple 'key: value'
YAML lines both parse. Missing file: prints the example path + creation hint and
exits 1 - the agent must prompt the user, never invent values.
"""
import os, sys, glob

HOMES = [os.environ.get("HERMES_HOME", ""), os.path.expanduser("~/.hermes")]
path = next((os.path.join(h, "school-config.md") for h in HOMES
             if h and os.path.isfile(os.path.join(h, "school-config.md"))), None)
if not path:
    print("MISSING ~/.hermes/school-config.md")
    print("Run: cp <suite>/school-config.example.md ~/.hermes/school-config.md, then fill it in.")
    sys.exit(1)

cfg = {}
for line in open(path, encoding="utf-8"):
    line = line.split("#", 1)[0].strip()
    if not line or ":" not in line and "=" not in line:
        continue
    k, _, v = line.partition("=") if "=" in line else line.partition(":")
    cfg[k.strip().lower()] = v.strip().strip('"').strip("'")

keys = sys.argv[1:] if len(sys.argv) > 1 else sorted(cfg)
for k in keys:
    k = k.lower()
    print(f"{k}: {cfg.get(k, '<UNSET>')}")
