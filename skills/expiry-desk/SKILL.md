---
name: expiry-desk
description: Warn about every renewal and expiry in your life with enough lead time to shop around instead of auto-renewing. The scheduled check runs at zero cost - no model involved.
version: 1.1.0
author: Allen Harper
metadata:
  hermes:
    tags: [blueprint, admin, money, level-4, zero-cost]
    requires_toolsets: [terminal, file]
    config:
      - key: expiry_desk.renewals_path
        default: "~/life/renewals.csv"
        description: CSV of renewals (name,date,lead_days,note)
        prompt: CSV of renewals (name,date,lead_days,note)
    blueprint:
      schedule: "0 8 * * *"
      deliver: origin
      prompt: "Run ~/.hermes/scripts/expiry-desk.py with the terminal tool and relay its stdout VERBATIM. If stdout is empty, reply with ONLY [SILENT]. Do not add commentary and do not modify any file."
      no_agent: false
---

# Expiry Desk (Level 4)

## What this costs
**Nothing, on the recommended path.** The daily check is pure date arithmetic — no model needed. Hermes's blueprint format cannot yet attach a script to a `no_agent` job, so you have two ways to schedule it:

- **The $0 way (recommended)** — skip the suggestion and create the `no_agent` job yourself with the one-liner below. The scheduler runs `expiry-desk.py` directly, delivers its stdout verbatim, and never touches a model. Empty stdout means no message. Most days are empty.
- **The one-tap way** — accept the blueprint suggestion. A minimal agent turn runs the same script via the terminal tool and relays its output. Costs one tiny model call per day; behaves identically.

The only time an LLM genuinely helps is when *you* talk to it - "add my passport, expires June 2029" - and that's a normal chat turn, not a scheduled one.

## Setup - one command first, whichever path you pick
Cron scripts must live in `~/.hermes/scripts/`. Copy the one bundled with this skill:

```bash
cp ~/.hermes/skills/expiry-desk/scripts/expiry-desk.py ~/.hermes/scripts/
chmod +x ~/.hermes/scripts/expiry-desk.py
```

Then EITHER create the $0 job (and dismiss the blueprint suggestion):

```bash
hermes cron create "0 8 * * *" --no-agent --script expiry-desk.py --name "expiry-desk"
```

(add `--deliver telegram` if you use Telegram; the default delivers locally) — OR `/suggestions accept` for the one-tap agent-relay version.

## Inputs
`renewals_path` - a CSV with `name,date,lead_days,note`:

```csv
name,date,lead_days,note
Passport,2029-06-14,270,"6 months validity needed for most of Asia"
Car insurance,2027-03-11,21,"quotes cheapest ~3 weeks out - do not auto-renew"
Boiler service,2027-01-15,30,
Domain renewal,2027-02-02,14,"registrar auto-renews at list price"
```

`lead_days` is the whole design. A passport needs ~270 because renewal is slow and destination rules bite. Insurance needs ~21 because that is when quotes bottom out. A filter needs ~10 because you just have to order one.

## What the script does
1. Reads the CSV. If it is missing or unparseable, it prints a warning - a blind watchdog must not look like a quiet one.
2. For each row computes days remaining. Prints rows where `0 <= days <= lead_days`, soonest first, with the note verbatim.
3. Prints nothing otherwise, which suppresses delivery.

Read it before you schedule it. It is forty lines of stdlib Python with no network access and no credentials - the subprocess environment is sanitized, so it couldn't reach your provider keys even if it wanted to.

## Adding entries (this is where the agent helps)
When you mention something that expires or renews, the agent appends a row with a sensible lead time and confirms it back to you. Tell it once:

```
When I tell you about something that expires or renews, append it to
~/life/renewals.csv with a sensible lead time and confirm the row back to me.
```

## Pitfalls
- Never auto-renew anything, never follow a renewal link, never enter payment details. The job reports a date and stops - it has no ability to do anything else, which is part of the point.
- Do not let the agent "helpfully" extend a date it thinks has passed. Overdue is overdue.
- A `.py` script runs under the current Python interpreter. On Windows Git Bash, `.sh` scripts additionally need `bash` on `PATH`.

## Verification
Break the CSV path on purpose once and confirm you get a warning rather than silence. On the $0 path, check `hermes cron list` - the job should show **no model attached**; that's the zero-cost confirmation.
