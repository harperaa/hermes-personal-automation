---
name: out-the-door-brief
description: A weekday morning message that gives decisions - what to wear, what to take, when to leave - instead of a weather report.
version: 1.0.0
author: Allen Harper
metadata:
  hermes:
    tags: [blueprint, daily, weather, level-2]
    requires_toolsets: [web]
    config:
      - key: out_the_door.city
        default: ""
        description: Your city, for the forecast
        prompt: Your city, for the forecast
      - key: out_the_door.travel_minutes
        default: "30"
        description: Minutes from door to first commitment
        prompt: Minutes from door to first commitment
      - key: out_the_door.calendar_path
        default: "~/life/ledger/today-calendar.md"
        description: Today's fixed commitments, one line (e.g. "09:00 team standup; 14:00 dentist")
        prompt: Today's calendar file
    blueprint:
      schedule: "45 6 * * 1-5"
      deliver: origin
      prompt: "Produce my out-the-door brief for today."
      no_agent: false
---

# Out-The-Door Brief (Level 2)

## When to Use
Weekday mornings, before the user is up.

## Setup
This skill needs your city. Set it once (Hermes stores it under `skills.config` in `config.yaml`; `hermes setup` also prompts for it):

```bash
hermes config set skills.config.out_the_door.city "Denver, CO"
hermes config set skills.config.out_the_door.travel_minutes 25
```

Without a city this skill cannot run - say so and show the command above rather than guessing a location.

## Output Format
Exactly these sections, in this order, under 80 words total:

```
WEAR — one line. Layers, coat, or neither.
TAKE — umbrella, sunglasses, gym kit. "Nothing extra" is a valid answer.
LEAVE BY — the time to walk out for the first commitment, allowing travel_minutes.
HEADS UP — at most one line, only if today genuinely differs from a normal day.
```

## Procedure
1. Get today's forecast for `city`. Look at the hours the user is actually outside, not the daily summary.
2. Convert the forecast into clothing and carry decisions. A 60% chance of rain at 3pm is "take the waterproof, rain from 3pm" - not a percentage.
3. Read `calendar_path` (default `~/life/ledger/today-calendar.md` — one line such as `09:00 team standup; 14:00 dentist`, the same file the morning standup reads). Find the first fixed commitment today. Subtract `travel_minutes` for LEAVE BY. If nothing before 10am, write "no fixed start".
4. Omit anything that isn't actionable.

## Pitfalls
- No news. No temperature dumps. No general forecast prose. Those are the failure modes this skill exists to avoid.
- If a section has nothing useful, write one short line saying so rather than padding it.
- Never invent a commitment. If `calendar_path` is missing or empty, say "no calendar file — add today's commitments to ~/life/ledger/today-calendar.md" in HEADS UP once, then stop mentioning it.

## Verification
Every line tells the user to do something or carry something. If a line is purely informational, it should not be there.
