---
name: secure-box-audit
description: Monthly audit of the Hermes host's security posture - allowlists, approvals, egress, exposure, dependency advisories. Detects VPS vs Railway/container hosting and applies the right expectations to each.
version: 1.1.0
author: Allen Harper
metadata:
  hermes:
    tags: [blueprint, security, level-0]
    requires_toolsets: [terminal, file]
    blueprint:
      schedule: "0 9 1 * *"
      deliver: origin
      prompt: "Run the monthly security audit and report only findings."
      no_agent: false
---

# Secure Box Audit (Level 0)

## When to Use
Monthly, on any machine running Hermes unattended. Also run it by hand immediately after changing config, adding a connector, installing a third-party skill, or redeploying.

## Why This Exists
Approval guards and write guards protect against an honest-but-mistaken agent. They are not a sandbox against a hostile one - the `terminal` tool runs as the same OS user and can reach the same paths. Containment is a deployment decision, and deployments drift. This checks that yours hasn't.

## Step 0 - Work out where you are
Before any check, detect the hosting environment. **Do not skip this; the expectations below differ by host.**

- If `RAILWAY_PROJECT_ID` or `RAILWAY_ENVIRONMENT` is set in the environment: mode = **RAILWAY**
- Else if `/.dockerenv` exists or `/proc/1/cgroup` mentions `docker` or `containerd`: mode = **CONTAINER**
- Else: mode = **VPS**

State the detected mode in one line at the top of any report you send.

## Checks - all modes
1. Run `hermes doctor`. Report any advisories as FINDINGS.
2. Read `~/.hermes/config.yaml`. Report as FINDINGS:
   - `approvals.cron_mode` is not `deny` - **this is the single most important line in the file on a container host, where there is no Docker sandbox underneath**
   - `approvals.mode` is `off`
   - `security.allow_private_urls` is `true`
3. Confirm memory approval is on if `sunday-ledger` or any memory-writing job is installed (`memory.write_approval: true`). Report if not.
4. List gateway allowlist entries from the environment (`GATEWAY_ALLOWED_USERS`, `TELEGRAM_ALLOWED_USERS`, etc.). Report any you cannot account for, and report as a FINDING if `GATEWAY_ALLOW_ALL_USERS` is set to a truthy value.
5. Determine the user the gateway runs as via `id -u` and `/proc/1/status` (do **not** rely on `ps` or `pgrep` - slim images often lack them).

## Checks - VPS mode only
6. `terminal.backend` should be `docker`, `ssh`, or a cloud sandbox. Report `local` as a FINDING.
7. `terminal.docker_forward_env` should be empty. Report if not.
8. The secrets file (`.env` inside the hermes home directory) should exist and be mode 600 - verify with `stat`, never by reading it. Report anything more permissive.
9. Gateway running as root (uid 0) is a FINDING.
10. Report the age of the most recent backup of `~/.hermes/`. Older than 7 days is a FINDING.

## Checks - RAILWAY and CONTAINER mode only
6. `terminal.backend` will be `local` - that is expected, not a finding. Railway prohibits privileged containers and Docker daemon access; the service container is the isolation boundary. Say so once in INFO, not as a FINDING.
7. If uid is 0, report as INFO (not FINDING) with the note: "running as root - if this is the RAILWAY_RUN_UID=0 volume workaround, confirm it is still required; otherwise unset it."
8. The secrets file may not exist on Railway - secrets are injected as environment variables instead. Report as a FINDING only if a secrets file **does** exist in the hermes home **and** is more permissive than 600 (again: `stat`, never read it), or if one appears inside the repo/volume where it could be committed.
9. **Exposure check - the important one.** If `RAILWAY_PUBLIC_DOMAIN` is set, the service has a public URL. Then:
   - If the dashboard is running (`hermes dashboard` process, or `dashboard.enabled` / a dashboard port in config) and bound to anything other than `127.0.0.1`: when an auth provider gates it (basic-auth env vars set, or a claim-login/auth plugin such as the AICVC mentor-auth is installed), report INFO — "public dashboard, gated by <provider>" — a hosted dashboard IS the product on managed deployments like the AICVC template. Report a FINDING only when the public dashboard has NO auth provider in front of it.
   - Note in INFO that the public domain exists at all, and whether it is needed (a Telegram-only bot does not need one - webhooks are outbound).
10. Backups cannot be verified from inside the container. Report as INFO: "confirm Railway volume backups are enabled for this service" - once per run, not as a FINDING.
11. Confirm `HERMES_HOME` (or the default) resolves to a path on the attached volume, not the ephemeral filesystem. If `~/.hermes` is **not** on a mounted volume, that is a FINDING: every redeploy will wipe jobs, skills, memory and the session DB.

## Reporting
- If every check passes for the detected mode, reply with ONLY `[SILENT]`.
- Otherwise: one line stating the mode, then FINDINGS (setting, current value, expected value), then INFO. No preamble.

## Pitfalls
- Do not modify any configuration. This skill reports; the human decides.
- Do not print the contents of `.env`, any key, token, or allowlist user ID. Report file permissions and counts, not values.
- If a command fails, say so plainly rather than assuming the check passed.
- Do not apply VPS expectations to a container host. A monthly false positive trains the user to ignore this job, and then the real finding gets ignored too.

## Verification
A clean month produces no message at all. On Railway, the first run should produce INFO lines about the `local` backend, volume backups, and (on hosted-dashboard deployments) the auth-gated public dashboard - and nothing else. A FINDING about the backend means mode detection failed.
