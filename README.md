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

**Way 1 — the idempotent installer (recommended):**

```bash
git clone https://github.com/harperaa/hermes-personal-automation.git
cd hermes-personal-automation && bash install.sh          # everything missing
bash install.sh expiry-desk quiet-inbox                   # or just these
```

Safe to re-run any time: existing skills are skipped untouched, only missing ones install, and each new one registers its schedule as a `/suggestions` entry (already-dismissed suggestions stay dismissed — the dedup latch is upstream). It also stages `expiry-desk.py` into `~/.hermes/scripts/`.

**Way 1b — a single skill by URL:**

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

## Resetting or reinstalling a blueprint

A suggestion is offered once. Accepting it creates the cron job and marks the suggestion *accepted*; dismissing marks it *dismissed*. Neither is offered again on its own, so a reset is three steps:

```
/cron list                    # note the job id (blueprint:<name>)
/cron remove <job-id>         # delete the job; old run output stays in ~/.hermes/cron/output/
/suggestions clear            # forget the "accepted" record (dismissed ones are kept — that is your "no")
```

Nothing re-offers the blueprint until its schedule is registered again. Do one of these:

- **Hermes Plugins image (Railway):** redeploy the service — the boot seed re-registers every installed blueprint that is not pending, accepted or dismissed. Or run the seed by hand from the chat terminal:

  ```bash
  /opt/hermes/.venv/bin/python /opt/hermes-plugins-dist/personal_automation_seed.py
  ```

- **Self-hosted install:** re-run `install.sh` — it tops the `/suggestions` backlog up for every installed blueprint.

Then `/suggestions` lists it again and `/suggestions accept N` recreates the job. Fire it right away with `/cron run <new-id>` rather than waiting for its schedule.

**Want the latest SKILL.md too?** Installs never overwrite an existing skill folder. Delete it first, then re-run the seed or `install.sh`:

```bash
rm -rf ~/.hermes/skills/<name>
```

**Changed your mind about a dismissal?** Dismissed stays dismissed on purpose. Skip the suggestion and schedule the job directly — this is exactly what accept does under the hood (schedule and prompt are in each SKILL.md front matter):

```bash
hermes cron create "0 9 1 * *" "Run the monthly security audit and report only findings." \
  --name "blueprint:secure-box-audit" --skill secure-box-audit
```

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
