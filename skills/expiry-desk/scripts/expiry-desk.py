#!/usr/bin/env python
# expiry-desk.py - zero-token renewal watchdog.
# Empty stdout means no delivery.
import csv, os
from datetime import date, datetime

path = os.path.expanduser("~/life/renewals.csv")
today = date.today()
due = []

try:
    with open(path) as f:
        for row in csv.DictReader(f):
            if not row.get("date"):
                continue
            when = datetime.strptime(row["date"].strip(), "%Y-%m-%d").date()
            lead = int(row.get("lead_days") or 30)
            days = (when - today).days
            if 0 <= days <= lead:
                due.append((days, row["name"], when, row.get("note", "")))
except FileNotFoundError:
    print(f"WARNING: {path} is missing - the expiry desk is blind.")
    raise SystemExit(0)
except Exception as e:
    print(f"WARNING: expiry desk could not read {path}: {e}")
    raise SystemExit(0)

if not due:
    raise SystemExit(0)

due.sort()
print("Coming up:")
for days, name, when, note in due:
    line = f"- {name}: {when:%d %b %Y} ({days} days)"
    if note:
        line += f" - {note}"
    print(line)
