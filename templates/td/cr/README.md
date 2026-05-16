# `.td/cr/` — change requests this project has filed against other teams

Outbound channel only. Each file in `.td/cr/` is a change request **this project sent to another team / project**. Inbound CRs (asks others sent to us) live as one-line entries in `.td/BACKLOG.md` referencing the sender's CR id — no parallel `cr/in/` folder.

This keeps a single canonical copy of every CR (in the sender's repo), and avoids the drift problem of mirroring files across repos.

## File naming

```
.td/cr/YYYY-MM-DD-CR-N-slug.md
```

- `YYYY-MM-DD` — date filed. Sorts chronologically when listed.
- `CR-N` — stable per-sender identifier. Numbering is per-project (this project's `CR-1` is unrelated to another project's `CR-1`). Receivers always reference as `CR-N (sender-project)`.
- `slug` — kebab-case short title.

Example: `2026-05-16-CR-1-populate-job-error.md`.

## Frontmatter

```yaml
---
id: CR-1
to: anzscofinder-pipeline      # receiver project (folder name or org/repo)
status: open                   # open | accepted | shipped | rejected | withdrawn
severity: high                 # high | medium | low
created: 2026-05-16
shipped_in:                    # commit SHA in receiver's repo when status=shipped
issue:                         # optional GH issue URL when notification layer ships
---
```

## Body

Each CR's body should be self-contained — a reader who has seen neither codebase should be able to act on it. Recommended sections:

- **What.** The change requested.
- **Why.** The consumer pain (referencing concrete observed behaviour, not "would be nice").
- **Suggested.** A concrete approach, including file paths or schema names where possible.
- **Impact.** What the sender will do with the change once delivered. Helps receiver weigh priority.

## Lifecycle

**Sender:**
1. Write `.td/cr/<file>` with `status: open`. Commit (`docs(cr): file CR-N <slug>`).
2. Notify the receiver — solo dev: switch hats. Multi-dev: post a link / open GH Issue.
3. As the receiver responds, update the frontmatter:
   - `status: accepted` (receiver agreed to do it; appears in their BACKLOG).
   - `status: shipped`, set `shipped_in: <sha>` (receiver shipped; SHA points at the commit in their repo).
   - `status: rejected` — keep the file with a brief reason in the body so the rationale survives.
   - `status: withdrawn` — sender decides not to pursue.
4. Each status change is its own small commit so the audit trail tracks the conversation.

**Receiver:**
1. On notification, triage the CR. If accepted, add one line to `.td/BACKLOG.md`:
   ```
   - 2026-05-16 — CR-1 (anzscofinder) populate JobError on fetch failures (High)
   ```
2. When implementing, commit message includes the cross-reference: `Resolves anzscofinder CR-1`.
3. Ping the sender to flip `status: shipped`.
4. If rejecting, ping the sender with the reason; sender records it in their CR body.

## Pruning

At `/td-close`, CRs in `status: shipped`, `status: rejected`, or `status: withdrawn` get pruned in the same commit (`chore: prune closed CRs`). `git log` preserves them. Open and accepted CRs survive close.

## Notification — today vs. tomorrow

**Today (solo, switching hats):** the act of switching to the receiver project IS the notification. The `cr/` folder is your reading queue. The receiver's BACKLOG line is theirs.

**Later (real collaborators):** layer GitHub Issues on top — file an issue on the receiver's repo, paste the CR link, set the `issue:` field in this CR's frontmatter. Same files, same lifecycle, just better notification + searchability. No restructuring needed.
