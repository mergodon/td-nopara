# Debug

Project-specific troubleshooting reference. Read only when something's on fire — not part of normal flow. Populated organically as incidents surface non-obvious tricks. Optional per project — created on demand (typically during a `/td-incident` close-out), not scaffolded at `/td-init`.

## Tooling

Where the observability surfaces live, and how to reach them in a hurry.

- **Logs:** <where to find them, command to tail, URL>
- **Errors:** <error tracker (e.g., Sentry) — link, project ID, how to find a correlation ID from a user report or an alert>
- **Metrics:** <dashboard URLs, key metrics to check first>
- **Hosting / runtime:** <Forge / Cloudflare / Vercel / Coolify / etc. — admin URL, ssh command, restart procedure>
- **DB / data:** <read-only console URL or connection string for safe inspection>

## Symptom → diagnostic path

Entries added as incidents teach us. Format: symptom (what the user / alert reports), then the diagnostic walk that found root cause.

### Example: 500 errors spike after a deploy

1. Open Sentry, filter by `release:<latest-deploy-sha>` — confirms new errors are deploy-related, not coincident.
2. Grab a correlation ID from any error event.
3. SSH to the box (`<ssh-command>`), grep recent log files for that correlation ID — gives the request path + stack trace beyond what Sentry captures.
4. Cross-reference the failing path against `git diff <previous-deploy>..HEAD` for the obvious change.
5. Hotfix or rollback decision.

(Remove or replace examples as the project grows real ones.)

## Gotchas

Things that have bitten us. One per heading. Symptom → root cause → workaround.

### Example: queue worker silently dies

- **Symptom:** Jobs pile up in the `jobs` table; no visible errors in app logs; user-visible features start failing as the queue lengthens.
- **Root cause:** `php-fpm` worker hits memory limit during a large batch job. Supervisord restarts it but the in-flight batch is lost.
- **Workaround:** `memory_limit=512M` in the queue-user's `php.ini`. Also chunked the batch processor in `app/Jobs/<name>.php` to checkpoint every 100 rows.

### Example: Cloudflare cache won't invalidate

- **Symptom:** Deploy ships but the live site shows old assets/HTML.
- **Root cause:** `_redirects` rules or page-rule cache settings overriding the default purge.
- **Workaround:** Manual purge via dashboard OR `wrangler kv:key delete` if the cache is in a Workers KV namespace.

## Production debug commands

One-liners meant for incident mode only — these touch live state and require deliberation.

- **Tail prod logs:** `<command>`
- **Restart workers:** `<command>`
- **Purge CDN cache:** `<command>`
- **Run a one-off migration:** `<command>`
- **Rollback to previous deploy:** `<command>`

## When to add to this file

During or right after an incident (typically the `/td-incident` close-out step). If a diagnostic walk or tool trick took more than a few minutes to figure out, capture it here — symptom + diagnostic steps + root cause + fix or workaround. Future-you (or another developer) hitting the same fire will thank current-you.

Don't add speculative content — only document what an actual incident proved out.
