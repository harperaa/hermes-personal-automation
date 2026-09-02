---
name: return-desk
description: Track return windows, warranty periods, and free-trial conversions from a plain purchase ledger, and warn before each one lapses.
version: 1.0.0
author: Allen Harper
metadata:
  hermes:
    tags: [blueprint, money, admin, level-1]
    requires_toolsets: [file]
    config:
      ledger_path: "~/life/purchases.md"
    blueprint:
      schedule: "0 8 * * *"
      deliver: origin
      prompt: "Check the purchase ledger for anything lapsing soon."
      no_agent: false
---

# Return Desk (Level 1)

## When to Use
Whenever the user says they bought something, and once daily to check what is about to lapse.

## Inputs
`ledger_path` (default `~/life/purchases.md`) - a markdown table:

```markdown
| Item | Bought | Return window | Warranty | Notes |
|---|---|---|---|---|
| Wireless headphones | 2026-08-20 | 30 days | 2 years | John Lewis |
```

## Procedure — logging a purchase
1. Parse what the user told you: item, purchase date, return window, warranty, any trial period.
2. If a field is missing, ask once. Do not guess a return window - retailers differ wildly.
3. Append one row to the ledger. Never rewrite existing rows.
4. Confirm the computed dates back to the user before scheduling anything.

## Procedure — the daily check
1. Read the ledger. For each row compute: return deadline, warranty expiry, trial conversion date.
2. Report anything where the deadline is 3 days away or less (returns), 30 days or less (warranty), or 2 days or less (trials).
3. For each, say what lapses, on what date, and what the user's options are.
4. If nothing is inside a window, reply with ONLY `[SILENT]`.

## Pitfalls
- Return windows usually run from delivery, not purchase. If the user gives a delivery date, prefer it and note which you used.
- Never advise the user to return something. Report the deadline and let them decide.
- A row with an unparseable date should be reported as a data problem, not silently skipped.

## Verification
Every reported item traces to a row in the ledger, with the date arithmetic shown.
