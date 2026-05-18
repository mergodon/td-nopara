# {{project_name}}

## What this is

{{one_or_two_sentences}}

## Who it's for

{{one_sentence}}

## Stack & choices

- Language/runtime: Node (build-time only, **on local machine** — nothing runs on the server)
- Framework: {{static_generator}} (static output to `dist/`, **committed to repo**)
- Hosting: Cloudflare Workers with Static Assets — `wrangler.jsonc` declares the project as assets-only (no Worker script), Cloudflare's edge serves `dist/` directly. No build runs on the server.
- DNS / edge: Cloudflare (zone `{{apex_domain}}`); `{{apex_domain}}` and `www.{{apex_domain}}` are bound to the `{{worker_name}}` Worker via Workers Custom Domains (account-level), which manage their own internal DNS records — no user-facing A/CNAME for these hostnames.
- Media storage: {{r2_bucket_or_none}}
- Database: {{db_or_none}}
- Auth: {{auth_or_none}}
- Key libs: {{libs_or_none}}

## Deployment

| Property | Value |
|----------|-------|
| Domain | https://{{apex_domain}} |
| Cloudflare Worker | `{{worker_name}}` (default URL: `https://{{worker_name}}.{{cf_subdomain}}.workers.dev`) |
| Cloudflare account | `{{cf_account_id}}` ({{cf_account_friendly}}) |
| Zone ID | `{{cf_zone_id}}` ({{apex_domain}}) |
| Worker Custom Domains | `{{apex_domain}}`, `www.{{apex_domain}}` → `{{worker_name}}` (account-level, DNS auto-managed) |
| GitHub Repo | `{{gh_slug}}` |
| R2 Bucket | `{{r2_bucket_or_none}}` (custom domain: `media.{{apex_domain}}` — if used) |
| Production branch | `main` |
| Build location | **local** (`npm run build` → commit `dist/`); the server does not build |
| Cloudflare build command | (empty) |
| Cloudflare deploy command | `npx wrangler deploy` (reads `wrangler.jsonc`) |
| Cloudflare framework preset | None |

## Active scope

- [ ] {{first_thing}}

## Shipped

(nothing yet)

## Out of scope

- Server-side rendering, dynamic content, API routes — site is static by design
- {{other_out_of_scope_or_none}}
