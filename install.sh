#!/usr/bin/env bash
# Idempotent installer for the Hermes Personal Automation collection.
#
# Safe to run as many times as you like:
#   - skills you already have are SKIPPED (your local edits are never touched)
#   - only missing skills are installed (via `hermes skills install`, so each
#     new one registers its schedule as a /suggestions entry you confirm)
#   - suggestions you already accepted or dismissed stay that way — the
#     dedup latch upstream guarantees a dismissed suggestion is never re-offered
#
# Usage:  bash install.sh            # install everything missing
#         bash install.sh expiry-desk quiet-inbox   # just these
set -u

REPO_RAW="https://raw.githubusercontent.com/harperaa/hermes-personal-automation/main"
HH="${HERMES_HOME:-$HOME/.hermes}"
ALL="secure-box-audit return-desk out-the-door-brief money-watch expiry-desk quiet-inbox sunday-kitchen people-file morning-standup boot-health-check sunday-ledger"
SKILLS="${*:-$ALL}"

command -v hermes >/dev/null 2>&1 || {
  echo "ERROR: the 'hermes' CLI is not on PATH. Run this on your Hermes box"; exit 1; }

installed=0; skipped=0; failed=0
for s in $SKILLS; do
  if [ -f "$HH/skills/$s/SKILL.md" ] \
     || ls "$HH"/skills/*/"$s"/SKILL.md >/dev/null 2>&1; then
    echo "skip:    $s (already installed)"
    skipped=$((skipped+1))
    continue
  fi
  echo "install: $s"
  out=$(hermes skills install --yes "$REPO_RAW/skills/$s/SKILL.md" 2>&1)
  echo "$out" | tail -n 6
  # the CLI exits 0 even when the security scan blocks the install —
  # verify the skill actually landed on disk
  if [ -f "$HH/skills/$s/SKILL.md" ] \
     || ls "$HH"/skills/*/"$s"/SKILL.md >/dev/null 2>&1; then
    installed=$((installed+1))
  else
    echo "FAILED:  $s (not installed — see scan output above)"
    failed=$((failed+1))
  fi
done

# expiry-desk ships a helper script the URL install doesn't carry — fetch it
# beside the skill and stage it where no_agent cron jobs can run it.
if { [ -f "$HH/skills/expiry-desk/SKILL.md" ] \
     || ls "$HH"/skills/*/expiry-desk/SKILL.md >/dev/null 2>&1; } \
   && [ ! -f "$HH/scripts/expiry-desk.py" ]; then
  mkdir -p "$HH/scripts"
  if curl -fsSL "$REPO_RAW/skills/expiry-desk/scripts/expiry-desk.py" \
       -o "$HH/scripts/expiry-desk.py"; then
    chmod +x "$HH/scripts/expiry-desk.py"
    echo "staged:  expiry-desk.py -> $HH/scripts/ (read it before scheduling)"
  else
    echo "WARNING: could not fetch expiry-desk.py — copy it manually"
  fi
fi

# Register the schedule of EVERY installed blueprint as a /suggestions entry.
# `hermes skills install` does this too, but upstream caps the pending
# backlog at 5 and silently drops the rest — and a re-run skips existing
# skills, so dropped ones would never be offered. This step tops the
# backlog up for the curated set only; suggestions already pending,
# accepted, or dismissed are left exactly as they are (dedup latch).
HPY="$(dirname "$(command -v hermes)")/python"
[ -x "$HPY" ] || HPY=python3
"$HPY" - "$HH" $SKILLS <<'PYEOF' 2>/dev/null || echo "note: could not top up suggestions (schedule manually if needed)"
import os, sys, pathlib
hh = pathlib.Path(sys.argv[1]); names = sys.argv[2:]
os.environ.setdefault("HERMES_HOME", str(hh))
try:
    import hermes_cli
    sys.path.insert(0, str(pathlib.Path(hermes_cli.__file__).resolve().parent.parent))
except Exception:
    sys.exit(1)
import cron.suggestions as cs
cs.MAX_PENDING = max(cs.MAX_PENDING, 24)
from tools.blueprints import parse_blueprint, register_blueprint_suggestion
n = 0
for name in names:
    for md in list(hh.glob(f"skills/{name}/SKILL.md")) + list(hh.glob(f"skills/*/{name}/SKILL.md")):
        spec = parse_blueprint(md.read_text(encoding="utf-8"))
        if spec is not None and register_blueprint_suggestion(spec):
            n += 1
        break
print(f"suggestions topped up: {n} newly registered")
PYEOF

echo
echo "Done: $installed installed, $skipped skipped, $failed failed."
[ "$installed" -gt 0 ] && echo "Run /suggestions in chat to schedule the new ones."
exit $failed
