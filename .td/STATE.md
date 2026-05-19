# State

Project:  td-flow
Topic:    idle
Phase:    shipped — `/td-mailbox` tracker-free redesign (2026-05-19)
Blocker:  none
Last:     2026-05-19 — **Reverted the outbound tracker mechanism in `/td-mailbox` to a minimum-dependency design.** Triggered by a critical review: the tracker Epic was over-engineered — it solved an outbound-tracking problem we already had a simpler solution for (org-wide search). New mechanism: outbound scope is the per-project `.td/PROJECT.md § Cross-repo` list (already-existing, opt-in, human-curated); outbound query is one bounded GraphQL search across those declared repos, client-side filtered by the `**From:** <project>` body marker. No tracker Epic, no sentinel logic, no "orphan detection" concept, no auto-create. Sub-issue linkage stays for **real planning Epics** with cross-repo children — that's a legit GitHub-native use case (progress bar + native UI), separate from outbound tracking. Filing rule simplified massively: file with marker + ask + why; optional `addSubIssue` only if the work belongs to an existing Epic. Validated via roleplay v3 (3rd roleplay this session): td-flow had no Cross-repo section initially → outbound correctly reported "no cross-repo registry declared"; added `mergodon/td-registry` to the section; filed a CR with marker; outbound query bounded to `repo:mergodon/td-registry` correctly returned the new filing AND correctly excluded a false-positive (`rgb-ggbuddy#8` mentions "td-flow" but lacks the marker; out of scope anyway because rgb-ggbuddy isn't declared). Also observed: GitHub search index lag (~1-5s after createIssue) — documented in command file. Test artifact closed. Both repos at zero open issues. Earlier today: shipped /td-mailbox + tracker model (886a8a3, now reverted); shipped stack-reality-check + doc hygiene at /td-clear and /td-close (32a5f3b); shipped post-roleplay refinements (253db08, mostly still relevant — Feature retire, close-as-stale, body cleanup, continuous orphan detection rolled into the simpler design as just-the-outbound-query).

## Resume note

td-flow at 7 slash commands. Cross-repo work surface is now tracker-free:

**Two pieces of state, that's all:**
1. `.td/PROJECT.md § Cross-repo` — list of repos this project files into (human-curated, opt-in, one-line edits to onboard a new connected repo).
2. `**From:** <project>` body marker — every cross-repo filing includes it. Identifies our own filings client-side and gives the receiver a stable source signal independent of GH account.

**Outbound mechanism:** one bounded GraphQL search `repo:A repo:B "<project>" type:issue state:open`, filter results by body marker. Done. No tracker Epic, no addSubIssue (except for real planning Epics where it adds value).

**Doc hygiene** is mechanical at `/td-clear` (heads-up) and `/td-close` (full diff vs PROJECT.md § Stack). Stack drift can't accumulate silently anymore.

**Issue Types in use:** Idea, Task, Bug, Epic. Feature was retired from the mergodon org mid-session.

**Search-index lag is real:** GitHub's search takes ~1-5s to index newly-created issues. Doesn't matter in normal workflow (you don't run /td-mailbox the moment after filing). Documented in commands/td-mailbox.md Step 4 as a one-paragraph note.

**Open follow-ups (in priority order):**

1. **First real-project run of `/td-mailbox`.** Validated 3 times this session synthetically — initial GraphQL plumbing (closed validation issues), full roleplay walk with tracker, then tracker-free roleplay. Next step: run on a real project that has open cross-repo work.

2. **First real `/td-close` run with the new stack-reality-check.** au-dual-track or another Livewire project — that's the source of the gap that triggered the upgrade.

3. **The `/td-init` auto-register-in-$TD_REGISTRY piece** from the 2026-05-17 BACKLOG item — still pending. Today shipped the /td-clear + /td-close enhancements from that item.

4. **Brownfield-detection real-project validation** of the v4.0 framework — still scheduled, unstarted.

5. **Optional future work — auto-add to Cross-repo on first cross-repo filing.** When the user says "file an issue for repo X" and X isn't in Cross-repo, the routing currently asks the user to declare it first. A future enhancement: offer to add the line to PROJECT.md § Cross-repo automatically in the same conversational turn (one-line edit + the createIssue mutation). Worth doing once we have real-project usage data.
