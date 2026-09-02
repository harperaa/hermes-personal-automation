---
name: people-file
description: Keep dated notes on the people you care about, and get a weekly list of who to reach out to - birthdays with real lead time, and friends you have not spoken to in months.
version: 1.0.0
author: Allen Harper
metadata:
  hermes:
    tags: [blueprint, relationships, level-7]
    requires_toolsets: [file]
    config:
      - key: people_file.vault_path
        default: "~/life"
        description: Vault root containing people/
        prompt: Vault root containing people/
      - key: people_file.birthday_lead_days
        default: "21"
        description: Days of birthday lead time
        prompt: Days of birthday lead time
      - key: people_file.overdue_months
        default: "4"
        description: Months of silence before someone is overdue
        prompt: Months of silence before someone is overdue
    blueprint:
      schedule: "0 17 * * 0"
      deliver: origin
      prompt: "Give me this week's reach-out list."
      no_agent: false
---

# People File (Level 7)

## When to Use
Weekly for the reach-out list. Also whenever the user mentions seeing or speaking to someone.

## Inputs
`vault_path/people/` - one markdown file per person:

```markdown
---
name: Sam Okafor
birthday: 1988-04-19
last_contact: 2026-08-12
---

- 2026-08-12 — Called. New job at a logistics startup, starts Sept 1. Nervous about managing people.
- 2026-06-02 — Mentioned wanting a proper chef's knife. Owns none.
```

## Procedure — filing a note
1. Identify the person. If no file exists, create one from the template and say so.
2. Append one dated line. **Append only** - never edit or delete an existing line.
3. Update `last_contact` in the frontmatter.

## Procedure — the weekly list
Produce at most 8 items, omitting any empty section:

- **BIRTHDAYS** - anyone within `birthday_lead_days`. Include gift ideas recorded in their file, quoting the dated line they came from.
- **OVERDUE** - anyone whose `last_contact` is older than `overdue_months`. One line on what you last knew, so the user has an opening.
- **FOLLOW UP** - anything in a file that reads like a promise made, or something worth asking about: a job starting, a health scare, a trip.

## Pitfalls
- **Never invent a detail about a person.** If the file does not say it, do not write it. A confidently wrong fact about a friend is worse than an empty file.
- Do not summarise away the specifics. "Wants a chef's knife" is the useful part; "likes cooking" is not.
- Keep the vault to people the user genuinely keeps up with. Cost grows with vault size, and so does noise.

## Verification
Every line in the weekly list traces to a dated note. Twenty-one days of birthday lead is enough to act on a gift idea; seven is not.
