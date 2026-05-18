# State

<!-- Where we are right now. Top section is field-shaped for quick scan. Resume note is free-form prose — as long as it needs to be (planning lives here for multi-step work). Past sessions live in git. -->

Project:  {{project_name}}
Topic:    idle
Phase:    idle
Blocker:  none
Last:     {{init_date}} — td-flow initialized from `cloudflare-static-assets` template

## Resume note

Fresh project from the `cloudflare-static-assets` template. Static site on Cloudflare's edge: build local (`npm run build` → commit `dist/`), Cloudflare Workers with Static Assets serves the committed `dist/` directly via `wrangler.jsonc` (assets-only, no `main` field). Custom hostnames are bound via account-level Workers Custom Domains (PUT not POST, no pre-existing A/CNAME). Framework preset in the CF dashboard MUST be **None** — picking a preset rewrites the project as SSR. See `PROJECT.md` for the deployment table and `WORKWAY.md` for the full set of gotchas.
