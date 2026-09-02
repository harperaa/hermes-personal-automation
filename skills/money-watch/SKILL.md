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

## Procedure
1. Read the watchlist. For each row, fetch the page and extract the current price or availability.
2. Compare against the threshold according to `type`.
3. For `protect` rows, ignore the row entirely once the claim window has passed - and say so once, on the day it closes.
4. Report only rows that crossed. Include the current value, the threshold, and the direct link.
5. If nothing crossed, or every fetch failed, reply with ONLY `[SILENT]`.

## Pitfalls
- Create this job with continuity enabled (`hermes cron create ... --continuity`, or accept the suggestion and enable continuity when prompted) - without it, the job re-reports the same drop every four hours.
- A page that fails to load is not a price change. Stay silent, and only report a fetch that has failed repeatedly.
- Never place an order or follow a checkout link. Report and stop.
- Prices in the page may include or exclude delivery. Say which you read.

## Verification
A run with nothing to report sends nothing - confirm in `hermes cron list` that the run completed, and that a real threshold crossing (set one artificially low) produces exactly one alert.
