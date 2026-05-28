---
description: Proactive production health check. Runs the project's .td-flow/health.sh, reports OK/WARN/FAIL — parks warnings to BACKLOG, escalates failures to /td-flow-incident. First run scaffolds the routine.
---

You are running a proactive health check on this project's production deployment. This is the inverse of `/td-flow-incident`: nothing is on fire yet — you are looking *for* fires before users find them. The check is **read-only on production** — observe, never mutate. Anything that needs a mutation to fix is a `/td-flow-incident`, not a `/td-flow-health`.

# Step 0 — Verify we're in a td-flow project

Confirm `./.td-flow/` exists. If missing, abort: "Not a td-flow project — `/td-flow-health` only runs inside a td-flow project."

# Step 1 — Locate the health routine

The project owns *what* to check; `/td-flow-health` only runs it. The routine is a script — canonical path `./.td-flow/health.sh`, fallback `./.td-flow/ops/health.sh` (some projects keep an `ops/` folder).

- **Found** → Step 4 (run it).
- **Not found** → Step 2.

# Step 2 — No routine — is this a production project?

Check `.td-flow/PROJECT.md` for a `## Health` section.

- **`## Health` says "Not applicable"** → this project has been marked non-production. Report: `Health: n/a — <reason from the section>. Nothing to check.` Stop here, exit clean.
- **No `## Health` section** → this is the first `/td-flow-health` on this project. Go to Step 3.

# Step 3 — First run: set up the routine (or mark non-production)

Tell the user this project has no health routine yet, and offer two doors:

**(a) Define one** — most projects with a production deployment want this.
**(b) Mark it non-production** — for local CLIs, libraries, scratch repos, anything with no live surface to check.

If **(b)** — add a `## Health` section to `.td-flow/PROJECT.md`:

```
## Health

Not applicable — <one-line reason, e.g. "local CLI, no production surface">.
```

Commit `docs: mark <project> non-production for /td-flow-health`. Done — future runs skip this project cleanly.

If **(a)** — **draft the script, don't interrogate.** Read `.td-flow/WORKWAY.md` § Live (production URL, deploy host, log locations) and `.td-flow/PROJECT.md` § Stack. From those, draft `.td-flow/health.sh` from the template at `~/projects/td-flow/templates/td-flow/health.sh`:

- Always include the **app-reachable** check, pointed at the production URL + the cheapest health route (Laravel ships `/up`; otherwise the homepage or a known-light route).
- Add the checks the docs justify: deploy-in-sync, disk on the deploy box, worker/queue liveness, failed-job count, TLS cert expiry, a critical cron's last run — only the ones this project's stack actually has.
- Leave anything you can't infer as a clearly-marked `# TODO:` block rather than guessing.

Present the drafted script in full as **one** proposal. The user adjusts it in one reply — the batch-decide shape, no check-by-check walk. On accept: write `.td-flow/health.sh`, `chmod +x` it, commit `feat(health): add health routine`. Then continue to Step 4 and run it for real.

# Step 4 — Run the routine

Execute the script. Capture stdout and the exit code. Surface the full section output to the user verbatim — the OK/WARN/FAIL lines *are* the report.

The script honors a fixed protocol:

- prints `OK` / `WARN` / `FAIL` lines, one per check;
- **exit 0** = all OK · **exit 1** = at least one WARN · **exit 2** = at least one FAIL.

If the script itself errors (an exit code other than 0/1/2, or it crashes), treat that as a FAIL of the harness — report the error. The health of the app is then *unknown*, which is itself worth surfacing.

# Step 5 — Interpret and act

Branch on the exit code:

**Exit 0 — all green.** Report it — `<project>: all OK`. Done; a clean health run changes nothing, nothing to commit.

**Exit 1 — WARN(s).** Not on fire, but worth a look. List the WARN lines. Offer: *"Park the WARN(s) to BACKLOG.md?"* On yes, append each as `- <YYYY-MM-DD> — health WARN: <check> — <detail>` to `.td-flow/BACKLOG.md`, commit `docs: park health warnings to backlog`.

**Exit 2 — FAIL(s).** Something is broken in production. List the FAIL lines. Offer: *"Escalate to /td-flow-incident?"* On yes, invoke `/td-flow-incident` and supply the failing check(s) as its Step 1 one-liner — don't re-ask "what's broken". On no, stop; the user owns the call.

Close every run (except the non-production Step 2 exit) with a one-line plain verdict — `<project>: all OK` / `<project>: N warn` / `<project>: N fail` — so the outcome is scannable at a glance. The script's own summary line is the detail; this is just the headline.

# Rules

- **Read-only on production, always.** `/td-flow-health` observes. It never restarts, purges, deploys, migrates, or edits production. Fixing is `/td-flow-incident`'s job.
- **The script is the contract.** `/td-flow-health` hardcodes no checks — every project's `.td-flow/health.sh` owns its own battery. The only fixed contract is the protocol: exit `0`/`1`/`2`, `OK`/`WARN`/`FAIL` lines. A project's checks evolve by editing its script, never this command.
- **Not a STATE-moving command.** A health run is not a "piece" — it does not touch `STATE.Topic`/`Phase`/`Last`. (If it escalates into `/td-flow-incident`, that command moves STATE itself.)
- **Confirm at the real branch points only:** Step 3's drafted script + PROJECT.md edit (single accept), Step 5's "park WARNs to BACKLOG?", Step 5's "escalate to /td-flow-incident?". Don't add extra gates around the commits — they follow the normal rhythm.
- **Path drift:** if the routine is found at `.td-flow/ops/health.sh`, run it, and mention once that the canonical path is `.td-flow/health.sh` — don't move it unprompted.
