# State

Project:  td-flow
Topic:    idle
Phase:    shipped — /td-refresh Phase 3 + command consistency review (2026-05-20)
Blocker:  none (token-scope for repo deletion still pending — see below)
Last:     2026-05-20 — **Added `/td-refresh` Phase 3: cross-repo registry drift check** and ran a consistency review across `/td-close`, `/td-clear`, `/td-park` per the new (tracker-free, registry-free) model. Phase 3 closes the loop on the "Cross-repo is load-bearing" decision: org-wide `**From:**` marker search (state:open) → diff observed-repos against declared-repos in `.td/PROJECT.md § Cross-repo` → propose add (filed-into-but-not-declared) or remove (declared-but-no-open-filings) per delta. Surface per-item, apply confirmed, write back PROJECT.md. Renumbered old Step 8 → 9 to accommodate the new phase. Updated CLAUDE.md slash-command entry (root + templates byte-identical) to mention Phase 3. Consistency review findings + fixes: (a) `/td-park` Step 2 hardcoded `"mergodon"` as the org — replaced with `<owner>` parameterization for forker portability; (b) `/td-close` Step 3 listed `Task` twice for planning work files — collapsed to `Epic for decomposing, Task for everything else`; (c) `/td-close` Step 7 doc-hygiene pass added a `PROJECT.md § Cross-repo` bullet (run Phase-3-equivalent drift check inline at close, or defer to /td-refresh); (d) `/td-close` frontmatter description updated to reflect stack-reality-check + hygiene-pass scope; (e) `/td-clear` Rules added one line pointing to /td-refresh Phase 3 for cross-repo drift (keeps /td-clear fast — no audit at handoff). Earlier today: retired `$TD_REGISTRY` private companion registry concept entirely (commit 89605d8 — destructive cleanup: deleted 6 test issues from td-flow, deleted ~/projects/td-registry/ local clone, removed TD_REGISTRY block from ~/dotfiles/shell/zshenv; doc updates across 10 files; -236/+46 lines).

## Resume note

td-flow at 7 slash commands. Both major simplifications from this session shipped:

1. **Tracker-free `/td-mailbox`** (yesterday's revert): outbound = bounded GraphQL search over PROJECT.md § Cross-repo + `**From:**` body-marker filter. No tracker Epic.

2. **`$TD_REGISTRY` retirement** (today's first commit): no separate registry repo, no SERVICES.md/NAMING.md layer; friendly-name resolution = PROJECT.md H1 → directory basename.

3. **`/td-refresh` Phase 3 + command consistency** (today's second commit): the load-bearing PROJECT.md § Cross-repo list now has a dedicated drift check at /td-refresh, plus inline at /td-close Step 7. /td-park/td-close/td-clear all reviewed for consistency with the new model.

**State of the framework:**
- 7 slash commands, all consistent with the tracker-free, registry-free model.
- Cross-repo state per project = (a) PROJECT.md § Cross-repo list, (b) `**From:** <project>` body marker. That's all.
- Doc-hygiene + stack-reality-check mechanical at /td-clear (heads-up) and /td-close (full pass + now includes Cross-repo drift).
- Issue Types: Idea, Task, Bug, Epic (Feature retired).

**Outstanding action item:**

- **GH repo deletion still pending.** `gh repo delete mergodon/td-registry` failed earlier with "needs delete_repo scope." Run `gh auth refresh -h github.com -s delete_repo` to add the scope, then I retry. The repo still exists on github.com (with closed test issues). All references in this codebase + your dotfiles are already cleared, so it's just a GH-side cleanup.

**Beyond this session:**

- First real-project run of `/td-mailbox` on a project with open cross-repo work (also exercises /td-refresh Phase 3 implicitly via the drift check at close).
- First real `/td-close` exercising the mechanical stack-reality-check.
- Brownfield-detection real-project validation of the v4.x framework.
