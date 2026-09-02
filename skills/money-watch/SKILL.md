---
name: money-watch
description: Watch prices, restocks, and bill changes, and stay completely silent unless there is money on the table.
version: 1.0.0
author: Allen Harper
metadata:
  hermes:
    tags: [blueprint, money, watcher, level-3]
    requires_toolsets: [web, file]
    config:
      - key: money_watch.watchlist_path
        default: "~/life/watchlist.md"
        description: Watchlist file (type | label | url | threshold | notes)
        prompt: Watchlist file (type | label | url | threshold | notes)
    blueprint:
      schedule: "0 */4 * * *"
      deliver: origin
      prompt: "Check the watchlist and report only items that crossed their threshold."
      no_agent: false
---

# Money Watch (Level 3)

## When to Use
Every few hours, to check things whose price or availability changes without warning.

## Inputs
`watchlist_path` - one item per line:

```
type | label | url | threshold | notes
price | Standing desk | https://... | 320 | current 399
protect | Headphones | https://... | 249 | bought 2026-08-20, claim window ends 2026-11-18
stock | Replacement filter | https://... | any | out since June
```

`type` is one of:
- `price` - alert when at or below threshold
- `protect` - price-protection window; alert if it drops below what was paid, while the claim window is open
- `stock` - alert when it becomes available

## Your memory between runs - the cron notepad
Your job's durable notepad is injected into every run; write to it with the
terminal tool: `hermes cron notepad <your job id> set <key> <value>`. Use it as
the single source of truth for what you already reported:

- `seen:<label>` - the last value you REPORTED for that row (price or stock
  state). Only report again when the current value differs.
- `closed:<label>` - set to `1` after announcing a protect window's close, so
  it is announced exactly once.

## Procedure
1. Read the watchlist AND your notepad. For each row, fetch the page and extract the current price or availability.
2. Compare against the threshold according to `type`.
3. For `protect` rows, ignore the row entirely once the claim window has passed - announce the close exactly once (check `closed:<label>` first, set it after).
4. Report only rows that crossed AND whose value differs from `seen:<label>`. Include the current value, the threshold, and the direct link - then update `seen:<label>`.
5. If nothing new crossed, or every fetch failed, reply with ONLY `[SILENT]`.

## Pitfalls
- The notepad is what stops this job re-reporting the same drop every four hours - never skip the `seen:` bookkeeping. (`--continuity` on the job adds the previous run's text too, but the notepad is the authoritative dedupe.)
- A page that fails to load is not a price change. Stay silent, and only report a fetch that has failed repeatedly.
- Never place an order or follow a checkout link. Report and stop.
- Prices in the page may include or exclude delivery. Say which you read.

## Verification
A run with nothing to report sends nothing - confirm in `hermes cron list` that the run completed, and that a real threshold crossing (set one artificially low) produces exactly one alert.
