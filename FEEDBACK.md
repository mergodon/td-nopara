# td-flow feedback

Bugs and ideas about the td-flow framework itself. Captured by saying "feedback on td-flow" in any project — the routing rule appends it here. Reviewed and addressed by editing the framework directly.

When an item is addressed, delete the line. Git keeps the history.

## Open

(empty)

## Bugs

(empty)

## 2026-05-24 — pre-commit hook: `xargs` strips quotes from Test command

Bug surfaced in impostoree-app (Xcode-driven iOS project). WORKWAY Test command:
```
xcodebuild test -project ... -destination 'platform=iOS Simulator,name=iPhone 17' -quiet
```
Hook extracts the line with awk, then trims via `| xargs`. `xargs` is shell-aware: it parses and removes the single quotes around the destination value before passing to echo. Result: `eval "$CMD"` runs the command with quotes gone, and `xcodebuild` sees `Simulator,name=iPhone` and `17` as separate args — "Unknown build action '17'".

Any Test command that needs internal quoting (Xcode, JVM `-Dprop="..."`, complex grep/find chains, etc.) hits this.

Fix in `hooks/pre-commit`: replace `| xargs` with a quote-preserving trim, e.g.
```
| sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
```
Applied locally in impostoree-app's `.git/hooks/pre-commit` to unblock; the framework copy at `~/projects/td-flow/hooks/pre-commit` still has the `xargs` form. Worth fixing upstream so future `/td-init` runs ship the corrected hook.
