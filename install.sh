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
  if hermes skills install --yes "$REPO_RAW/skills/$s/SKILL.md"; then
    installed=$((installed+1))
  else
    echo "FAILED:  $s"
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

echo
echo "Done: $installed installed, $skipped skipped, $failed failed."
[ "$installed" -gt 0 ] && echo "Run /suggestions in chat to schedule the new ones."
exit $failed
