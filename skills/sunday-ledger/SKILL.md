---
name: sunday-ledger
description: Assemble one page every Sunday from your renewals, commitments, purchases, and people vault - what is due, what you owe, what is expiring, and who to call.
version: 1.0.0
author: Allen Harper
metadata:
  hermes:
    tags: [blueprint, weekly, planning, level-10]
    requires_toolsets: [file]
    config:
      - key: sunday_ledger.vault_path
        default: "~/life"
        description: Vault root the ledger assembles from
        prompt: Vault root the ledger assembles from
    blueprint:
      schedule: "0 3 * * 0"
      deliver: origin
      prompt: "Assemble this week's Sunday ledger."
      no_agent: false
---

# Sunday Ledger (Level 10)

## When to Use
Overnight on Sunday, so the page is waiting Sunday morning. Deliver `local` and pair with a cheap formatting job that sends it.

## Inputs
- `vault_path/renewals.csv`
- `vault_path/ledger/commitments.md`
- `vault_path/purchases.md`
- `vault_path/people/`
- The last 7 days of sessions, via `session_search`

## Output Format
Write to `vault_path/ledger/YYYY-Www-sunday.md`. Omit any empty section:

```
DUE — anything dated in the next 14 days, soonest first.
OWED — commitments made to other people that are still open.
EXPIRING — renewals inside their lead window, with what to do about each.
WHO TO CALL — at most 3 people, with a one-line opening for each.
DECIDE — anything genuinely needing a decision this week.
```

## Procedure
1. Read every input. Note any that are missing rather than assuming they are empty.
2. Assemble the sections. **Every line must trace to a file you read** - never invent an item.
3. Hard limit: one page. If it does not fit, cut the least urgent item. Do not shrink the text to fit more in.
4. Then propose at most 3 updates to `MEMORY.md`. **List them for approval. Do not write them.**

## Pitfalls
- Automated memory writes at 3am with nobody watching is how an agent's model of you drifts somewhere you did not authorise. Pair this with `memory.write_approval: true`.
- Do not merge this with the daily standup. Daily is "what do I do today"; weekly is "what am I forgetting".
- Cost grows with the vault. Run this on a capable model at high reasoning effort, but only once a week.

## Verification
Every line cites the file it came from. The page fits on one screen.
