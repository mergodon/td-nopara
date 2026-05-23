# State

Project:  td-flow
Topic:    preserve-in-flight-design
Phase:    working
Blocker:  none
Last:     2026-05-24 — /td-snapshot shipped (16cfe82); /td-incident rewritten as composition.

## Resume note

Active piece: #11 In-flight design lost across /td-incident pivot when topic isn't yet materialised in STATE/work — Closes #11 on ship.

Planning surface: `.td/work/preserve-in-flight-design.md`. The issue proposes two fixes (A + D) targeting the same failure mode: 90-minute in-chat design conversation lost across a `/td-park` + `/td-incident` sequence because STATE/work never reflected the in-flight topic. Fix A is a snapshot prompt in `/td-incident` Step 2.5; Fix D is a framework-level "materialise the topic before continuing the design" rule. v5.1 just closed before this — context preserved in commit `3958b16`.
