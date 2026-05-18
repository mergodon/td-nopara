# Way of work

How this project gets tested, verified, and shipped. Section headers are locked. Add and update values as we learn the project. CLAUDE.md routes natural-language statements to the right section here.

## Local testing

Automated checks run before committing. The pre-commit hook reads `Test command` from this section.

- Test command:    {{test_command_or_none}}
- Dev server:      `npm run dev` ({{static_generator}} dev)
- Local URL:       http://localhost:{{dev_port}}
- Pre-ship checklist:
  - [ ] `npm run build` succeeds locally without errors
  - [ ] `dist/` is committed (Cloudflare serves the committed `dist/` directly — no build runs on the server)
  - [ ] If `public/_redirects` changed: visually re-check the rules against legacy URL examples

No test suite — site is static, verification is by build + visual check on the live URL.

### When local testing isn't possible

- What can be tested locally: build (`npm run build`), dev server, the produced `dist/` itself
- What requires the live environment: `_redirects` behavior (dev servers ignore it; only the Cloudflare edge honors it), edge cache, R2 image serving via `media.{{apex_domain}}`
- The workaround for development: dev server covers most things; for `_redirects` push to `main` and verify on the live URL or on the `.workers.dev` URL

## Local UAT

- Who runs it: nobody — static site, no UAT step required
- What to verify: n/a
- How: n/a

## Live

- Live URL:        https://{{apex_domain}}
- Worker URL:      https://{{worker_name}}.{{cf_subdomain}}.workers.dev (always available, useful for smoke-testing)
- Deploy:          on push to `origin/main` — Cloudflare's webhook fires, the build pipeline clones the repo, sees the empty build command, runs `npx wrangler deploy` which reads `wrangler.jsonc` and uploads `dist/` as static assets. Total time ~30–60 seconds. No npm install, no Node, no static generator on the server.
- Smoke after ship: `curl -sI https://{{apex_domain}} | head -1` should return `HTTP/2 200`
- Logs / build history: Cloudflare dashboard → Workers & Pages → `{{worker_name}}` → Deployments / Logs
- Rollback: dashboard → Deployments → previous deployment → Rollback

## Framework specifics

### {{static_generator}} (static output)

- `npm run build` writes static HTML/assets to `dist/`. **`dist/` is committed** — Cloudflare serves what's in the repo. Always build locally before committing changes to `src/` or `public/`.
- {{generator_specific_notes_or_none}}

### Cloudflare Workers with Static Assets

- Project name: `{{worker_name}}`. Default URL: `https://{{worker_name}}.{{cf_subdomain}}.workers.dev`.
- `wrangler.jsonc` at repo root declares the project: `name`, `compatibility_date`, and `assets.directory: ./dist`. **No `main` field** — that's what makes it assets-only (no Worker script runs).
- Build settings in the Cloudflare dashboard:
  - Framework preset: **None** — DO NOT pick a framework preset (e.g. Astro, Next, SvelteKit); selecting one will trigger that framework's `add cloudflare` adapter and rewrite the project as an SSR Worker.
  - Build command: **empty** — server runs nothing, just clones the repo.
  - Deploy command: `npx wrangler deploy` (default) — reads `wrangler.jsonc`, uploads `dist/`.
- Custom hostnames are bound via **account-level Workers Custom Domains** (not Worker Routes, not zone-level DNS):
  - `{{apex_domain}}` → `{{worker_name}}`
  - `www.{{apex_domain}}` → `{{worker_name}}`
  - Cloudflare auto-manages the DNS for these hostnames (you'll see placeholder AAAA records pointing at `100::` in the zone — that's Cloudflare's internal routing, do not edit).
  - API: `PUT /accounts/{id}/workers/domains` (note: PUT, not POST). The hostname must NOT already have an A/CNAME record in the zone, or the bind fails — delete the existing record first.
- Redirects live in `public/_redirects`. The build copies it into `dist/_redirects`; the Workers Static Assets handler honors it. Real static assets take precedence over `_redirects` rules — so `/foo/real-page/` serves the real page and won't be caught by a wildcard rule.
- Headers (cache control, security) can be set in `public/_headers` if needed.
- The `cloudflare` skill (uses `$CLOUDFLARE_API_TOKEN`) handles DNS, R2, cache purge, Custom Domain binds, etc.

### Cloudflare (DNS + R2)

- DNS managed inside the `{{apex_domain}}` zone (account `{{cf_account_id}}`, zone ID `{{cf_zone_id}}`).
- SSL: Full mode.
- R2 bucket `{{r2_bucket_or_none}}` hosts media; served via `media.{{apex_domain}}` (CNAME → `public.r2.dev`, R2 Custom Domain).
- Cache purge / DNS edits via the `cloudflare` skill (uses `$CLOUDFLARE_API_TOKEN`).

## Notes

- All hosting is on Cloudflare's edge — no servers, no containers, no build pipeline doing heavy lifting. Builds happen locally and the result is committed.
- R2 buckets can't be renamed (it's a destructive recreate). Pick the bucket name carefully on first creation; the user-facing name is the `media.{{apex_domain}}` custom domain, which can change freely.
