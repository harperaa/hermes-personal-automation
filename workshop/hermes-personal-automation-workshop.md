# Automate Your Personal Life with Hermes
### A 10-Level Workshop

**From "it sent me a message" to "it runs my household while I sleep."**

---

## How This Workshop Works

Each level introduces **one new Hermes mechanism**. The difficulty comes from the machinery, not from writing longer prompts. If you skip a level, the next one won't make sense — Level 8 assumes you understand delivery targets from Level 2 and silence from Level 3.

Every level follows the same shape:

- **New mechanism** — the one thing you're actually learning
- **The build** — what you're making
- **Steps** — commands and chat prompts
- **Verification** — how you know it worked
- **Cost note** — what this spends per run
- **Failure mode** — what breaks first for most people

**Total time:** roughly 16–20 hours across all eleven, best spread over two to three weeks. Level 0 is an afternoon. Levels 1–4 are one evening. Levels 5 and 8–10 each deserve their own sitting.

### The six ideas underneath

The ten levels teach six concepts. Each concept spans one or two levels, and the order is built so that no idea arrives before the one it depends on:

| Concept | Levels | Projects | The shift |
|---|---|---|---|
| **Containment comes first** | 0 | The Box | Decide the blast radius before there's anything in it |
| **A process, not a tab** | 1–2 | The Return Desk · The Out-The-Door Brief | It runs whether or not you're looking at it |
| **Silence is the feature** | 3 | The Money Watch | Designing the null result is the hard part |
| **Most automation doesn't need a brain** | 4–5 | The Expiry Desk · The Quiet Inbox | Cheap thing decides, expensive thing thinks |
| **Procedures compound, prompts don't** | 6 | The Sunday Kitchen | Stop starting from zero every time |
| **Memory has layers** | 7 | The People File | "It forgot" is a routing problem, not a capacity one |
| **Small pieces, known blast radius** | 8–10 | The Morning Standup · The Household Share · The Sunday Ledger | Architecture, and what happens when it goes wrong |

If you're working through this alone, the concept boundaries are natural stopping points.

### The projects compound

These are not ten disconnected toys. Each one feeds the next, and by the end they're a single system:

```
The Box ─────────────► every later project inherits its blast radius
The Return Desk ─────► starts the purchase ledger the Sunday Ledger reads
The Out-The-Door ────► becomes the delivery stage of The Morning Standup
The Money Watch ─────► its cheapest watchers get rewritten as free ones
The Expiry Desk ─────► its script pattern becomes the gate in The Quiet Inbox
The Quiet Inbox ─────► extracts the commitments the Standup triages
The Sunday Kitchen ──► its shopping list becomes a Standup collector
The People File ─────► becomes the vault the Sunday Ledger reads from
The Morning Standup ─► the daily surface everything else reports through
The Household Share ─► makes any of the above installable by someone else
```

If a project doesn't end up wired into something later, that's a signal it wasn't worth building. Delete it rather than maintaining it.

---

## Before You Start

### Prerequisites

- **Level 0 completed.** It's the security and deployment groundwork, and it's genuinely a prerequisite rather than an optional appendix — see the note under house rule 1.
- Hermes installed and responding in text mode (`hermes` → type something → get a reply)
- The gateway installed as a service: `hermes gateway install`. **Cron only fires when the gateway is running.** In pure CLI mode, jobs only fire when you run `hermes cron` commands or have an active session.
- At least one messaging platform wired up. Telegram is the path of least resistance and most of this workshop assumes it.
- A machine that stays on. A cheap VPS, a Raspberry Pi, an old laptop, a Mac mini — anything that doesn't sleep.

### Your three GUI surfaces

Every level below ends with a **Doing it in the GUI** section. Three surfaces cover most of it, and it's worth knowing upfront which does what:

| Surface | Start it with | Covers |
|---|---|---|
| **Web dashboard** | `hermes dashboard` → `127.0.0.1:9119` | Config, API keys, MCP servers, pairing, webhooks, gateway, memory, credentials, sessions, logs, analytics, cron, skills |
| **Desktop app** | The desktop download | Bots roster, Bot Chat, routines, kanban, personalities, learning journey; connects to remote instances over SSH |
| **TUI** | `hermes --tui` | Chat with widgets and a status bar, when you're on a terminal but want more than plain CLI |

The dashboard needs the optional `web` extra installed. For a headless box, `hermes serve` runs a backend the Desktop app connects to remotely — that's the clean way to get a GUI on a VPS without exposing a web port.

**What has no GUI, deliberately:** event hooks, `SKILL.md` authoring, and cron scripts are all plain files. That's a design choice rather than a gap — these are the things that run code on your behalf, and the docs are explicit that you should be able to read exactly what they do. The CLI and the config files remain the source of truth; every GUI here is a view onto them.

### Three house rules

**1. Sandbox before you grant.** Do not give an agent your email, your files, and your shell on day one. Run Hermes on a box that isn't your daily driver, and let it reach anything sensitive through a narrow, scoped path. Add permissions one at a time, after each workflow is boringly reliable. **Level 0 is where you build that box** — skipping it doesn't save time, it just moves the cost to the day something goes wrong.

**2. Pin your models.** An unpinned cron job inherits your global default. Change your chat model and your whole fleet moves with it. Set a fleet default once:

```bash
hermes config set cron.model <cheap-model-name>
```

Then pin the handful of jobs that genuinely need reasoning. Hermes has a drift guard that fails a job closed if its unpinned model changes underneath it — that's a feature, not a bug.

**3. Cron prompts must be self-contained.** Every cron job runs in a completely fresh session with no memory of you, this conversation, or last run. "Check on that thing" fails. "Read `~/notes/inbox.md`, list any line starting with TODO, and reply with only `[SILENT]` if there are none" works.

---

---
# Level 0: Build the Box Before You Fill It

**Difficulty: ○○○○○○○○○○** — not hard, just non-negotiable

### New mechanism
Deployment isolation, the approval stack, gateway authorization, and write safety.

### The project: **The Box**

**Outcome:** An agent that lives somewhere other than your daily driver, can only reach what you chose to give it, and whose worst possible day is a rebuild rather than a breach.

Nothing in this level automates anything. It's the level that makes the other ten safe to attempt.

**Time it gives back:** None directly — this is the insurance policy on all ten hours the rest of the workshop saves you.

**You'll have built:**
- A host that isn't your primary machine, with Hermes running as a non-root service
- An explicit allowlist — the agent answers to you and nobody else
- A chosen execution boundary, deliberately, with the tradeoff understood
- A written note of what the agent can reach, and a restore you have actually tested

### Why this comes before Level 1

The Hermes docs are unusually honest about their own limits, and the sentence worth internalizing is this: the write guards apply to `write_file` and `patch` only. The `terminal` tool runs as the same OS user and can `cat` or overwrite those same paths with a shell command. The approval system is a guardrail against an honest-but-mistaken agent. **It is explicitly not a sandbox against a hostile one.**

So containment is a deployment decision, not a config toggle. And the threat isn't that the model turns evil — it's that somewhere between here and Level 10 the agent reads a web page, triages an email, or loads a community skill containing text written specifically to redirect it. Assume that happens. Design so that when it does, the damage stops somewhere you chose.

Retrofitting this later means a rebuild. By Level 5 you're pointing it at mail; by Level 10 there are several agents holding several sets of credentials.

### Steps

**Part 1 — Pick where it lives (45 min)**

| Option | Isolation | Persistence | Container backend? | Best for |
|---|---|---|---|---|
| **Your daily driver** | None | N/A | Yes | Nothing. Don't. |
| **Old laptop / Pi / mini PC** | Separate host, your LAN | Local disk | Yes | Anything touching home devices |
| **VPS** (Hetzner, DO, etc.) | Separate host, off-network | Local disk | Yes | The default recommendation |
| **Railway / container PaaS** | Managed container | Volume required | **No** | Lowest-friction start |

A cheap VPS is the sweet spot: disposable, off your home network, and it can run the Docker terminal backend. Community setups run comfortably in the $5–20/month range.

**If you go the home-hardware route,** don't port-forward. Use a mesh VPN (Tailscale is the common choice) and give the agent a *scoped tag* that reaches only the specific machine and port it needs — not your whole LAN.

**If you go Railway,** four specifics will save you an evening:

- **Attach a volume and mount it at your `HERMES_HOME` path.** Without it, every redeploy wipes your jobs, skills, memory, and session database. Volumes mount at *runtime* only — anything written during build does not persist. One volume per service.
- **`terminal.backend: docker` will not work.** Railway prohibits privileged containers and blocks Docker daemon access, so there's no nesting. Your isolation boundary *is* the Railway container — which is a real boundary, but it means the guardrails in Part 4 are doing more of the work, so leave them all on.
- **The official image runs as non-root (`hermes`, uid 10000).** Non-root images can hit permission errors on attached volumes; Railway's documented workaround is setting `RAILWAY_RUN_UID=0`. Reach for it only if you actually hit the error.
- **Redeploys restart the service.** Jobs on the volume survive; anything mid-run is marked `unknown` in the execution ledger and is not auto-retried.

**Part 2 — Lock the front door (30 min)**

Gateway authorization defaults to **deny**, which is the right default. Make it explicit rather than accidental — set allowlists in `~/.hermes/.env`:

```bash
TELEGRAM_ALLOWED_USERS=123456789
# or cross-platform:
GATEWAY_ALLOWED_USERS=123456789
```

Never set `GATEWAY_ALLOW_ALL_USERS=true`. For anyone you add later — a partner on the family bot at Level 9 — use pairing instead of hardcoding IDs:

```bash
hermes pairing list
hermes pairing approve telegram ABC12DEF
hermes pairing revoke telegram 123456789
```

Codes are 8 characters from an unambiguous alphabet, expire in an hour, rate-limited to one per user per ten minutes, with a lockout after five failed approvals. If you'd rather strangers get nothing at all:

```yaml
# ~/.hermes/config.yaml
unauthorized_dm_behavior: ignore   # default is `pair`
```

Then lock the secrets file:

```bash
chmod 600 ~/.hermes/.env
```

**Part 3 — Choose your execution boundary (40 min)**

| Backend | Isolation | Dangerous-command check | Notes |
|---|---|---|---|
| `local` | None — runs on host | Yes | Fine only if the host is already disposable |
| `ssh` | Separate machine | Yes | Gateway here, execution there |
| `docker` | Container | **Skipped** | The recommended production default |
| `modal` / `daytona` / `vercel_sandbox` | Cloud sandbox | **Skipped** | Managed isolation |

The counter-intuitive part: container backends **skip** the dangerous-command approval checks entirely, because the container *is* the boundary. That's not a weakening — a `rm -rf` inside a disposable container is a non-event, and it means you stop training yourself to click "approve" on prompts.

```yaml
# ~/.hermes/config.yaml
terminal:
  backend: docker
  docker_forward_env: []      # keep this empty — anything listed here is readable by code in the container
  container_cpu: 1
  container_memory: 5120
  container_persistent: false  # ephemeral: workspace on tmpfs, gone on cleanup
```

Hermes already hardens every container it starts — `--cap-drop ALL`, `no-new-privileges`, a pids limit, and size-capped tmpfs mounts. You don't need to add that yourself.

A useful split for the paranoid: run the **gateway** (holding your messaging tokens and model API keys) on one host and **execution** on another via `backend: ssh`, with the connection details in `.env` rather than `config.yaml` so they don't travel with a profile export. A prompt-injected agent then never has both the credentials and the shell.

**Part 4 — Set the guardrails you keep either way (30 min)**

```yaml
approvals:
  mode: smart            # auxiliary model triages; ambiguous cases escalate to you
  timeout: 300           # fail-closed — no answer means denied
  cron_mode: deny        # headless jobs cannot self-approve. Leave this alone.
  single_query_mode: deny
  deny:
    - "git push --force*"
    - "*curl*|*sh*"
```

`cron_mode: deny` is the one to never touch. Every job you build from Level 2 onward runs headless with nobody watching; `approve` would let an injected instruction auto-authorize itself at 3am.

`approvals.deny` is your editable floor — fnmatch globs, checked *before* `--yolo` and before `approvals.mode: off`. It's how you run permissively with specific permanent exceptions. Quote the patterns; a bare leading `*` is a YAML alias and won't parse.

Underneath all of it sits a hardline blocklist — filesystem-root wipes, fork bombs, zeroing a block device — refused regardless of `--yolo`, regardless of `mode: off`, regardless of you clicking "allow always". There is no override flag. Good design; don't go looking for a way around it.

Optionally constrain writes:

```bash
# list BOTH your workspace and Hermes home, or the agent can't manage its own state
export HERMES_WRITE_SAFE_ROOT=/home/you/vault:/home/you/.hermes
```

The classic mistake is pointing this at a project directory only, then wondering why the agent can't write skills or scripts. Note also that `~/.ssh/`, `~/.aws/`, `.env` files anywhere on disk, and Hermes' own credential stores are blocked regardless — pointing the safe root at `$HOME` does not unlock them.

And the obvious one: don't `/yolo` on a machine holding anything you'd miss.

**Part 5 — Network and egress policy (25 min)**

SSRF protection is on by default and blocks private ranges, loopback, link-local (including cloud metadata at `169.254.169.254`), and CGNAT space. Leave it that way:

```yaml
security:
  allow_private_urls: false     # default
  website_blocklist:
    enabled: true
    domains:
      - "*.internal.yourdomain.com"
      - "192.168.1.1"
  tirith_enabled: true          # content-level scanning: homograph URLs, pipe-to-shell
  tirith_fail_open: true        # set false to block commands when the scanner is unavailable
```

If you later need the agent to reach a LAN service — a local model endpoint, a home dashboard — `allow_private_urls: true` is the switch, and it is a genuine trust boundary. Turning it on means a prompt-injected URL can be fired at your home network. Prefer scoping the specific host over opening the whole category.

**Part 6 — Supply chain (25 min)**

You are about to install skills, and possibly MCP servers, written by strangers.

- **Skill trust levels** run `builtin` → `official` → `trusted` → `community`. Community skills are scanned for exfiltration patterns, injection attempts, and destructive commands; `dangerous` verdicts stay blocked. `--force` overrides non-dangerous findings — treat every use of it as a decision you'd defend.
- **Read what you install.** A `SKILL.md` is instructions your agent will follow. Skim it the way you'd skim a shell script from a forum.
- **MCP servers get a filtered environment** — only `PATH`, `HOME`, `USER`, locale, `TERM`, `SHELL`, `TMPDIR`, and `XDG_*` pass through. Put any token the server needs in its own `env:` block, never in the global environment.
- **Run `hermes doctor`.** It surfaces advisories for known-compromised package versions with remediation steps; `hermes doctor --ack <id>` dismisses one permanently once you've acted.
- On locked-down setups, `security.allow_lazy_installs: false` stops runtime `pip install` entirely.

**Part 7 — Backups and a restore you've actually run (25 min)**

Everything that matters lives in two places: `~/.hermes/` (jobs, skills, `MEMORY.md`, `state.db`, `.env`) and whatever vault you set up at Level 7. Back both up off-host, on a schedule.

Then do the part everyone skips: **restore it somewhere else and confirm it works.** "Worst day is a rebuild" is only true if you've done the rebuild once. An untested backup is a belief, not a control.

Also worth knowing before you need it: Hermes snapshots your working directory before making file changes, and `/rollback` restores it.

Finally, the boring hygiene:

```bash
hermes update            # security patches
tail -f ~/.hermes/logs/gateway.log   # watch for unauthorized access attempts
```

Never run the gateway as root.

### Doing it in the GUI

`hermes dashboard` starts a local web server and opens **http://127.0.0.1:9119**. It runs entirely on your machine — no data leaves localhost. It needs the `web` extra (FastAPI + Uvicorn); the embedded Chat tab additionally needs the `pty` extra.

| Task | Where |
|---|---|
| Approvals, terminal backend, security keys | **Configuration** — structured editor over `config.yaml`, plus a raw YAML view |
| Provider keys and credentials | **API Keys / Credentials** |
| Approve or revoke who can message the bot | **Messaging / Pairing** |
| Start, stop, restart, watch logs | **Gateway** |

**One caution that belongs in a security level:** the dashboard is itself an attack surface. A non-loopback bind always requires an auth provider — that guard is deliberate and was tightened after an earlier flag stopped disabling auth. Don't expose port 9119 to the internet. Reach it over your mesh VPN or an SSH tunnel (`ssh -L 9119:127.0.0.1:9119 you@yourbox`) and leave the bind on loopback.

If you're on the official Docker image, remember `docker exec` defaults to root — run pairing commands as `-u hermes` or the approval file gets written with the wrong ownership and is silently ignored.

## Confirm you have a push channel — before you rely on silence

Every skill in this collection delivers with `deliver: origin`: reports go to the chat where you accepted the suggestion, falling back to your configured home channel. On a clean run they send *nothing* (`[SILENT]`). That design only works if there is somewhere for the non-silent runs to land.

If you only ever talk to Hermes through the **dashboard chat** and never connect a messaging platform, there is no push channel — findings exist only in the dashboard's **Cron tab** run history, which nobody checks on a Tuesday. A broken boundary that reports into a tab you never open is indistinguishable from a healthy one. So, before Level 1:

1. **Connect one push platform** (Telegram is the usual choice) and set it as your home channel, **or** decide — explicitly, out loud — that checking the Cron tab is part of your weekly rhythm.
2. **Test it**: `hermes cron create "* * * * *" "Say exactly: delivery test OK" --name delivery-test`, wait a minute, confirm the message reaches your phone, then `hermes cron delete delivery-test`.
3. Accept suggestions **from the chat you want reports in** — that conversation becomes each job's origin.

### Verification
- [ ] Hermes is running on something that is not your primary machine
- [ ] A second account messaging your bot gets denied or a pairing code — test this yourself
- [ ] `~/.hermes/.env` is `chmod 600` and the gateway is not running as root
- [ ] You know which terminal backend you're on and why
- [ ] `approvals.cron_mode` is `deny`
- [ ] `hermes doctor` is clean or every advisory is consciously acknowledged
- [ ] You have restored from backup onto a different machine at least once
- [ ] A test cron message actually reached your phone (or you've committed to the Cron tab check)
- [ ] You can state in one paragraph what the agent can reach — write it down; you'll extend it at Level 10

### Cost note
Zero tokens. $5–20/month if you rent a box. The cheapest insurance in the whole workshop.

### Failure mode
Deciding this is overkill for a personal assistant and skipping to Level 1. It's a reasonable-feeling call right up until Level 5, when the same agent is reading your mail on a machine that also holds your SSH keys — and by then the fix is a rebuild rather than a config change.

The second failure mode is the opposite: spending a weekend on a threat model for an agent that tells you the weather. Part 1 plus Part 2 gets you 80% of the value in an hour. Do those now, and the rest before Level 5.

---

---

# Level 1: Teach It Who You Are, Then Give It a Deadline

**Difficulty: ●○○○○○○○○○**

### New mechanism
Persistent memory files (`SOUL.md`, `USER.md`, `MEMORY.md`) + one-shot cron.

### The project: **The Return Desk**

**Outcome:** You never again eat a missed return window, an expired warranty claim, or a free trial that quietly renewed at full price.

You tell it what you bought, in one sentence, whenever you buy something. It logs it and schedules the warnings — three days before a return window shuts, a month before a warranty expires, two days before a trial converts.

**Time it gives back:** One recovered return usually pays for the whole setup. Beyond that, it removes an entire category of low-grade mental tracking — the "when do I have to decide about that by" background hum.

**You'll have built:**
- `SOUL.md` with a persona you don't wince at
- `USER.md` carrying your name, timezone, and quiet hours
- `~/life/purchases.md` — a plain ledger of what you bought and what clock is running on it
- Scheduled one-shot jobs firing days or months out, visible in `hermes cron list`

### Why this is Level 1 and not throat-clearing
Every later level inherits this context. A morning brief written by an agent that doesn't know your timezone is a morning brief that arrives at 3am.

### Steps

**Part 1 — Set the persona (10 min)**

`SOUL.md` is the persona file, loaded first into the system prompt. Write who the agent should *be*, not what it should know:

```markdown
# Persona

You are my personal assistant. You are concise and direct.
You lead with the answer, then the reasoning if it's needed.
You don't apologize unless you actually got something wrong.
Before anything irreversible, you say what you're about to do and wait.
```

**Part 2 — Set your profile (10 min)**

`USER.md` (about 1,375 characters — deliberately small) is *you*. Just tell it in chat:

```
Remember: my name is [name], I'm in [timezone], I'm usually asleep
between 11pm and 6:30am, and I don't want to be messaged in that window
unless something is actually on fire. Save that to my user profile.
```

Verify with `hermes memory show`. Those quiet hours matter — a reminder that fires at 3am is a reminder you'll mute.

**Part 3 — Open the purchase ledger (15 min)**

Create `~/life/purchases.md` with a header row and nothing else:

```markdown
# Purchases with a clock running

| Item | Bought | Return window | Warranty | Notes |
|---|---|---|---|---|
```

Then, in chat:

```
Whenever I tell you I bought something, do two things:

1. Append a row to ~/life/purchases.md with what I told you.
2. Schedule one-shot reminders: 3 days before the return window closes,
   and 1 month before any warranty expires. Free trials: 2 days before
   they convert.

Each reminder should name the item, say what's about to lapse, and tell
me what my options are. Confirm the dates back to me before you schedule.
```

**Part 4 — Log something real, then fire a test (15 min)**

Give it an actual purchase from the last week:

```
I bought a [item] on [date]. 30-day returns, 2-year warranty.
```

Check `hermes cron list` — you should see the one-shots with their fire dates. Then prove the loop end to end without waiting a month:

```
/cron add "in 10m" "Remind me the return desk works, and tell me what time you think it is."
```

**Part 5 — Turn on memory approval if you're cautious (5 min)**

```yaml
# ~/.hermes/config.yaml
memory:
  write_approval: true
```

The agent then tells you what it *would* have saved and you decide.

### Doing it in the GUI

| Task | Where |
|---|---|
| Edit `SOUL.md`, `USER.md`, `MEMORY.md` by hand | Dashboard → **Memory** (MD Files) |
| Swap personality presets | Desktop → **Personalities**, or `/personality` in chat |
| Create the one-shot reminder | Dashboard → **Cron** → new job, schedule `in 10m` |
| Confirm it fired | Dashboard → **Cron** → job view, run history |

Editing the memory files directly in the dashboard is often better than asking the agent to remember something — you get exactly the wording you want, and you see the character budget you're spending.

### Verification
- [ ] The nudge arrived, roughly on time
- [ ] The time it reported matches your actual local time
- [ ] `hermes cron list` shows the job as consumed (one-shots run once)
- [ ] Your name appears when you start a fresh session

### Cost note
Two agent turns total. Pennies.

### Failure mode
The job never fires because the gateway isn't running. Run `hermes cron status`. If the scheduler isn't ticking, `hermes gateway install` then `hermes gateway restart`.

---

---

# Level 2: Decisions, Not Information

**Difficulty: ●●○○○○○○○○**

### New mechanism
Recurring schedules, delivery targets, and toolset trimming.

### The project: **The Out-The-Door Brief**

**Outcome:** One message before you're up that tells you what to wear, what to take, and when to leave. Not a weather report. Not a news roundup. Decisions.

**Time it gives back:** Ten minutes of phone-checking every morning, plus the days you'd have arrived soaked, without the gym kit, or eight minutes late.

The distinction matters more than it sounds. "High of 14°, 60% chance of rain" is information you still have to think about. "Take the waterproof, rain starts 3pm, leave by 8:10 for the 8:40" is a decision already made.

**You'll have built:**
- A recurring `out-the-door` job delivering to your phone on weekdays
- A cron toolset trimmed to what the job actually needs
- **A written-down cost per run** — this is the artifact people skip and regret

### Steps

**Part 1 — Write the job (20 min)**

The prompt has to carry everything, because the session is fresh. Note the shape: every line is an instruction to *you*, not a data point.

```bash
hermes cron create "weekdays at 6:45am" \
  "Produce my out-the-door brief for [your city]. Exactly these sections:

   WEAR — one line. Layers, coat, or neither. Name the reason only if it's
   not obvious (wind, a cold snap, rain arriving later).
   TAKE — umbrella, sunglasses, anything today's weather makes necessary.
   Say 'nothing extra' if that's the answer.
   LEAVE BY — the time I need to walk out for my first commitment, allowing
   [X] minutes travel. If nothing is scheduled before 10am, say 'no fixed start'.
   HEADS UP — at most one line, only if something today genuinely differs
   from a normal day.

   Rules: no general forecast, no temperature dumps, no news. If a section
   has nothing useful, write one short line saying so. Under 80 words total." \
  --deliver telegram \
  --name "out-the-door"
```

Resist the urge to add a news section. You have four other sources for news; you have none for "leave eight minutes earlier today."

**Part 2 — Trim the toolset (15 min)**

This is the part people skip and then wonder why a news summary costs real money. Every tool schema you carry rides along in *every* LLM call. A brief that fetches web pages does not need the browser, delegation, or terminal toolsets.

```bash
hermes tools
# select the "cron" platform, toggle off everything but web + file
```

Or scope it to just this job when you create it, via the `cronjob` tool's `enabled_toolsets` field:

```
enabled_toolsets=["web", "file"]
```

**Part 3 — Understand where output can go (10 min)**

The `--deliver` target is the whole delivery layer. Worth knowing before Level 8:

| Target | Meaning |
|---|---|
| `origin` | back to the chat where the job was created (messaging default) |
| `local` | files only, `~/.hermes/cron/output/` (CLI default) |
| `telegram` | your Telegram home channel |
| `telegram:<chat_id>` | a specific chat |
| `all` | every connected home channel, resolved at fire time |
| `telegram,discord` | an explicit set |
| `bot-chat` | into the agent's own chat, so it *processes* the output rather than posting it |

The agent's final response is delivered automatically. Don't write "then send it to me" in the prompt — that's the delivery layer's job, and telling the agent to do it makes it try to send the message twice.

**Part 4 — Make it continuable (10 min, optional)**

By default a cron delivery is fire-and-forget; reply to it and the agent has no idea what you're talking about. Set `attach_to_session: true` on the job (or `cron.mirror_delivery: true` globally) and the brief lands in a session you can reply into.

### Doing it in the GUI

| Task | Where |
|---|---|
| Create the recurring job, set schedule and delivery target | Dashboard → **Cron** → new job |
| Trim which toolsets cron jobs carry | Dashboard → **Tools** — enable/disable per platform, same thing `hermes tools` does in curses |
| Watch what it's costing | Dashboard → **Analytics** |

The Tools page is the clickable equivalent of the curses screen: pick the **cron** platform, untick everything the brief doesn't need. Do it here if the curses UI is awkward over SSH.

### Verification
- [ ] Brief arrives on schedule, weekdays only
- [ ] It's under 200 words and follows your section order
- [ ] `hermes cron runs out-the-door --limit 5` shows clean completions
- [ ] Cost per run is what you expected — check before you scale up

### Cost note
This is your baseline. Measure it. Every later level is a multiple of this number.

### Failure mode
The brief is 800 words of enthusiastic filler. Fix it in the prompt with hard limits and an explicit output shape, not by asking it to "be concise."

---

---

# Level 3: Watchers That Stay Quiet

**Difficulty: ●●●○○○○○○○**

### New mechanism
`[SILENT]` suppression — the difference between an assistant and a spam machine.

### The project: **The Money Watch**

**Outcome:** Three or four things you'd otherwise check manually now check themselves, and stay quiet until there's money on the table.

The strongest candidates, in rough order of payoff:

- **Price-protection windows.** Many card issuers and retailers refund the difference if something you bought drops in price within 30–90 days. Nobody claims this, because nobody re-checks. A watcher does.
- **A wishlist item crossing your threshold** — you buy at the right moment instead of the impatient one.
- **Restocks** on the thing that's been unavailable for months.
- **A bill or subscription changing price** — providers raise quietly and rely on you not noticing.

**Time it gives back:** Zero minutes of checking, replaced by three or four alerts a month that each carry a real decision.

**You'll have built:**
- Watchers running on `--continuity`, so they don't repeat themselves
- Both branches tested — silence verified, alert verified
- Audit files under `~/.hermes/cron/output/` proving the silent runs happened

### Why this is a step up
Level 2 always has something to say. Level 3 has to *decide*, and the discipline of designing for silence is what makes an assistant livable. Twenty jobs that message you daily is noise. Twenty jobs that message you three times a month is a superpower.

### Steps

**Part 1 — Build the watcher (30 min)**

```bash
hermes cron create "every 4h" \
  "Check the current price of [specific product] at [specific URL].

   If the price is at or below \$[threshold], reply with the price,
   the direct link, and how much it dropped.

   If it is above \$[threshold], or if the page fails to load,
   reply with ONLY the exact text [SILENT] and nothing else." \
  --deliver telegram \
  --name "price-watch" \
  --continuity
```

Two things doing work there:

`[SILENT]` — if the agent's final response contains that marker, delivery is suppressed entirely. The output is still written to `~/.hermes/cron/output/` for audit, so you can confirm it actually ran. Note that **failed** jobs always deliver regardless — you'll still hear about a broken watcher.

`--continuity` — the job sees its own previous output on each run. Without it, a recurring watcher has amnesia and re-reports the same drop every four hours. With it, it can dedupe against what it already told you.

**Part 2 — Test both branches (20 min)**

Don't wait four hours to find out it's broken. Force a run:

```bash
hermes cron run price-watch
```

Then temporarily edit the threshold to something absurd so the alert branch fires, confirm you get the message, and put it back:

```bash
hermes cron edit price-watch --prompt "..."
```

**Part 3 — Add two more (30 min)**

Three watchers, three different silence conditions. This is where the pattern actually sinks in.

### Doing it in the GUI

| Task | Where |
|---|---|
| Toggle continuity on a job | Dashboard → **Cron** → job editor → continuity toggle |
| Force a run without waiting | Dashboard → **Cron** → run now |
| Confirm a silent run actually happened | Dashboard → **Cron** → run history for that job |

The run-history view is the one that matters at this level. A silent watcher and a broken watcher look identical from your phone — the history tells you which one you have.

### Verification
- [ ] A run with nothing to report sends nothing
- [ ] That same run still wrote a file under `~/.hermes/cron/output/<job_id>/`
- [ ] The alert branch, when forced, delivers properly
- [ ] After the first alert, continuity stops it repeating the same news

### Cost note
Every silent tick still costs a full agent turn. Three watchers at every-4h is 18 LLM calls a day for, most days, zero messages. Level 4 fixes exactly this.

### Failure mode
The agent replies "Everything looks fine, nothing to report! [SILENT]" — and because the marker is present, you get nothing, which is correct. But the reverse also happens: it explains at length *why* it's staying silent and forgets the marker. Say "reply with ONLY the exact text [SILENT] and nothing else."

---

---

# Level 4: Every Renewal, For Nothing

**Difficulty: ●●●●○○○○○○**

### New mechanism
`no_agent` script-only cron jobs — a schedule with zero LLM involvement.

### The project: **The Expiry Desk**

**Outcome:** Every renewable and expiring thing in your life warns you with enough lead time to *act* rather than panic — or worse, auto-renew.

Passport and driving licence. Car insurance, tax, and service. Home and contents insurance. Boiler service. Smoke alarm batteries. Water filters. Professional registrations. The domain you forgot you own.

**Time it gives back:** Hours a year of last-minute admin, and real money — insurance quotes are cheapest around three weeks out, and auto-renewal is consistently the most expensive option available.

The lead time is the entire point. "Your passport expired" is useless. "Your passport expires in nine months, and several countries require six months' validity" is actionable.

**You'll have built:**
- `~/life/renewals.csv` — one line per thing, with its own lead time
- A $0 script doing pure date maths, speaking only inside a lead window
- A `--no-agent` job costing exactly nothing per run, forever
- A deliberately broken script, proving a dead watchdog still alerts you

### Why this is the level most people skip
This is the single biggest cost lever in Hermes and it's easy to miss. If the message content is *fully determined* by the check, an LLM adds nothing but latency and expense. The scheduler runs your script, delivers stdout verbatim, and never touches the inference layer.

**Empty stdout means no delivery.** That's the entire watchdog pattern in one sentence.

### Steps

**Part 1 — Write down everything with a clock on it (20 min)**

This part is manual and it's the only genuinely tedious half hour in the workshop. It's also the one that pays. Create `~/life/renewals.csv`:

```csv
name,date,lead_days,note
Passport,2029-06-14,270,"6 months validity needed for most of Asia"
Driving licence,2031-02-02,60,
Car insurance,2027-03-11,21,"quotes cheapest ~3 weeks out - do not auto-renew"
Car tax,2027-01-31,30,
Car service,2026-11-20,21,"book early, garage runs 2 weeks out"
Home insurance,2027-05-02,21,"do not auto-renew"
Boiler service,2027-01-15,30,
Smoke alarm batteries,2027-03-01,14,
Water filter,2026-12-01,10,
```

The `lead_days` column is the whole design. A passport needs nine months because renewal is slow and destination rules bite. Insurance needs about three weeks because that's when quotes bottom out. A water filter needs ten days because you just have to order one.

**Part 2 — Write the $0 script (30 min)**

Pure date maths. No model, no tokens, no reasoning required — which is exactly why this belongs at Level 4.

Scripts must live in `~/.hermes/scripts/`; paths that escape the directory are rejected. The subprocess environment is sanitized, so your provider keys are **not** inherited.

```python
#!/usr/bin/env python
# ~/.hermes/scripts/expiry-desk.py
import csv, os
from datetime import date, datetime

path = os.path.expanduser("~/life/renewals.csv")
today = date.today()
due = []

try:
    with open(path) as f:
        for row in csv.DictReader(f):
            if not row.get("date"):
                continue
            when = datetime.strptime(row["date"].strip(), "%Y-%m-%d").date()
            lead = int(row.get("lead_days") or 30)
            days = (when - today).days
            if 0 <= days <= lead:
                due.append((days, row["name"], when, row.get("note", "")))
except FileNotFoundError:
    print(f"WARNING: {path} is missing - the expiry desk is blind.")
    raise SystemExit(0)

if not due:
    raise SystemExit(0)          # empty stdout = no delivery. This is the point.

due.sort()
print("Coming up:")
for days, name, when, note in due:
    line = f"- {name}: {when:%d %b %Y} ({days} days)"
    if note:
        line += f" - {note}"
    print(line)
```

**Part 3 — Register it (10 min)**

If you installed the `expiry-desk` blueprint: copy the script into `~/.hermes/scripts/` first. The blueprint format cannot attach a script to a `no_agent` job, so the suggestion schedules a minimal agent turn that relays the script's output — accept it with `/suggestions accept`, or dismiss it and create the true $0 `no_agent` job yourself (recommended):

```bash
chmod +x ~/.hermes/scripts/expiry-desk.py

hermes cron create "every day at 08:00" \
  --no-agent \
  --script expiry-desk.py \
  --deliver telegram \
  --name "expiry-desk"
```

Daily is fine — it costs nothing and stays silent almost every day. Note the missing-file branch speaks up rather than exiting quietly: a watchdog that has gone blind must say so.

**Part 4 — Let the agent maintain it (20 min)**

You don't want to hand-edit a CSV forever. In chat:

```
When I tell you about something that expires or renews, append it to
~/life/renewals.csv with a sensible lead time and confirm the row back to me.
```

Then feed it a few: *"my home insurance renews on the 2nd of May, don't let it auto-renew"*.

**Part 5 — Add a second $0 watchdog, then break it (20 min)**

Pick one that suits your life — a backup that's gone stale, a disk filling, a domain expiring. The `cronjob` tool exposes `no_agent` directly, so you can just ask:

```
Ping me on Telegram if my home disk goes above 85% full. Check every 15 minutes.
```

Read the script it wrote before you trust it. Then deliberately break one — bad path, syntax error — and confirm you get an error alert. A watchdog that fails silently is worse than no watchdog.

### Doing it in the GUI

| Task | Where |
|---|---|
| Attach the script and flip off the agent | Dashboard → **Cron** → job editor → script field + no-agent option |
| Spot a job that stopped auto-firing | Dashboard → **Cron** → job view shows `last_fire_error` |

The script itself is a file — write it in your own editor (or let the agent write it and then *read it* before scheduling). The GUI is for wiring it up, not authoring it. Some community dashboards add a file browser for `HERMES_HOME` if you want that in the browser too.

### Verification
- [ ] `hermes cron list` shows the jobs with no model attached
- [ ] Silent days produce no message
- [ ] Alert conditions do produce a message
- [ ] Breaking the script on purpose produces an error alert — a broken watchdog must not fail silently

### Cost note
Zero. No tokens, no model, no provider. This is the point.

### Failure mode
On Windows Git Bash, `.sh` files need `bash` on `PATH`. Anything that isn't `.sh`/`.bash` runs under the current Python interpreter — so a `.py` gate works fine, but a `.js` file won't do what you expect.

---

---

# Level 5: Gate the Expensive Thinking

**Difficulty: ●●●●●○○○○○**

### New mechanism
The `wakeAgent` pre-run gate — a $0 script that decides whether the LLM runs at all.

### The project: **The Quiet Inbox**

**Outcome:** Mail gets read, classified, and drafted against while you're doing something else — and costs nothing on the days nothing arrives. Nothing is ever sent without you.

It also pulls out the thing inboxes hide worst: **the commitments**. Anything you promised, anything someone's waiting on, anything with a date attached, lifted into a file you can actually see.

**Time it gives back:** The heaviest single win in the workshop. Triage is most people's largest recurring time cost, and a good draft takes ten seconds to approve versus ten minutes to compose.

**You'll have built:**
- A gate script that fails closed to `wakeAgent: false`
- A dedicated agent mail account with forwarding rules set at the source
- `~/life/drafts/` filling with replies you review and send yourself
- `~/life/ledger/commitments.md` — what you owe, to whom, by when
- A usage graph that is **flat** on quiet days

### Why this sits right here
Level 4 proved a schedule doesn't need a brain. This is the other half of the same idea: when the job *does* need a brain, a script can still decide whether to wake it. Cheap thing decides, expensive thing thinks.

It's also the first level where you grant access to something genuinely sensitive, which is why the blast-radius work comes before the automation work. If you'd rather not point an agent at your mail yet, do Part 1 and stop there. The mechanism is identical whether it's guarding an inbox or a folder.

### Steps

**Part 1 — Learn the gate on something harmless (30 min)**

Build the mechanism before you point it at anything you care about. If your cron job attaches a pre-check script, that script can decide at runtime whether Hermes invokes the agent at all — emit a final stdout line of `{"wakeAgent": false}` and the tick is skipped entirely. No tokens, no model, no provider.

Three shapes cover most cases:

- **File-change gate** — compare a watched file's mtime against a stored timestamp; skip if unchanged
- **External-flag gate** — some other process drops `/tmp/ready`; the script consumes and deletes it
- **Row-count gate** — query *your own* database for new rows, pass the count through as context

One caution: don't point a gate at `~/.hermes/state.db`. That's an internal schema that changes between releases. Query your own data.

**Part 2 — Design the blast radius before you touch mail (30 min)**

Before wiring email in, decide what the agent is *never* allowed to see. The pattern that holds up in practice: give the agent its **own** dedicated mail account, and forward only the categories you want automated into it. Your primary inbox — with its 2FA codes, password resets, and banking notifications — stays out of reach entirely. If the agent is ever compromised, those were never within its blast radius.

Set up saved searches and filters at the source, so the filtering happens before the agent, not after.

**Part 3 — Write the mail gate (40 min)**

```python
#!/usr/bin/env python
# ~/.hermes/scripts/mail-gate.py
import json, sys, subprocess

# Replace with your own count command — an IMAP CLI, an API call, whatever.
try:
    out = subprocess.run(
        ["your-mail-cli", "count", "--unread"],
        capture_output=True, text=True, timeout=30
    )
    n = int(out.stdout.strip() or 0)
except Exception:
    print(json.dumps({"wakeAgent": False}))
    sys.exit(0)

if n < 1:
    print(json.dumps({"wakeAgent": False}))       # skip this tick entirely
else:
    print(json.dumps({"wakeAgent": True, "context": {"unread": n}}))
```

The script's stdout is injected into the prompt as context, and the final line's `wakeAgent` decides whether the agent runs. Omit it and the default is `true`.

```bash
hermes cron create "every 20m" \
  "New mail has arrived. For each unread message: summarize it in one line
   and classify it as ACTION / FYI / IGNORE.

   Draft replies for anything marked ACTION and save them to
   ~/life/drafts/ — do NOT send anything.

   If everything is IGNORE, reply with ONLY [SILENT]." \
  --script mail-gate.py \
  --deliver telegram \
  --name "inbox-triage"
```

**Part 4 — Keep the human gate (20 min)**

Drafts, never sends. This is a rule, not a preference. Read the drafts for a full week before you even consider changing it — and honestly, most people never do, because reviewing a good draft takes ten seconds and un-sending a bad one takes an apology.

### Doing it in the GUI

| Task | Where |
|---|---|
| Attach the gate script to the job | Dashboard → **Cron** → job editor → script field |
| Prove the gate is working | Dashboard → **Analytics** — spend should be flat on idle days |
| Restrict what this job can reach | Dashboard → **Tools** → per-platform toolsets |

Analytics is the verification surface for this level. "It didn't cost anything" is a claim you can actually check on a graph rather than assume.

### Verification
- [ ] An idle inbox produces zero LLM calls — confirm in your usage dashboard, not by assumption
- [ ] New mail wakes the agent within one interval
- [ ] Drafts appear on disk; nothing is ever sent
- [ ] Your primary inbox's sensitive categories genuinely never reach the agent — test this deliberately

### Cost note
This is where the economics flip. A 20-minute poll is 72 ticks a day. Ungated, that's 72 agent turns for maybe six useful ones. Gated, you pay for six.

### Failure mode
The gate throws an exception and — depending on how you wrote it — either wakes the agent every tick or never wakes it again. Fail closed to `wakeAgent: false` on error like the script above, and pair it with a `no_agent` watchdog that tells you if the gate itself has been silent for too long.

---

---

# Level 6: Turn a Chore Into a Skill

**Difficulty: ●●●●●●○○○○**

### New mechanism
Authoring a `SKILL.md` and attaching it to a cron job.

### The project: **The Sunday Kitchen**

**Outcome:** Sunday morning you get five dinners built around what's already in the fridge and closest to expiring, plus a shopping list covering only the gap.

**Time it gives back:** The 40 minutes of Sunday planning, the midweek "what do we even have" stall, and the food you'd otherwise throw away — which for most households is a meaningful monthly number.

Swap the domain if meals aren't your friction point: a packing list that accounts for destination weather and trip length, a training log that connects soreness to sleep, a plant-watering schedule that knows which pots dry out fastest. The mechanism is identical; pick the chore you actually repeat.

**You'll have built:**
- `~/.hermes/skills/meal-planner/SKILL.md` with inputs, hard constraints, and a verification condition
- `inventory.md` and `preferences.md` as the skill's data layer
- A `weekly-meals` job that improves whenever you edit the skill, never the job

### Why skills, not longer prompts
A cron prompt is a one-off. A skill is versioned, testable, loadable by several jobs, shareable, and — crucially — kept *out* of your context until it's needed. Progressive disclosure is the whole design.

### Steps

**Part 1 — Do it manually three times (30 min)**

Run the workflow by hand in chat. Notice where it goes wrong, what you had to correct, what context it kept missing. You cannot write a good skill for a workflow you haven't run.

**Part 2 — Write the skill (45 min)**

Create `~/.hermes/skills/meal-planner/SKILL.md`:

```markdown
---
name: meal-planner
description: Plans a week of dinners from current fridge and pantry inventory, prioritizing items closest to expiry.
version: 1.0.0
author: [you]
metadata:
  hermes:
    tags: [Personal, Food, Planning]
    requires_toolsets: [file]
---

# Meal Planner

## When to Use
When asked to plan meals, decide dinner, or produce a shopping list.

## Inputs
- Inventory file: `~/life/kitchen/inventory.md` (one item per line, `item — qty — expiry`)
- Household preferences: `~/life/kitchen/preferences.md` (dislikes, dietary constraints, rotation rules)

## Procedure
1. Read both files. If inventory is missing or empty, say so and stop — do not invent contents.
2. Sort inventory by expiry date, soonest first.
3. Propose 5 dinners. Each must use at least two items from the top third of that sorted list.
4. Respect every constraint in preferences.md without exception.
5. Produce a shopping list of only what the 5 dinners need beyond current inventory.
6. Cap each recipe description at 2 sentences.

## Pitfalls
- Do not repeat a main protein more than twice in one week.
- Do not suggest anything requiring equipment not listed in preferences.md.
- If two constraints conflict, say which and ask — do not silently pick one.

## Verification
Every proposed dinner traces to at least two named inventory items.
```

**Part 3 — Test it in isolation (20 min)**

```bash
hermes chat --toolsets skills -q "Use the meal-planner skill to plan this week"
```

Iterate on the SKILL.md until the output is right *before* you schedule it.

**Part 4 — Attach it to a schedule (15 min)**

```bash
hermes cron create "every sunday at 10am" \
  "Plan the coming week's dinners and give me the shopping list." \
  --skill meal-planner \
  --deliver telegram \
  --name "weekly-meals"
```

The prompt becomes a thin task instruction layered on top of the skill. You can attach several skills to one job — they load in order.

### Doing it in the GUI

| Task | Where |
|---|---|
| See installed skills, inspect their content | Dashboard → **Skills** |
| Browse and install community skills | Dashboard → **Skills** → marketplace / browse |
| Attach a skill to a scheduled job | Dashboard → **Cron** → job editor → skill selector |

Authoring a `SKILL.md` stays in your text editor — that's a writing task, not a form. But the Skills page is the fastest way to confirm Hermes actually picked up your new skill, and to read a community skill's full text *before* you install it.

### Verification
- [ ] The skill works when invoked manually
- [ ] The scheduled job produces the same quality as the manual run
- [ ] Editing `SKILL.md` changes behaviour on the next run, without touching the cron job
- [ ] Missing inventory file produces a clean refusal, not invented groceries

### Cost note
Slightly *cheaper* than an equivalent giant cron prompt — the skill only loads when relevant, and the prompt stays small.

### Failure mode
You write the skill as a wish list instead of a procedure. "Plan good meals" is not a skill. Numbered steps with explicit inputs, hard constraints, and a verification condition is.

---

---

# Level 7: The People You Keep Forgetting

**Difficulty: ●●●●●●●○○○**

### New mechanism
`--workdir`, durable file-based memory, and end-of-day capture.

### The project: **The People File**

**Outcome:** You stop being the person who forgets. Birthdays arrive with enough lead time to actually buy something. The friend you meant to call three months ago surfaces before it becomes embarrassing. And when you do call, you remember what you last talked about.

**Time it gives back:** Kills the annual birthday scramble and the "I should really message them" loop that costs more attention unresolved than it would to just do. Gift ideas get captured when you hear them, in June, instead of invented under pressure in December.

**You'll have built:**
- `~/life/people/` — one file per person, with dated notes appended over time
- `AGENTS.md` at the vault root, so every job with that workdir inherits your conventions
- A Capture channel you dictate into after seeing someone
- A Sunday job that produces one short list: who to reach out to this week, and why

### Why this matters
`MEMORY.md` caps around 2,200 characters and `USER.md` around 1,375. They're for facts that must *always* be in context. They are not a journal, a project log, or a life archive. The pattern that scales is: bounded memory files for critical facts, a vault on disk for everything else, and `session_search` over `~/.hermes/state.db` for "did we discuss this in March?"

### Steps

**Part 1 — Set up the vault and the workdir (30 min)**

Cron jobs run detached by default — no context files, working directory wherever the gateway started. Point them at a vault instead.

Create `~/life/people/` with one file per person you actually want to keep up with. Start with fifteen, not two hundred:

```markdown
---
name: Sam Okafor
birthday: 1988-04-19
met: university, 2009
last_contact: 2026-08-12
---

# Sam

- 2026-08-12 — Called. New job at a logistics startup, started Sept 1.
  Nervous about managing people for the first time.
- 2026-06-02 — Mentioned wanting a proper chef's knife. Owns none.
- 2026-03-30 — Dad's health scare. Ask.
```

Then an `AGENTS.md` at the vault root so every job with this workdir inherits the conventions:

```markdown
# Vault conventions

- One file per person in ./people/, named firstname-lastname.md
- Notes are APPEND ONLY. Never edit or delete an existing dated line.
- Every note starts with an ISO date and a dash.
- Update the `last_contact` frontmatter field when a contact is logged.
- Never invent a fact about a person. If unsure, write what was said verbatim.
```

That last rule matters more than it looks. This vault is about people you care about; a confidently hallucinated detail is worse than a blank file.

**Part 2 — A capture path (25 min)**

Create a Telegram topic or Discord channel called `Capture`. After you see someone or get off a call, dictate a messy line into it — *"coffee with Sam, new job starts Sept, wants a chef's knife"*.

Then a nightly job to file it properly:

```bash
hermes cron create "every day at 21:30" \
  "Read today's messages from the Capture channel. For each person mentioned,
   append a dated line to their file in ./people/ and update last_contact.
   If a person has no file yet, create one from the template and tell me.
   Append only - never modify an existing line. If nothing was captured
   today, reply with ONLY [SILENT]." \
  --workdir /home/[you]/life \
  --deliver telegram \
  --name "capture-filing"
```

With `--workdir` set, `AGENTS.md` is injected into the system prompt and all file tools work from there. One constraint: jobs with a `workdir` run **sequentially** on the scheduler tick rather than in the parallel pool.

**Part 3 — The Sunday reach-out list (30 min)**

This is the payoff — the part that saves the time.

```bash
hermes cron create "every sunday at 17:00" \
  "Read every file in ./people/. Produce one short list, nothing else:

   BIRTHDAYS — anyone with a birthday in the next 21 days. Include any gift
   ideas recorded in their file, quoting the dated line it came from.
   OVERDUE — anyone whose last_contact is more than 4 months ago. One line
   each on what you last knew about them, so I have an opening.
   FOLLOW UP — anything in a file that reads like something I said I'd do,
   or something worth asking about (a job starting, a health scare, a trip).

   Maximum 8 items total. If a section is empty, omit it entirely.
   Never invent a detail - if a file doesn't say it, don't write it." \
  --workdir /home/[you]/life \
  --deliver telegram \
  --name "reach-out"
```

Twenty-one days of birthday lead is deliberate. Seven days is a panic-bought gift card; three weeks is enough to act on the chef's knife you wrote down in June.

**Part 4 — Teach it to search its own past (15 min)**

Ask things like *"when did Sam mention the new job?"* and watch it use `session_search` against the SQLite FTS5 index rather than guessing. Every CLI and messaging session is in there — which means conversations you had before you built the vault are still findable.

### Doing it in the GUI

| Task | Where |
|---|---|
| Edit or prune memory entries | Dashboard → **Memory** |
| Review what the agent has learned over time | `/journey` in chat, or the Desktop learning-journey panel |
| Read and link your notes | **Obsidian itself** — that's the real GUI at this level |

The journey panel is a timeline of saved skills and memory entries with edit and delete on individual nodes. Worth opening monthly: it's where you catch a wrong assumption the agent saved about you weeks ago and has been quietly acting on since.

### Verification
- [ ] Journal entries appear in the vault with correct dates and structure
- [ ] Wiki-links resolve inside Obsidian
- [ ] The weekly review cites actual entries rather than inventing a nice narrative
- [ ] `session_search` surfaces a real conversation from weeks back

### Cost note
The nightly filing job is the one to watch — it only wakes when you actually captured something, so most days it is near-free. The Sunday reach-out job reads every file in the vault, so its cost grows with the vault; keep it to people you genuinely keep up with rather than every contact you own.

### Failure mode
The agent rewrites your notes instead of appending, or hallucinates `[[links]]` to notes that don't exist. Both are prompt problems: say "append only, never modify existing content" and "only link to files that exist in ./notes — verify before linking."

---

---

# Level 8: Chain Jobs Into a Pipeline

**Difficulty: ●●●●●●●●○○**

### New mechanism
`context_from` — one job's most recent output injected as context into the next.

### The project: **The Morning Standup**

**Outcome:** This retires your Level 2 brief. Instead of *information* about your day, you get a *judgment*: at most three things that genuinely matter, with any conflict between a commitment and a deadline flagged before you hit it.

It's the assembly point for everything you've built. The Expiry Desk's warnings, the commitments the Quiet Inbox extracted, the reach-outs from the People File, and today's actual calendar — collected, weighed against each other, and cut down to what you can hold in your head.

**Time it gives back:** Replaces the 20-minute morning triage where you scan four surfaces and try to hold the whole day at once.

**You'll have built:**
- Two or more collectors writing to `~/life/ledger/`, delivering `local`
- A triage job pinned to a capable model at `high` reasoning effort
- A delivery job pinned to a cheap one
- A chain wired with `context_from`, staged minutes apart

When it's running well, pause `out-the-door`. Two daily messages competing for the same attention is how people start ignoring both.

### Why chaining beats one giant job
A single job that gathers, judges, and formats does all three badly and costs the most expensive model's rate for the gathering. Split it: collection runs cheap or scriptless, triage runs on a good model at high reasoning effort, delivery runs cheap again. You can also debug each stage in isolation and reuse a collector across multiple pipelines.

### Steps

**Part 1 — Build the collectors (40 min)**

Two or three cheap jobs, each writing a section of a daily ledger. All deliver `local` — nobody needs to see raw data:

```bash
hermes cron create "every day at 06:00" \
  "Check [your calendar source] for today's commitments and write them to
   ~/life/ledger/today-calendar.md as a plain list with times." \
  --deliver local --name "collect-calendar"

hermes cron create "every day at 06:05" \
  "Read ~/life/ledger/errands.md and ~/life/ledger/bills.md. Write anything
   due in the next 7 days to ~/life/ledger/today-due.md, sorted by date." \
  --deliver local --name "collect-due"
```

**Part 2 — The triage job (40 min)**

This one gets the good model and the reasoning budget, and it consumes the collectors' outputs by name:

```bash
hermes cron create "every day at 06:15" \
  "Using the collected data above, produce today's priorities.

   Rules:
   - At most 3 items in MUST DO. If everything is a priority, nothing is.
   - Flag any conflict between calendar commitments and deadlines.
   - Anything not urgent goes in a single LATER line, not a list.
   - If today is genuinely quiet, say so in one sentence." \
  --deliver local \
  --name "triage" \
  --reasoning-effort high

hermes cron edit triage --provider [provider] --model [good-model]
```

Then wire the chain. Get the collector IDs from `hermes cron list` and set `context_from` on the triage job to `["collect-calendar", "collect-due"]` — names work as well as IDs. Each upstream job's most recent completed output is injected above the prompt at runtime.

**Part 3 — The delivery job (20 min)**

```bash
hermes cron create "every day at 06:30" \
  "Format the triage above as a message under 150 words. No preamble." \
  --deliver telegram --name "daily-ledger"
```

Set its `context_from` to `triage` and pin it to a cheap model.

**Part 4 — Understand the timing trap (15 min)**

Chaining reads the most recent *completed* output. It does **not** wait for an upstream job running in the same tick. Space your stages by real minutes — that's why the times above are 06:00, 06:05, 06:15, 06:30, not all at 06:00.

### Doing it in the GUI

| Task | Where |
|---|---|
| See the whole chain in one place | Dashboard → **Cron** (aggregates across profiles, with a filter) |
| Pin a per-job model and provider | Dashboard → **Cron** → job editor |
| Adjust stagger times between stages | Dashboard → **Cron** → edit each job's schedule |

Model pins are deliberately user-owned — the agent's own `cronjob` tool cannot set or change them. The dashboard, `hermes cron edit --model`, and `jobs.json` are the three places you can. Setting them here makes the cheap/expensive split visible in one list.

### Verification
- [ ] Each stage's output exists under `~/.hermes/cron/output/<job_id>/`
- [ ] Triage output visibly reflects both collectors
- [ ] Breaking one collector degrades the brief without killing the pipeline
- [ ] Your model pins are actually in effect — check `hermes cron list`

### Cost note
Counter-intuitively lower than one monolithic job, because only the triage stage pays for a capable model.

### Failure mode
Stage 2 reports on yesterday's data because stage 1 hadn't finished. Widen the gaps. If a collector is slow, give it its own earlier slot.

---

---

# Level 9: Package It So Others Can Run It

**Difficulty: ●●●●●●●●●○**

### New mechanism
Blueprints (a skill that carries a schedule) and gateway event hooks.

### The project: **The Household Share**

**Outcome:** Your partner installs the shopping-list automation themselves, in one command, on their own machine — and stops routing every change request through you. And your gateway tells you when something broke overnight instead of failing quietly.

**Time it gives back:** Removes you as the single point of failure for anything shared. Also removes the slow tax of a broken job you didn't notice for a fortnight.

**You'll have built:**
- A blueprint skill that installs as a *suggestion*, never a silent job
- `~/.hermes/BOOT.md` and a working `boot-md` hook
- A guardrail hook that blocks writes outside your vault and scripts directories

### Why this is near the top
Everything before this was *your* automation on *your* box. This level is about the automation surviving contact with a fresh machine, a family member, or your own future self after a rebuild.

### Steps

**Part 1 — Turn a skill into a blueprint (40 min)**

Take the meal-planner skill from Level 6 — the one your household actually uses — and add a `blueprint:` block. It becomes a runnable, shareable automation that someone else can install without you:

```yaml
metadata:
  hermes:
    tags: [blueprint, personal, food]
    blueprint:
      schedule: "0 10 * * 0"
      deliver: origin
      prompt: "Plan the coming week's dinners and give me the shopping list."
      no_agent: false
```

Installing a blueprint never silently schedules anything — it registers as a *suggestion*:

```bash
/suggestions              # list pending
/suggestions accept 1     # actually create the cron job
/suggestions dismiss 1    # never offer it again
/suggestions catalog      # browse the curated starter automations
```

Numbers are positional — re-run `/suggestions` before acting on one; the list renumbers after every accept or dismiss.

**Dismissal is a one-way door.** A dismissed suggestion latches by its dedup key: reinstalling the skill will never re-offer it (that's consent-first working as designed — "no" shouldn't mean "ask me again next update"). If you change your mind later, don't hunt for an un-dismiss; just schedule the job directly — this is exactly what accept does under the hood, so the result is identical:

```bash
hermes cron create "0 9 1 * *" "Run the monthly security audit and report only findings." \
  --name "blueprint:secure-box-audit" --skill secure-box-audit
```

**Your jobs have memory — use it.** Two upstream cron features matter here:

- **The notepad** — every cron job gets a durable key-value scratchpad (16KB per key), automatically injected into each run's prompt. The agent writes it with `hermes cron notepad <job_id> set <key> <value>`. `money-watch` uses it to remember the last price it reported (no more re-alerting the same drop every four hours), `quiet-inbox` keeps its last-seen-mail watermark there, and `boot-health-check` remembers which incidents it already told you about.
- **Continuity** (`--continuity` on `hermes cron create`) — injects the previous run's *output* into the next run's prompt. Good for narrative continuity; the notepad is the authoritative store for structured state.

**Installs are idempotent.** `install.sh` at the repo root can be re-run any time: skills you already have are skipped untouched, only missing ones are installed, and your accepted/dismissed decisions are preserved. Pulling the latest collection onto an existing box is just `git pull && bash install.sh`.

That's the correct trust model, and it's worth internalizing before you hand anything to anyone. (`/blueprint <name>` is a separate, built-in catalog of curated automations — it walks you through fields one question at a time; the skills in this repo flow through `/suggestions`, not `/blueprint`.)

**Part 2 — Build a boot checklist (60 min)**

Hermes doesn't ship a built-in `BOOT.md` hook — you wire it yourself, which means you can see exactly what it does.

Write `~/.hermes/BOOT.md` in plain language:

```markdown
# Startup Checklist

1. Run `hermes cron list` and check whether any jobs failed overnight.
2. If any failed, summarize which and why.
3. Check that ~/life/renewals.csv still exists and parses. The expiry desk
   is the one job whose silence is indistinguishable from failure.
4. If nothing needs attention, reply with only [SILENT].
```

Then create `~/.hermes/hooks/boot-md/HOOK.yaml`:

```yaml
name: boot-md
description: Run ~/.hermes/BOOT.md on gateway startup
events:
  - gateway:startup
```

And a `handler.py` alongside it that reads the file and spawns a one-shot agent on a background thread. Two things are essential in the handler: resolve the gateway's model with `_resolve_gateway_model()` and its credentials with `_resolve_runtime_agent_kwargs()`. A bare `AIAgent()` falls back to built-in defaults and will 401 against any custom endpoint. Spawn on a thread so gateway startup isn't blocked on a full agent turn.

Test it:

```bash
hermes gateway restart
hermes logs --follow --level INFO | grep boot-md
```

**Part 3 — Know your four hook systems (30 min)**

| System | Registered via | Runs in | Use for |
|---|---|---|---|
| Gateway hooks | `HOOK.yaml` + `handler.py` in `~/.hermes/hooks/` | Gateway only | Logging, alerts, boot checklists |
| Plugin hooks | `ctx.register_hook()` in a plugin | CLI + gateway | Tool interception, guardrails, metrics |
| Shell hooks | `hooks:` block in `config.yaml` | CLI + gateway | Drop-in scripts, blocking, context injection |
| Outbound webhooks | `hooks.outbound:` in `config.yaml` | CLI + gateway | Pushing signed events elsewhere |

Gateway hooks **only** fire in the gateway — the CLI doesn't load them. If you want something that fires everywhere, you want a plugin or shell hook.

**Part 4 — A useful guardrail hook (30 min)**

A shell hook on `pre_tool_call` can block or modify a tool call before it runs. A worthwhile personal one: block `write_file` and `patch` anywhere outside your designated vault and scripts directories. Note the fail-closed semantics — if a `pre_tool_call` callback times out, the tool is blocked rather than allowed through unchecked.

### Doing it in the GUI

| Task | Where |
|---|---|
| Browse and schedule a blueprint | Dashboard → **Cron** → **Blueprints** tab → fill the form → *Schedule it* |
| Send a blueprint to the desktop composer | Desktop → **Send to App** on any blueprint |
| Review pending suggestions | `/suggestions` in chat — list, accept, dismiss |

Blueprints are the most GUI-friendly thing in the whole workshop: pick one, fill two fields, confirm. Nothing is ever scheduled without that confirmation.

Hooks are the opposite — `HOOK.yaml` and `handler.py` are files with no GUI equivalent, by design. You see exactly what they do because you wrote them.

### Verification
- [ ] A fresh profile can install your blueprint and accept the suggestion
- [ ] Installing does *not* create a job until you accept
- [ ] `hermes gateway restart` triggers the boot checklist, visible in logs
- [ ] A quiet boot produces no message; a real failure does
- [ ] Your guardrail hook actually blocks a write outside the allowed paths

### Cost note
The boot hook costs one agent turn per gateway restart. If you're restarting often while developing, that adds up — consider the non-agent variant that just posts a fixed notification.

### Failure mode
The boot hook silently does nothing. Almost always the credential resolution, and almost always visible in `hermes logs`. Second most common: it works beautifully in the CLI and never fires in the gateway, or vice versa, because you picked the wrong hook system.

---

---

# Level 10: The Sunday Ledger

**Difficulty: ●●●●●●●●●●**

### New mechanism
Profiles, subagent delegation, and self-consolidating memory.

### The project: **The Sunday Ledger**

**Outcome:** One page, every Sunday evening, assembled while you slept. What's due. What you owe people. What's expiring. Who to call. What to buy. Decisions surfaced, not data.

Behind it: scoped agents that can't reach into each other's business — one for home admin, one for health, one for money — a coordinator that hands out the work, and a 3am job that reads the week back and proposes what next week should know.

**Time it gives back:** Collapses the Sunday-evening "what am I forgetting" sweep across calendar, inbox, bills, and notes into reading one page. For most people that's the single most reliable hour of the week returned.

**You'll have built:**
- Three profiles with descriptions and separate credentials
- One delegation that returns a summary instead of flooding the parent's context
- A `sunday-ledger` job that **proposes** memory updates rather than writing them
- `hermes cron incidents` either empty or consciously acknowledged
- A written blast-radius note you could read aloud to a sceptical friend

### Why this is the top of the ladder
Every prior level was a workflow. This is an architecture. It's also where the failure modes stop being "the message didn't arrive" and start being "two agents rewrote each other's memory and neither of them is configured the way I set them up anymore."

### Steps

**Part 1 — Split into profiles (60 min)**

A profile is a separate Hermes home directory: its own `config.yaml`, `.env`, `SOUL.md`, memory, sessions, skills, cron jobs, and state DB.

**The one rule that matters: never point two agent processes at the same profile.** Both write memory automatically, and each loads the other's writes at session start, so two writers on one home compound each other's state until it stops resembling anything you configured. Profiles exist precisely to prevent this.

```bash
hermes profile create home   --description "Renewals, maintenance, errands, meal planning, the household calendar."
hermes profile create money  --description "Bills, subscriptions, price watches, renewals with a cost attached."
hermes profile create people --description "The people vault: birthdays, follow-ups, gift ideas, reach-outs."
```

Each gets its own credentials and its own scope. The `people` profile has no reason to touch your bank mail; the `money` profile has no reason to read your private notes about friends. That separation is the point — it's what lets you give the money agent real financial visibility without it also holding everything else.

**Part 2 — Delegation (60 min)**

Your default profile becomes the coordinator. It uses `delegate_task` to hand isolated work to subagents rather than doing everything in one enormous context window. This is a context-management move as much as an organizational one: a child agent's 40,000 tokens of intermediate work never enter the parent's context — only its summary does.

Start with one delegation, not five. Something like: "research this appliance replacement, compare three options against my constraints, come back with a recommendation and the reasoning."

**Part 3 — Cross-profile routing (45 min)**

Use `bot-chat:<profile>` as a delivery target. Unlike every other target — where the recipient is a human reading a channel — the recipient here is the *bot itself*: it receives the output as an incoming message and acts on it.

```
deliver: "bot-chat:household"
```

Two caveats: each such delivery costs the target bot a full agent turn, so mind the frequency; and profiles are validated against `hermes profile list` at create time, so only same-machine profiles can be targeted.

**Part 4 — The Sunday Ledger job (60 min)**

This is the one that makes the whole system feel alive. While you sleep, it assembles the week.

```bash
hermes cron create "every sunday at 03:00" \
  "Assemble this week's ledger. Read: ~/life/renewals.csv, ~/life/ledger/commitments.md,
   ~/life/purchases.md, the ./people vault, and the last 7 days of sessions
   via session_search.

   Write ~/life/ledger/YYYY-Www-sunday.md with exactly these sections,
   and omit any section that is empty:

   DUE — anything with a date in the next 14 days, soonest first.
   OWED — commitments I made to other people that are still open.
   EXPIRING — renewals inside their lead window, with what I should do.
   WHO TO CALL — at most 3 people, with a one-line opening for each.
   DECIDE — anything genuinely needing a decision from me this week.

   Hard limit: one page. If it doesn't fit, cut the least urgent, don't shrink
   the text. Never invent an item - every line must trace to a file you read.

   Then propose at most 3 updates to MEMORY.md. Do NOT write them.
   List them for my approval." \
  --workdir /home/[you]/life \
  --deliver local \
  --name "sunday-ledger" \
  --reasoning-effort high
```

Then a cheap delivery job at 08:00 Sunday with `context_from: ["sunday-ledger"]` to format and send it.

Note "do not write them, list them." Automated memory writes at 3am with nobody watching is how an agent's model of you drifts somewhere you didn't authorize. Pair this with `memory.write_approval: true`.

**Part 5 — Budget and failure governance (45 min)**

At this scale, three things need to be deliberate:

**Routing.** Cheap models for mechanical work, capable models for judgment. Set `cron.model` as the fleet default, pin the exceptions, and use `--reasoning-effort` per job — heavy analyses at `high`, recurring chores at `minimal` — without touching your global default.

**Failure handling.** A recurring job that keeps failing pings you every run. Hermes records each failure as a durable incident keyed by job plus a normalized error signature:

```bash
hermes cron incidents                  # newest activity first
hermes cron incidents ack <id>         # stop re-pinging this exact signature
```

Acknowledging silences that one signature only — a *different* error mints a new incident and alerts again. Also set a review nudge threshold:

```yaml
cron:
  failure_nudge_threshold: 3
```

**Preflight.** Leave `cron.preflight` on. It validates API keys, skill readiness, and delivery targets *before* constructing any agent machinery — a misconfigured job never spends tokens, and you get exactly one alert rather than a repeating one.

**Part 6 — Audit what you built (30 min)**

Sit down and write out, honestly: which agent can reach which credentials, which can write where, and what the worst case looks like if any single one is compromised. If you can't answer that in five minutes, you've built something you don't understand well enough to run unattended.

### Doing it in the GUI

| Task | Where |
|---|---|
| Switch between profiles | Dashboard → profile switcher (Chat and most pages follow it) |
| See every profile's jobs at once | Dashboard → **Cron** → filter by profile |
| Manage the roster of agents | Desktop → **Bots** tab — each Bot is a profile under `~/.hermes/profiles/<name>/` |
| Inspect a bot's scheduled routines | Desktop → **Routines** pane (they appear as `[bot:<name>] <routine>`) |
| Watch multi-agent work | Desktop → **Kanban** board |

Two things the profile switcher does *not* absorb, so don't expect it to: gateway processes (use `hermes -p <name> gateway …`) and each profile's session database. If you're reaching a remote box, `hermes serve` runs a headless backend the Desktop app can connect to over SSH — which is how you get a GUI on a VPS without exposing the dashboard.

### Verification
- [ ] Each profile runs independently with its own memory and credentials
- [ ] No two processes share a profile home
- [ ] Delegation returns summaries without flooding the parent's context
- [ ] The nightly job *proposes* memory updates rather than writing them
- [ ] `hermes cron incidents` is empty, or every entry is one you consciously acknowledged
- [ ] You can state the blast radius of each profile out loud

### Cost note
This is the level where costs get away from people. Instrument before you expand: know your daily spend, know which job dominates it, and re-check after every addition.

### Failure mode
Over-building. The most common Level 10 outcome is an elaborate multi-agent system that does less useful work than the Level 2 morning brief, because complexity outran reliability. If a level-10 component isn't clearly beating what a simpler job did, delete it.

---

---
## Workshop Completion Checklist

By the end you should have:

- [ ] **The Box** — isolated host, explicit allowlist, tested restore (L0)
- [ ] **The Return Desk** — nothing lapses without warning you first (L1)
- [ ] **The Out-The-Door Brief** — decisions each morning, not a forecast (L2)
- [ ] **The Money Watch** — watchers that speak only when there's money on the table (L3)
- [ ] **The Expiry Desk** — every renewal warned with real lead time, for $0 (L4)
- [ ] **The Quiet Inbox** — mail triaged, drafts only, flat spend on idle days (L5)
- [ ] **The Sunday Kitchen** — a chore captured as a skill and scheduled (L6)
- [ ] **The People File** — you stop being the person who forgets (L7)
- [ ] **The Morning Standup** — a chained pipeline with per-stage model routing (L8)
- [ ] **The Household Share** — one shareable blueprint and one gateway hook (L9)
- [ ] **The Sunday Ledger** — one page a week, assembled while you slept (L10)

---

## The Two Things Worth Remembering

**Start with one workflow. Make it boringly reliable. Then add the next piece.** The most common failure with Hermes isn't a broken job — it's a default profile turned into a backpack full of every skill, tool, and instruction, running twenty half-working automations that each need babysitting. Ten reliable jobs beat forty flaky ones every single time.

**Permissions come last, and one at a time.** Level 0 first. Give it a scoped path to anything that matters. Assume that anything the agent can reach, an attacker who compromises the agent can also reach — and design the setup so that sentence isn't frightening.

---

*Reference: the current Hermes docs at `hermes-agent.nousresearch.com/docs` — particularly Security, Scheduled Tasks, Creating Skills, Event Hooks, Persistent Memory, and Profiles. The cron page in particular is worth reading end to end before Level 8.*
