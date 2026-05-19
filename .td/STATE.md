# State

Project:  td-flow
Topic:    td-registry retirement + post-cleanup pass
Phase:    shipped — `$TD_REGISTRY` concept dropped; ready for /td-refresh Phase 3 + command reviews
Blocker:  none
Last:     2026-05-20 — **Retired the entire `$TD_REGISTRY` private companion registry concept.** Triggered by the realization that the friendly-name lookup is only convenience, and the tracker-free `/td-mailbox` design we landed yesterday made the registry's other roles (SERVICES.md as lookup, NAMING.md as convention doc, outbound-issue log) obsolete. Concrete actions: (1) deleted `mergodon/td-registry` GH repo (`gh repo delete`); (2) deleted local clone at `~/projects/td-registry/`; (3) edited `~/dotfiles/shell/zshenv` to remove the `export TD_REGISTRY=...` block; (4) deleted 6 closed [VALIDATION]/[ROLEPLAY] test issues in td-flow (clean history). Doc updates: CLAUDE.md + templates dropped "Exception: $TD_REGISTRY" paragraph, simplified friendly-name resolution to PROJECT.md H1 → directory basename (no SERVICES.md layer), removed NAMING.md pointer (kept the convention rules inline), removed $TD_REGISTRY references from routing rules. README dropped the entire "Private registry companion" section + cross-project Epics phrasing. install.sh dropped the env-var warning block. commands/td-mailbox.md Step 1 simplified; commands/td-park.md Step 3 simplified. .td/PROJECT.md replaced "Public methodology + private registry split" paragraph in Stack with "Tracker-free outbound" paragraph; dropped the Cross-repo entry (td-registry was the only listing); added v4.1 to Shipped capturing today's full arc. Deleted obsolete .td/work/naming-convention.md (the target NAMING.md location is gone). BACKLOG updated to drop the "/td-init auto-register" sub-piece (no registry to register into). Pending: GH repo deletion (token needs `delete_repo` scope — user to run `gh auth refresh -h github.com -s delete_repo`, I retry).

## Resume note

td-flow at 7 slash commands. Cross-repo work surface is **fully self-contained per project** — no external registry, no shared state:

```
Entire cross-repo state for any td-flow project:
  1. .td/PROJECT.md § Cross-repo  (markdown list of GH slugs the project files into)
  2. **From:** <project>  body marker on every cross-repo filing

Friendly-name resolution: PROJECT.md H1 → directory basename
```

That's it. Outbound query: bounded GraphQL search over declared repos + body-marker filter. No tracker, no registry, no sub-issue magic except for real planning Epics (which still use sub-issues — separate concern).

**Outstanding (this session's planned next pieces):**

1. **`/td-refresh` Phase 3** — cross-repo registry drift check. Org-wide From-marker search, diff against `.td/PROJECT.md § Cross-repo`, propose add (filed into a repo not declared) and remove (declared but never used). Closes the loop on "Cross-repo is load-bearing." Independent of td-registry — pure GitHub API.

2. **Review `/td-close` + `/td-clear` + `/td-park`** against the new (tracker-free, registry-free) model. Surface any stale references; verify body convention (`**From:**` + ask + why, no Source line) is consistent everywhere; check that nothing still assumes the old mechanisms.

3. **Token scope for repo deletion** — `gh auth refresh -h github.com -s delete_repo` then I retry `gh repo delete mergodon/td-registry --yes`. (Repo still exists on GitHub until that lands.)

**Open follow-ups beyond this session:**

- First real-project run of `/td-mailbox` on a project with open cross-repo work.
- First real `/td-close` exercising the mechanical stack-reality-check.
- Brownfield-detection real-project validation of the v4.x framework.
