# td-flow feedback

Bugs and ideas about the td-flow framework itself. Captured by saying "feedback on td-flow" in any project — the routing rule appends it here. Reviewed and addressed by editing the framework directly.

When an item is addressed, delete the line. Git keeps the history.

## Open

- **STATE.md handover spec is too loose for complex sessions (2026-05-25, anzscofinder-pipeline).** The current CLAUDE.md describes STATE.md as "current phase, current topic, blocker, resume note" — adequate for small handoffs, insufficient for multi-phase work. After ~2 days of intense U2 catalogue enrichment work (decisions, audits, partial human-in-loop reviews, multiple parallel runs, partner deliverables), my first comprehensive STATE.md still missed the categorised pending-action list. Peter caught it; I had to add 16.A (Peter's actions), 16.B (external waits), 16.C (Claude's sequenced next steps C1-C5), 16.F (dependency graph), 16.G (resume sequence). The doc was a state-of-the-world dump, not a continuation playbook. Recommend STATE.md template gain required sections:
  - **Pending-action list** with `owner / effort / blocks` columns
  - **External waits** with `awaiting / from-whom / ETA`
  - **Dependency graph** (text-ASCII or table) showing critical path
  - **First-action pointer** — single explicit "the very next thing"
  - **Background-processes / in-flight state** — what's running on the machine right now (long-lived dev servers, queued jobs, etc.)
  - **Volatile artifacts** — `/tmp/` data + recovery cost if lost
  - **Credentials state** — rotated? revoked? new key in .env?
  - **Cumulative spend + budget marker** (when applicable)
  - **Safe-without-asking vs needs-approval** boundary
- **/td-clear should enforce a self-validation step.** Before declaring handover complete, the skill should prompt the model to answer:
  - "Given only this STATE.md, could a fresh Claude know EXACTLY what to do next, by whom, in what order?"
  - "Are there decisions Peter is waiting on that aren't surfaced?"
  - "Are there volatile artifacts that might disappear?"
  - "Is there anything in the conversation that's NOT in committed docs?"
  - If any answer is "no" or "yes (and not captured)" — STATE.md is incomplete; iterate before allowing commit.
- **The 200-line cap on MEMORY.md is fine, but STATE.md needs no cap.** Complex projects warrant 300-500 lines of structured handover. The current setup doesn't constrain STATE.md length but doesn't require enough structure either. Consider documenting STATE.md as "structured per template, length as needed."

## Bugs

(empty)

## Bugs

(empty)
