# Hermes Personal Automation

**Eleven installable automations that hand your recurring life admin to an AI agent — safely.**

Each one is a [Hermes](https://hermes-agent.nousresearch.com) skill that declares a schedule, which makes it a **blueprint**: installable, inspectable, and shareable through the normal skills pipeline. Installing one never schedules anything. It registers a suggestion you confirm.

They are ordered as a curriculum. Each level introduces one new mechanism, and the projects feed each other — by the end you have one system, not eleven gadgets.

---

## The eleven

| Level | Skill | Runs | What it gives you back |
|---|---|---|---|
| 0 | [`secure-box-audit`](skills/secure-box-audit) | Monthly | The boundary everything else depends on |
| 1 | [`return-desk`](skills/return-desk) | Daily | No more missed returns, warranties, or trial renewals |
| 2 | [`out-the-door-brief`](skills/out-the-door-brief) | Weekdays | What to wear, take, and when to leave |
| 3 | [`money-watch`](skills/money-watch) | Every 4h | Price drops, restocks, price-protection claims |
| 4 | [`expiry-desk`](skills/expiry-desk) | Daily | Every renewal, with lead time to shop around. **$0 by default — no model** |
| 5 | [`quiet-inbox`](skills/quiet-inbox) | Every 20m | Mail triaged and drafted. Never sent |
| 6 | [`sunday-kitchen`](skills/sunday-kitchen) | Sundays | Five dinners from what's already in the fridge |
| 7 | [`people-file`](skills/people-file) | Sundays | Who to reach out to, with 21 days of birthday lead |
| 8 | [`morning-standup`](skills/morning-standup) | Daily | Three things that matter, conflicts flagged |
| 9 | [`boot-health-check`](skills/boot-health-check) | Daily | Which of the above broke overnight |
| 10 | [`sunday-ledger`](skills/sunday-ledger) | Sundays | One page: due, owed, expiring, who to call |

The full build guide — mechanisms, steps, verification, cost notes, GUI equivalents — is in [`workshop/`](workshop/).

---

## Install

**Start with Level 0.** Read [SECURITY.md](SECURITY.md) first. These skills schedule an autonomous agent against your personal data, and the boundary matters more than any individual automation.

**Way 1 — the skills pipeline (gets you the one-tap suggestion):**

```bash
hermes skills install https://raw.githubusercontent.com/harperaa/hermes-personal-automation/main/skills/expiry-desk/SKILL.md
```

Installing registers the schedule as a *suggestion* — nothing runs until you confirm:

```
/suggestions              # list pending
/suggestions accept 1     # create the job
/suggestions dismiss 1    # never offer it again
```

**Way 2 — clone and copy** (works everywhere, including a Railway container's chat terminal):

```bash
git clone https://github.com/harperaa/hermes-personal-automation.git
cp -r hermes-personal-automation/skills/expiry-desk ~/.hermes/skills/
```

A copied skill skips the suggestion flow, so schedule it explicitly — either ask the agent in chat ("schedule the expiry-desk skill exactly per its blueprint frontmatter") or run the one-liner yourself:

```bash
hermes cron create "0 8 * * *" "<the blueprint prompt from its SKILL.md>" \
  --name "blueprint:expiry-desk" --skill expiry-desk
```

**On Railway** (the AICVC template or any hosted hermes): your home is the attached volume, so `~/.hermes/skills/` persists across redeploys. Use the dashboard chat's terminal for the commands above.

### Timezones — read this once

Cron schedules run in the **server's** timezone. Railway containers run UTC, so `30 6 * * *` fires at 6:30 UTC — 2:30am US Eastern. Either set a `TZ` service variable (e.g. `TZ=America/New_York`) on your Railway service, or shift the hours in each blueprint before accepting.

Test any skill before scheduling it:

```bash
hermes chat --toolsets skills -q "Use the expiry-desk skill and tell me what's coming up"
```

---

## Two things that will save you a bad week

**Silence is the design.** Most of these produce nothing on most days. `money-watch` might speak three times a month. `expiry-desk` stays quiet for weeks. That is the intended behaviour — an assistant that messages you daily gets ignored, including on the day it matters. This is also why `boot-health-check` exists: a broken job and a quiet job look identical from your phone.

**Several skills need one data file you write once.** `expiry-desk` needs `renewals.csv`, `money-watch` needs `watchlist.md`, `sunday-kitchen` needs an inventory. Each `SKILL.md` shows the format. That first half hour is the only tedious part of the whole collection, and it is the one that pays.

Paths and preferences live in `metadata.hermes.config`, so you can point `vault_path` wherever you keep things without editing the skill. They resolve into `skills.config` and show up in `hermes config show`.

---

## Your data stays yours

`.gitignore` excludes `renewals.csv`, `purchases.md`, `watchlist.md`, `people/`, and anything under `life/` by default. If you fork this to keep your own configuration, those files will not follow you into a public repo by accident.

---

## Licence

MIT. See [LICENSE](LICENSE).

Built alongside a live workshop on personal AI automation. If you improve one of these, open a PR — particularly the lead times in `expiry-desk`, which vary by country.

---

## About

Built and taught by **Dr. Allen Harper** for the [AI Cyber Value Creators](https://www.skool.com/ai-cyber-value-creators) community, where these eleven levels are run as a hands-on workshop. MIT licensed — use them, fork them, teach with them.
