---
name: morning-standup
description: Collect your commitments, renewals, and calendar overnight, then deliver a judgment - at most three things that matter today, with conflicts flagged.
version: 1.0.0
author: Allen Harper
metadata:
  hermes:
    tags: [blueprint, daily, planning, level-8]
    requires_toolsets: [file]
    config:
      - key: morning_standup.ledger_path
        default: "~/life/ledger"
        description: Directory the collector jobs write into
        prompt: Directory the collector jobs write into
    blueprint:
      schedule: "30 6 * * *"
      deliver: origin
      prompt: "Produce today's standup from the collected ledger files."
      no_agent: false
---

# Morning Standup (Level 8)

## When to Use
Early morning, after the collectors have run. This is the triage stage of a chain, not a standalone job.

## Inputs
Everything in `ledger_path`, typically written by earlier jobs:
- `today-calendar.md` - today's fixed commitments
- `commitments.md` - what the user owes, to whom, by when
- renewals inside their lead window
- anything else a collector dropped there

## Output Format
```
MUST DO — at most 3 items. If everything is a priority, nothing is.
CONFLICT — only if a commitment collides with a deadline. Name both.
LATER — a single line, not a list.
```

## Procedure
1. Read every file in `ledger_path`. Note which are stale - a collector may have failed.
2. Weigh items against each other rather than listing them. A deadline that can slip is not a MUST DO.
3. Cap MUST DO at three. Cutting is the job.
4. If today is genuinely quiet, say so in one sentence and stop.

## Pitfalls
- Stale inputs are the main failure mode. If a collector's output is from yesterday, say so rather than reporting old data as today's.
- Do not restate the calendar. The user can read their calendar; they cannot easily see what conflicts with what.
- Run this stage on a capable model at high reasoning effort, and the delivery stage on a cheap one. Judgment is the only part worth paying for.

## Verification
Someone reading only the MUST DO section should not be ambushed by anything before 6pm.
