---
name: boot-health-check
description: On gateway startup, check whether any scheduled job failed overnight and whether the files your automations depend on are still there.
version: 1.0.0
author: Allen Harper
metadata:
  hermes:
    tags: [blueprint, ops, level-9]
    requires_toolsets: [terminal, file]
    blueprint:
      schedule: "0 7 * * *"
      deliver: origin
      prompt: "Run the health check and report only problems."
      no_agent: false
---

# Boot Health Check (Level 9)

## When to Use
Daily, and on gateway startup if you wire it to a `gateway:startup` hook.

## Why This Exists
A broken automation is indistinguishable from a quiet one. Every silence-by-default job in this collection has that property, which is exactly why one job has to check the others.

## Procedure
1. Run `hermes cron list`. Report any job that is paused unexpectedly or whose last run failed.
2. Run `hermes cron incidents`. Report unacknowledged incidents with their error signature.
3. Confirm the data files the automations depend on exist and parse:
   - `~/life/renewals.csv`
   - `~/life/purchases.md`
   - `~/life/watchlist.md`
   - `~/life/people/` (non-empty)
   Report any that are missing, empty, or unreadable.
4. Report the age of the most recent backup of `~/.hermes/` - unless running in a container/Railway (detect as in `secure-box-audit` Step 0), where host-side backups aren't visible: then note once "confirm volume backups are enabled" and move on.
5. If everything is healthy, reply with ONLY `[SILENT]`.

## Running it on startup
To fire this when the gateway boots rather than on a schedule, create `~/.hermes/hooks/boot-md/HOOK.yaml`:

```yaml
name: boot-md
description: Run the health check on gateway startup
events:
  - gateway:startup
```

In the accompanying `handler.py`, resolve the gateway model with `_resolve_gateway_model()` and credentials with `_resolve_runtime_agent_kwargs()` - a bare `AIAgent()` falls back to built-in defaults and will 401 against a custom endpoint. Spawn the agent on a background thread so startup is not blocked. Gateway hooks only fire in the gateway; the CLI does not load them.

## Pitfalls
- Report only. Do not restart, resume, or repair anything automatically.
- Do not acknowledge incidents on the user's behalf - acknowledging silences that error signature.

## Verification
Pause a job deliberately and confirm the next run reports it.
