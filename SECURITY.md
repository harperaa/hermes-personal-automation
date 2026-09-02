# Security Notes

These skills schedule an autonomous agent against your personal data. Read this before installing any of them.

## The threat model

The moment an agent reads a web page, triages an email, or loads a skill someone else wrote, it is processing text a stranger controls. Assume that eventually some of that text is written specifically to redirect it — not because the model is bad, but because that is the environment it operates in.

Hermes' approval guards and write guards protect against an honest-but-mistaken agent. They are **not** a sandbox against a hostile one: the `terminal` tool runs as the same OS user and can reach the same paths a write guard blocks. Containment is a deployment decision, not a config toggle.

## Before you install anything here

1. Run Hermes on a host that is **not** your daily driver — a cheap VPS, an old laptop, a Pi.
2. Set an explicit gateway allowlist. Never `GATEWAY_ALLOW_ALL_USERS=true`.
3. Keep `approvals.cron_mode: deny`. Every skill here runs headless; `approve` would let an injected instruction authorise itself at 3am.
4. `chmod 600 ~/.hermes/.env`, and do not run the gateway as root.
5. Install `secure-box-audit` first and run it once by hand.

Level 0 of the workshop in `workshop/` covers all of this properly.

## Skill-specific notes

**`quiet-inbox` is the highest-risk skill in this repo.** Point it at a *dedicated* mail account with only the categories you want automated forwarded into it. Your primary inbox — 2FA codes, password resets, banking — should never be reachable. The skill drafts and never sends, but the blast radius is set by which account you hand it, not by the skill text.

**`money-watch`** fetches arbitrary pages you list. It is instructed never to follow a checkout link or place an order. Review its watchlist as untrusted input.

**`sunday-ledger`** proposes memory updates rather than writing them. Keep it that way, and pair it with `memory.write_approval: true`.

## Reporting a problem

Open an issue. Do not include the contents of any `.env`, key, token, or personal data file in a report.
